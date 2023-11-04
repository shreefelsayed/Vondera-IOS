import SwiftUI

struct StoreInfoView: View {
    @State var store:Store
    @State private var deleteStoreAlert = false
    @State private var deleting = false
    
    var body: some View {
        List {
            Section("Main info") {
                NavigationLink("Name and Slogan", destination: StoreEditName(store: store))
                
                NavigationLink("Logo", destination: StoreLogo(store: store))
                
                NavigationLink("Website Settings", destination: WebsiteSettings())

                NavigationLink("Communication", destination: StoreCommunications(store: store))
    
                NavigationLink("Store Category", destination: StoreCategoryUpdate())
                 
                NavigationLink("Sales Channels", destination: StoreMarketPlacesUpdate())
                
                NavigationLink("Store Options", destination: StoreOptions(store: store))
                
            }
            
            Section("Shipping info") {
                
                NavigationLink("Areas and shipping fees", destination: StoreShipping(storeId: store.ownerId))
                
                NavigationLink("Receipt custom message") {
                    (store.subscribedPlan?.accessCustomMessage ?? false) ?
                    AnyView(StoreCustomMessage()): AnyView(AppPlans(selectedSlide: 9))
                }
            }
            
            /*Section("Api Settings") {
             NavigationText(view: AnyView(EmptyView()), label: "Connect to shopify store")
             NavigationText(view: AnyView(EmptyView()), label: "Maytapi whatsapp info")
             NavigationText(view: AnyView(EmptyView()), label: "Events webhooks", divider: false)
             }
             */
            
            
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
            AnalyticsManager.shared.deleteStore()
            try! await StoresDao().deleteStore(id:store.ownerId)
            UserInformation.shared.clearUser()
            await AuthManger().logOut()
        }
    }
}
