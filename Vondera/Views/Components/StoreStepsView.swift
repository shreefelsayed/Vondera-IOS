//
//  StepsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 05/07/2023.
//

import SwiftUI

struct StoreStepsView: View {
    @ObservedObject var user = UserInformation.shared
    @State var openImport = false
    var body: some View {
        VStack {
            HStack {
                Image("shopify")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 42)
                
                
                Text("Have a shopify store ? Import your data now 🚀")
            }
            .onTapGesture {
                openImport.toggle()
            }
            .navigationDestination(isPresented: $openImport) {
                ImportShopify()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.bottom, 12)
            
            VStack(alignment: .leading) {
                if let myUser = user.user, let store = myUser.store {
                    Text("Your first steps with Vondera")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 6)
                    
                    StepItem(isDone: !(store.logo?.isEmpty ?? true), view: AnyView(StoreLogo(store: myUser.store!)), text: "Add your store logo")
                    
                    StepItem(isDone: store.categoriesCount ?? 0 > 0, view: AnyView(CreateCategory(storeId: myUser.storeId, onAdded: nil)), text: "Add your categories")
                    
                    StepItem(isDone: store.productsCount ?? 0 > 0, view: AnyView(AddProductView(storeId: myUser.storeId)), text: "Add your first product")
                    
                    StepItem(isDone: store.listAreas?.count ?? 0 > 0, view: AnyView(StoreShipping(storeId: myUser.storeId)), text: "Add your supported shipping areas")
                    
                    StepItem(isDone: store.couriersCount ?? 0 > 0, view: AnyView(NewCourier(storeId: myUser.storeId, currentList: .constant([Courier]()))), text: "Add your couriers info")
                    
                    StepItem(isDone: store.ordersCount ?? 0 > 0, view: AnyView(AddToCart()), text: "Create your first order", isLast: true)
                    
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        
        
    }
}

struct StepItem: View {
    var isDone = false
    var view: AnyView
    var text: LocalizedStringKey
    var isLast = false
    
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
                
                if !isLast {
                    Divider()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StoreStepsView()
}
