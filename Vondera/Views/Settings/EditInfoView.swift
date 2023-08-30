import SwiftUI
import AlertToast
import LoadingButton

struct EditInfoView: View {
    var user:UserData
    @ObservedObject var viewModel:EditInfoViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(user: UserData) {
        self.user = user
        self.viewModel = EditInfoViewModel(user: user)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 12) {
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Change name")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding()
        .navigationTitle("Edit Info")
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
        
    }
    
    func save() {
        Task {
            await viewModel.updateName()
        }
    }
}

struct EditInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditInfoView(user: UserData.example())
        }
    }
}
