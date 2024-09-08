//
//  StoreEditName.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import PhotosUI

struct StoreInformation: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var userInfo = UserInformation.shared
    
    @State private var name = ""
    @State private var slogan = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var gov = ""
    @State private var cateNo:Int = 7
    
    @State private var selectedImage: UIImage? = nil
    @State private var pickedPhoto:PhotosPickerItem?
    
    @State private var isSaving = false
    @State private var isLoading = false
    
    
    @State private var isCategorySheet = false
    
    var body: some View {
        List {
            // MARK : INFO
            Section("Store info") {
                
                // MARK : LOGO
                HStack {
                    Spacer()
                    PhotosPicker(selection: $pickedPhoto) {
                        ZStack(alignment: .bottomTrailing) {
                            ImagePickupHolder(currentImageURL: userInfo.user?.store?.logo ?? "", selectedImage: selectedImage, currentImagePlaceHolder: UIImage(named: "app_icon"), reduis: 120)
                            
                            Image(.btnCamera)
                        }
                    }
                    .onChange(of: pickedPhoto) { _ in
                        guard let pickedPhoto = pickedPhoto else { return }
                        Task {
                            if let image = try? await pickedPhoto.getImage() {
                                self.selectedImage = image
                            }
                        }
                    }
                    .frame(alignment: .center)
                    Spacer()
                }
                
                
                FloatingTextField(title: "Name", text: $name, required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Slogan", text: $slogan, required: nil, autoCapitalize: .sentences, keyboard: .default)
                
                FloatingTextField(title: "Phone", text: $phone, required: true, autoCapitalize: .never, keyboard: .phonePad)
                
                // MARK : Category Picker
                if let storeCategory = CategoryManager().getCategoryById(id: cateNo) {
                    Text("Store Category")
                        .bold()
                    
                    HStack {
                        Label {
                            Text(storeCategory.name)
                        } icon: {
                            Image(storeCategory.drawableId)
                        }
                        
                        Spacer()
                        
                        Image(systemName : "chevron.right")
                    }
                    .bold()
                    .onTapGesture {
                        isCategorySheet.toggle()
                    }
                }
                
                
                
                
            }
            .listRowSeparator(.hidden)
            
            // MARK : Address
            Section("Address") {
                Picker("Government", selection: $gov) {
                    ForEach(GovsUtil().govs, id: \.self) { option in
                        Text(option)
                    }
                }
                
                FloatingTextField(title: "Address", text: $address, caption: "We won't share your address, we collect it for analyze perpose", required: nil, multiLine: true)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .task {
            await fetchData()
        }
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .sheet(isPresented: $isCategorySheet, content: {
            NavigationStack {
                StoreCategoryPicker(cateId: $cateNo, isPresented: $isCategorySheet)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    save()
                }
                .disabled(isLoading || isSaving)
            }
        }
        .navigationTitle("Store information")
        .withAccessLevel(accessKey: .storeSettings, presentation: presentationMode)
    }
    
    
    private func fetchData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        do {
            let result = try await StoresDao().getStore(uId: storeId)
            guard let result = result else { return }
            DispatchQueue.main.async {
                self.name = result.name
                self.slogan = result.slogan ?? ""
                self.phone = result.phone
                self.address = result.address
                self.gov = result.governorate
                self.cateNo = result.categoryNo ?? 7
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            CrashsManager().addLogs(error.localizedDescription, "Store Information")
        }
    }
    
    private func save() {
        guard validate() else {
            return
        }
        
        self.isSaving = true
        
        Task {
            if let storeId = userInfo.user?.storeId {
                do {
                    
                    let data = [
                        "name": name,
                        "phone": phone,
                        "slogan": slogan,
                        "address": address,
                        "governorate": gov,
                        "categoryNo":cateNo
                    ]
                    
                    try await StoresDao().update(id: storeId, hashMap: data)
                    
                    // --> Check if image changed, then update the image
                    if selectedImage != nil  {
                        self.savePhoto()
                    } else {
                        self.onUpdateCompleted()
                    }
                } catch {
                    self.onError(error: error.localizedDescription)
                    CrashsManager().addLogs(error.localizedDescription, "Store Information")
                }
            }
        }
    }
    
    func savePhoto() {
        // --> Upload the new Image
        guard let image = selectedImage, let user = userInfo.user else { return }
        
        S3Handler.singleUpload(image: image,
                               path: "stores/\(user.storeId)/icon.jpg",
                               maxSizeMB: 0.3) { link in
            if let link = link {
                Task {
                    if let _ = try? await StoresDao().update(id: user.storeId, hashMap: ["logo" : link]) {
                        self.onUpdateCompleted(url: link)
                    }
                }
            } else {
                ToastManager.shared.showToast(msg: "Error Updating image", toastType: .error)
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
            userInfo.user?.store?.name = name
            userInfo.user?.store?.slogan = slogan
            userInfo.user?.store?.address = address
            userInfo.user?.store?.governorate = gov
            userInfo.user?.store?.categoryNo = cateNo
            userInfo.user?.store?.phone = phone
            
            if let url = url {
                userInfo.user?.store?.logo = url
            }
            
            UserInformation.shared.updateUser(userInfo.user)
            
            self.presentationMode.wrappedValue.dismiss()
            self.isSaving = false
            ToastManager.shared.showToast(msg: "Your info updated", toastType: .success)
        }
        
    }
    
    private func validate() -> Bool {
        guard !name.isBlank else {
            ToastManager.shared.showToast(msg: "Please fill the store name", toastType: .error)
            return false
        }
        
        guard phone.isPhoneNumber else {
            ToastManager.shared.showToast(msg: "Please fill the store phone number", toastType: .error)
            return false
        }
        
        guard !gov.isBlank else {
            ToastManager.shared.showToast(msg: "Please select the store city", toastType: .error)
            return false
        }
        
        guard !address.isBlank else {
            ToastManager.shared.showToast(msg: "Please enter the store address", toastType: .error)
            return false
        }
        
        return true
    }
}

struct StoreCategoryPicker : View {
    @Binding var cateId:Int
    @Binding var isPresented:Bool
    var body: some View {
        List {
            ForEach(CategoryManager().getAll(), id: \.id) { cate in
                StoreCategoryLinearCard(storeCategory: cate, selected: $cateId) {
                    isPresented = false
                }
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        }
        .listStyle(.plain)
        .padding()
        .navigationTitle("Choose Category")
    }
}

#Preview {
    StoreInformation()
}
