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
        List {
            Section("Your personal name") {
                
                FloatingTextField(title: "Name", text: $viewModel.name, required: true, autoCapitalize: .words)

            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Update")
                    .bold()
                    .disabled(viewModel.name.isEmpty || viewModel.isSaving)
                    .onTapGesture {
                        save()
                    }
                
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSaving)
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

#Preview {
    EditInfoView(user: UserData.example())
}
