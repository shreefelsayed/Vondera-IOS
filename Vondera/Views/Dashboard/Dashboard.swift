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
                
                NavigationLink("Shoppers") {
                    (store.subscribedPlan?.accessClient ?? false) ?
                    AnyView(ClientsView(store: store)) : AnyView(AppPlans(selectedSlide: 6))
                }
            }
            
            
            Section("Products") {
                NavigationLink("New Product") {
                    AddProductView(storeId: store.ownerId)
                }
                
                NavigationLink("Categories", destination: StoreCategories(store: store))
                
                NavigationLink("Store Products") {
                    StoreProducts(storeId: store.ownerId)
                }
                
                NavigationLink("Warehouse") {
                    (store.subscribedPlan?.accessStockReport ?? false) ? 
                    AnyView(WarehouseView(storeId: store.ownerId)) : AnyView(AppPlans(selectedSlide: 7))
                }
            }
            
            
            Section("Others") {
                NavigationLink("All Orders", destination: StoreAllOrders(storeId: store.ownerId))
                NavigationLink("Deleted Orders", destination: StoreDeletedOrders(storeId: store.ownerId))
                
                //TODO
                //NavigationLink("Order Complaints", destination: EmptyView())
            }
            
            Section("Tools") {
                NavigationLink("Expanses") {
                    (store.subscribedPlan?.accessExpanses ?? false) ?
                    AnyView(StoreExpanses(storeId: store.ownerId)) : AnyView(AppPlans(selectedSlide: 8))
                }
                
                //TODO
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
