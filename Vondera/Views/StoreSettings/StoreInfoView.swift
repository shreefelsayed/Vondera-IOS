import SwiftUI

struct StoreInfoView: View {
    @State var store:Store
    @State private var deleteStoreAlert = false
    @State private var deleting = false

    var body: some View {
        List() {
            Section("Main Info") {
                NavigationLink("Name and Slogan", destination: StoreEditName(store: store))
                NavigationLink("Logo", destination: StoreLogo(store: store))
                NavigationLink("Communications", destination: StoreCommunications(store: store))
                
                
                
                //TODO : RE-ENABLE THIS
                /*
                NavigationLink("Store Category", destination: StoreCategoryUpdate(store: $store))

                 NavigationLink("Sales Channels", destination: StoreMarketPlaces(selectedItems: Binding(
                     get: { store.listMarkets!.map(\.id) },
                     set: { newValue in
                         store.listMarkets = newValue.map { id in
                             return StoreMarketPlace(id: id, active: true)
                         }
                     }
                 )))
                */
                
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
            
            
            Button {
                deleteStoreAlert.toggle()
            } label: {
                Text("Delete my account")
                    .foregroundStyle(.red)
                    .disabled(deleting)
            }
            
        }
        .alert(isPresented: $deleteStoreAlert) {
            Alert(
                title: Text("Delete your account"),
                message: Text("Are you sure you want to delete your accont ? this will delete all of your data, we can't recover them later."),
                
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
