import SwiftUI

struct Dashboard: View {
    var store:Store
    var body: some View {
        List() {
            Section("") {
                NavigationLink("Reports", destination: StoreReport(storeId: store.ownerId))
            }
            
            Section("Store Users") {
                NavigationLink("Employees", destination: StoreEmployees(storeId: store.ownerId))
                NavigationLink("Couriers", destination: StoreCouriers(storeId: store.ownerId))
                NavigationLink("Shoppers", destination: ClientsView(store: store))
            }
            
            
            Section("Products") {
                NavigationLink("New Product") {
                    AddProductView(storeId: store.ownerId)
                }
                
                NavigationLink("Categories", destination: StoreCategories(store: store))
                
                NavigationLink("Store Product") {
                    StoreProducts(storeId: store.ownerId)
                }
                NavigationLink("Warehouse") {
                    WarehouseView(storeId: store.ownerId)
                }
            }
            
            
            Section("Others") {
                NavigationLink("All Orders", destination: StoreAllOrders(storeId: store.ownerId))
                NavigationLink("Deleted Orders", destination: StoreDeletedOrders(storeId: store.ownerId))
                //NavigationLink("Order Complaints", destination: EmptyView())
            }
            
            Section("Tools") {
                NavigationLink("Expanses", destination: StoreExpanses(storeId: store.ownerId))
                //NavigationLink("Create Orders Sheet", destination: EmptyView())
            }
        }
        .navigationTitle("Dashboard 💼")
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Dashboard(store: Store.example())
        }
    }
}

struct Navigation: View {
    var view:AnyView
    var label:String
    var divider = true
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: view) {
                HStack {
                    Text(label)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            if divider {
                Divider()
            }
        }
        
    }
}
