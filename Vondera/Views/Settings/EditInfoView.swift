import SwiftUI
import AlertToast
import PhotosUI
import FirebaseAuth

struct EditInfoView: View {
    @ObservedObject var userInfo = UserInformation.shared
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var changePassword = false
    @State private var isSaving = false
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var selectedImage: UIImage? = nil
    @State private var pickedPhoto:PhotosPickerItem?

    
    var body: some View {
        List {
            Section() {
                
                // MARK : Photo Picker
                HStack {
                    Spacer()
                    PhotosPicker(selection: $pickedPhoto) {
                        ZStack(alignment: .bottomTrailing) {
                            ImagePickupHolder(currentImageURL: userInfo.user?.userURL ?? "", selectedImage: selectedImage, currentImagePlaceHolder: UIImage(named: "defaultPhoto"), reduis: 120)
                            
                            Image(.btnCamera)
                        }
                    }
                    .onChange(of: pickedPhoto) { _ in
                        Task {
                            if let data = try? await pickedPhoto?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    self.selectedImage = uiImage
                                    return
                                }
                            }
                        }
                    }
                    .frame(alignment: .center)
                    Spacer()
                }
                
                
                FloatingTextField(title: "Name", text: $name, required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Email", text: $email, required: true, autoCapitalize: .never, keyboard: .emailAddress)
                
                
                FloatingTextField(title: "Phone", text: $phone, required: true, autoCapitalize: .never, keyboard: .phonePad)
                
                
                // --> Upadte Button
                Label(
                    title: { Text("Change my password") },
                    icon: {
                        Image(.icEditPassword)
                    }
                )
                .onTapGesture {
                    changePassword.toggle()
                }
            }
            .listRowSeparator(.hidden)
        }
        
        .listStyle(.plain)
        .task {
            updateUI()
        }
        .willProgress(saving: isSaving)
        .navigationDestination(isPresented: $changePassword, destination: {
            ChangePasswordView()
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    save()
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Edit info")
        
    }
    
    func updateUI() {
        if let myUser = userInfo.user {
            self.name = myUser.name
            self.phone = myUser.phone
            self.email = myUser.email
        }
    }
    
    private func validate() -> Bool {
        guard !name.isBlank else {
            ToastManager.shared.showToast(msg: "Fill your name", toastType: .error)
            return false
        }
        
        guard email.isValidEmail else {
            ToastManager.shared.showToast(msg: "Enter a valid email address", toastType: .error)
            return false
        }
        
        guard phone.isPhoneNumber else {
            ToastManager.shared.showToast(msg: "Enter a valid phone number", toastType: .error)
            return false
        }
        
        return true
    }
    
    func save() {
        guard validate() else {
            return
        }
        
        self.isSaving = true
        
        Task {
            if let myUser = userInfo.user {
                do {
                    // --> If email changed update the mail in auth
                    if email != myUser.email, let currentUser = Auth.auth().currentUser {
                        try await currentUser.updateEmail(to: email)
                    }
                    
                    // --> Update the info
                    let data = [
                        "name": name,
                        "phone": phone,
                        "email": email
                    ]
                    
                    try await UsersDao().update(id: myUser.id, hash: data)

                    // --> Check if image changed, then update the image
                    if selectedImage != nil  {
                        self.savePhoto()
                    } else {
                        self.onUpdateCompleted()
                    }
                } catch {
                    self.onError(error: error.localizedDescription)
                }
            }
            
            
        }
    }
    
    func savePhoto() {
        // --> Upload the new Image
        guard let selectedImage = selectedImage, let user = userInfo.user else { return }
        
        S3Handler.singleUpload(image: selectedImage, path: "stores/\(user.storeId)/users/\(user.id)/avatar.jpg", maxSizeMB: 0.3) { link in
            if let link = link {
                Task {
                    if let _ = try? await UsersDao().update(id: user.id, hash: ["userURL" : link]) {
                        self.onUpdateCompleted(url: link)
                    }
                }
            } else {
                ToastManager.shared.showToast(msg: "Error with uploading", toastType: .error)
            }
        }
    }
    
    func onError(error:String) {
        DispatchQueue.main.async {
            ToastManager.shared.showToast(msg: error.localize(), toastType: .error)
            self.isSaving = false
        }
    }
    
    func onUpdateCompleted(url:String? = nil) {
        DispatchQueue.main.async {
            // --> Set local vars
            userInfo.user?.name = name
            userInfo.user?.email = email
            userInfo.user?.phone = phone
            if let url = url {
                userInfo.user?.userURL = url
            }
            
            UserInformation.shared.updateUser(userInfo.user)

            self.presentationMode.wrappedValue.dismiss()
            self.isSaving = false
            ToastManager.shared.showToast(msg: "Your info updated", toastType: .success)
        }
        
    }
}

#Preview {
    EditInfoView()
}
