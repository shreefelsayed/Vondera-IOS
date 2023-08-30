//
//  StoreInfoView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct StoreInfoView: View {
    var store:Store
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Main Info")
                        .font(.title2)
                        .bold()
                    
                    Spacer().frame(height: 12)
                    
                    NavigationText(view: AnyView(StoreEditName(store: store)), label: "Name and Slogan")
                    NavigationText(view: AnyView(StoreLogo(store: store)), label: "Logo")
                    NavigationText(view: AnyView(StoreCommunications(store: store)), label: "Communications")
                    NavigationText(view: AnyView(StoreSocial(store: store)), label: "Social Presence")
                    NavigationText(view: AnyView(StoreOptions(store: store)), label: "Store Options", divider: false)
                }
                
                Spacer().frame(height: 20)
                
                VStack(alignment: .leading) {
                    Text("Products")
                        .font(.title2)
                        .bold()
                    
                    Spacer().frame(height: 12)
                    
                    NavigationText(view: AnyView(StoreCategories(store: store)), label: "Categories")
                    NavigationText(view: AnyView(StoreProducts(storeId: store.ownerId)), label: "Products", divider: false)
                }
                
                Spacer().frame(height: 20)
                
                VStack(alignment: .leading) {
                    Text("Shipping Info")
                        .font(.title2)
                        .bold()
                    
                    Spacer().frame(height: 12)
                    
                    NavigationText(view: AnyView(StoreShipping(storeId: store.ownerId)), label: "Areas and shipping fees")
                    
                    NavigationText(view: AnyView(EmptyView()), label: "Receipt custom message", divider: false)
                }
                
                Spacer().frame(height: 20)
                
                VStack(alignment: .leading) {
                    Text("Api Settings")
                        .font(.title2)
                        .bold()
                    
                    Spacer().frame(height: 12)
                    
                    NavigationText(view: AnyView(EmptyView()), label: "Connect to shopify store")
                    NavigationText(view: AnyView(EmptyView()), label: "Maytapi whatsapp info")
                    NavigationText(view: AnyView(EmptyView()), label: "Events webhooks", divider: false)
                }


            }
        }
        .padding()
        .navigationTitle("Store Info")
    }
}

struct StoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StoreInfoView(store: Store.example())
    }
}
