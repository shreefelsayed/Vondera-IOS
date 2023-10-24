//
//  StoreMarketPlaces.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct StoreMarketPlacesSheet: View {
    @Binding var selectedItems:[String]
    @State var myUser:UserData?
    
    var body: some View {
        VStack {
            List(MarketsManager().getAllMarketPlaces()) { market in
                VStack(alignment: .leading) {
                    if myUser != nil {
                        NavigationLink(destination: EmptyView()) {
                            MarketCheckCard(market: market, checked: bindingForMarket(market))
                        }
                    } else {
                        MarketCheckCard(market: market, checked: bindingForMarket(market))
                    }
                }
                .padding(.trailing, 12)
                .listRowInsets(EdgeInsets())
                
            }
        }
        // MARK : Update database with the market places
        .onChange(of: selectedItems) { newValue in
            let storeMarketPlaces = selectedItems.map { id in
                return StoreMarketPlace(id: id, active: true)
            }
            
            if let user = myUser {
                Task {
                    let data = storeMarketPlaces.map { market in
                        return market.dictionary()
                    }
                    
                    try? await StoresDao().update(id: user.storeId, hashMap: ["listMarkets" : data])
                    
                    user.store?.listMarkets = storeMarketPlaces
                    UserInformation.shared.updateUser(user)
                }
            }
        }
        .onAppear {
            myUser = UserInformation.shared.getUser()
        }
        .navigationTitle("Sales Channels")
    }
    
    // --> Bind the check to list
    func bindingForMarket(_ market: Markets) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                selectedItems.contains(market.id)
            },
            set: { newValue in
                if newValue {
                    selectedItems.append(market.id)
                } else {
                    selectedItems.removeAll { $0 == market.id }
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        StoreMarketPlacesSheet(selectedItems: .constant(["instagram", "facebook"]))
    }
}
