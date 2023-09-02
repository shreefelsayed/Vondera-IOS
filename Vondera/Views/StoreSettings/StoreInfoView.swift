import SwiftUI

struct StoreInfoView: View {
    var store:Store
    @State private var deleteStoreAlert = false
    @State private var deleting = false

    var body: some View {
        List() {
            Section("Main Info") {
                NavigationLink("Name and Slogan", destination: StoreEditName(store: store))
                NavigationLink("Logo", destination: StoreLogo(store: store))
                NavigationLink("Communications", destination: StoreCommunications(store: store))
                NavigationLink("Social Presence", destination: StoreSocial(store: store))
                NavigationLink("Store Options", destination: StoreOptions(store: store))
            }
            
            Section("Shipping Info") {
                NavigationLink("Areas and shipping fees", destination: StoreShipping(storeId: store.ownerId))
                //NavigationLink("Receipt custom message", destination: StoreProducts(storeId: store.ownerId))
            }
            
            /*Section("Api Settings") {
             NavigationText(view: AnyView(EmptyView()), label: "Connect to shopify store")
             NavigationText(view: AnyView(EmptyView()), label: "Maytapi whatsapp info")
             NavigationText(view: AnyView(EmptyView()), label: "Events webhooks", divider: false)
             }*/
            
            //TODO : Create Delete Store Button With Alert
            
            Button {
                
            } label: {
                Text("Delete my store")
                    .foregroundStyle(.red)
                    .disabled(deleting)
                    .onTapGesture {
                        deleteStoreAlert.toggle()
                    }
            }
            
        }
        .alert(isPresented: $deleteStoreAlert) {
            Alert(
                title: Text("Delete your store"),
                message: Text("Are you sure you want to delete your store ? this will delete all of your data, we can't recover them later."),
                
                primaryButton: .destructive(
                    Text("Delete").foregroundColor(.red), action: {
                    deleteStore()
                }),
                secondaryButton: .cancel()
            )
        }
        .navigationTitle("Store Info")
    }
    
    func deleteStore() {
        Task {
            deleting = true
            try! await StoresDao().deleteStore(id:store.ownerId)
            
            await AuthManger().logOut()
        }
    }
}

struct StoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StoreInfoView(store: Store.example())
    }
}
