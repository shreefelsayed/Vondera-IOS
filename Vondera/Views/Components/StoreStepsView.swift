//
//  StepsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 05/07/2023.
//

import SwiftUI

struct StoreStepsView: View {
    var myUser:UserData?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = myUser {
                Text("Your first steps with Vondera")
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 6)
                
                StepItem(isDone: !(myUser.store?.logo?.isEmpty ?? true), view: AnyView(StoreLogo(store: myUser.store!)), text: "Add your store logo")
                
                StepItem(isDone: myUser.store?.categoriesCount ?? 0 > 0, view: AnyView(CreateCategory(storeId: myUser.storeId, onAdded: nil)), text: "Add your categories")
                
                StepItem(isDone: myUser.store?.productsCount ?? 0 > 0, view: AnyView(AddProductView(storeId: myUser.storeId)), text: "Add your first product")
                
                StepItem(isDone: myUser.store?.listAreas?.count ?? 0 > 0, view: AnyView(StoreShipping(storeId: myUser.storeId)), text: "Add your supported shipping areas")
                
                StepItem(isDone: myUser.store?.couriersCount ?? 0 > 0, view: AnyView(NewCourier(storeId: myUser.storeId, currentList: .constant([Courier]()))), text: "Add your couriers info")
                
                StepItem(isDone: myUser.store?.ordersCount ?? 0 > 0, view: AnyView(AddToCart()), text: "Create your first order")
                
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
        .buttonStyle(.plain)
    }
}

