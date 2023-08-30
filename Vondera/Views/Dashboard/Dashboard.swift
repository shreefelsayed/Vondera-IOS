//
//  Dashboard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct Dashboard: View {
    var store:Store
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                NavigationText(view: AnyView(EmptyView()), label: "Reports", divider: false)

                
                VStack(alignment: .leading) {
                    Text("Store Users")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 6)
                    
                    NavigationText(view: AnyView(StoreEmployees(storeId: store.ownerId)), label: "Employees")

                    
                    NavigationText(view: AnyView(StoreCouriers(storeId: store.ownerId)), label: "Couriers")

                    
                    NavigationText(view: AnyView(ClientsView(store: store)), label: "Shoppers", divider: false)

                }
                
                VStack(alignment: .leading) {
                    Text("Products")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 6)
                    
                    NavigationText(view: AnyView(AddProductView(storeId: store.ownerId)), label: "New Product")
                    
                    NavigationText(view: AnyView(StoreProducts(storeId: store.ownerId)), label: "Store Product")
                    
                    NavigationText(view: AnyView(WarehouseView(storeId: store.ownerId)), label: "Warehouse", divider: false)
                }
                
                VStack(alignment: .leading) {
                    Text("Others")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 6)
                    
                    NavigationText(view: AnyView(StoreAllOrders(storeId: store.ownerId)), label: "All Orders")
                    
                    NavigationText(view: AnyView(StoreDeletedOrders(storeId: store.ownerId)), label: "Deleted Orders")
                    
                    NavigationText(view: AnyView(EmptyView()), label: "Order Complaints", divider: false)
                }
                
                VStack(alignment: .leading) {
                    Text("Tools")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 6)
                    
                    NavigationText(view: AnyView(StoreExpanses(storeId: store.ownerId)), label: "Expanses")
                    NavigationText(view: AnyView(EmptyView()), label: "Create Orders Sheet", divider: false)
                    
                }
                
                
            }
            .padding()
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
