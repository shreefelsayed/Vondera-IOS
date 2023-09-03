//
//  StepsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 05/07/2023.
//

import SwiftUI

struct StepsView: View {
    @State var store:Store
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your first steps with Vondera")
                .font(.title2)
                .bold()
                .padding(.vertical, 6)
            
            StepItem(isDone: !(store.logo?.isEmpty ?? true), view: AnyView(StoreLogo(store: store)), text: "Add your store logo")

            StepItem(isDone: store.categoriesCount ?? 0 > 0, view: AnyView(CreateCategory(storeId: store.ownerId, listCategories: .constant([Category]()))), text: "Add your categories")
            
            StepItem(isDone: store.productsCount ?? 0 > 0, view: AnyView(AddProductView(storeId: store.ownerId)), text: "Add your first product")
            
            StepItem(isDone: store.listAreas?.count ?? 0 > 0, view: AnyView(StoreShipping(storeId: store.ownerId)), text: "Add your supported shipping areas")
            
            StepItem(isDone: store.couriersCount ?? 0 > 0, view: AnyView(NewCourier(storeId: store.ownerId, currentList: .constant([Courier]()))), text: "Add your couriers info")
            
            StepItem(isDone: store.ordersCount ?? 0 > 0, view: AnyView(AddToCart(storeId: store.ownerId)), text: "Create your first order")
        }.onAppear {
            Task {
                store = await LocalInfo().getLocalUser()!.store!
            }
        }
    }
}

struct StepItem: View {
    @State var isDone = false
    var view: AnyView
    var text: String
    
    var body: some View {
        NavigationLink(destination: view) {
            VStack(alignment: .leading) {
                HStack {
                    Text(text)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: isDone ? "checkmark" : "arrow.right")
                        .foregroundColor(isDone ? Color.green : Color.secondary)
                }
                
                Divider()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

