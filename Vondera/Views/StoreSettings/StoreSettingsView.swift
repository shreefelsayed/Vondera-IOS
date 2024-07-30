import SwiftUI

struct StoreSettingsView: View {
    @State var store:Store
    @State private var deleteStoreAlert = false
    @State private var deleting = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            Section() {
                NavigationLink(destination: StoreMarketPlacesUpdate()) {
                    Label(
                        title: { Text("Sales Channels") },
                        icon: { Image(.btnSalesChannel) }
                    )
                }
                
                NavigationLink {
                    StoreCustomMessage()
                } label: {
                        Label(
                            title: { Text("Receipt Options") },
                            icon: { Image(.btnReceipts) }
                        )
                }
                
                NavigationLink(destination: StoreShipping(storeId: store.ownerId)) {
                    Label(
                        title: { Text("Areas and shipping fees") },
                        icon: { Image(.btnShipping) }
                    )
                }
            }
            
            Section() {
                NavigationLink(destination: WhatsappSettings()) {
                    Label(
                        title: { Text("Whatsapp Settings") },
                        icon: { Image(.whatsapp).resizable().frame(width: 24, height: 24).scaledToFit() }
                    )
                }
            }
            
            Section() {
                NavigationLink(destination: StoreOrderSettings()) {
                    Label(
                        title: { Text("Order Settings") },
                        icon: { Image(.btnOrders) }
                    )
                }

                NavigationLink(destination: StoreProductSettings()) {
                    Label(
                        title: { Text("Products Settings") },
                        icon: { Image(.btnProducts) }
                    )
                }
                
                NavigationLink(destination: StoreOtherSettings()) {
                    Label(
                        title: { Text("Other Settings") },
                        icon: { Image(.btnSettings) }
                    )
                }
            }
            
            Section() {
                NavigationLink(destination: ImportShopify()) {
                    Label(
                        title: { Text("Import from shopify") },
                        icon: { Image(.btnShopify) }
                    )
                }
                
             }
             
            Section() {
                Label(
                    title: { Text("Delete my account") },
                    icon: { Image(.btnDelete) }
                )
                .onTapGesture {
                    deleteStoreAlert.toggle()
                }
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
        .navigationTitle("Store Settings")
        .withAccessLevel(accessKey: .storeSettings, presentation: presentationMode)
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


// TODO : A Panel to verify the password before deleting the store

#Preview {
    NavigationStack {
        StoreSettingsView(store: Store.example())
    }
}
