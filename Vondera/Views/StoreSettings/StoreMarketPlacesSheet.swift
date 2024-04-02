//
//  StoreMarketPlaces.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct StoreMarketPlacesUpdate : View {
    @ObservedObject var userInfo = UserInformation.shared

    @State var selectedItems = [String]()
    @State var isSaving = false
    
    let markets = MarketsManager().getAllMarketPlaces()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            ForEach(markets) { market in
                VStack(alignment: .leading) {
                    NavigationLink(destination: MarketPlaceOrders(marketPlaceId: market.id)) {
                        MarketCheckCard(market: market, checked: Binding(items: $selectedItems, currentItem: market.id))
                    }
                }
            }
        }
        .listStyle(.plain)
        .willProgress(saving: isSaving)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    Task {
                        await update()
                    }
                }
            }
        }
        .task {
            if let markets = userInfo.user?.store?.listMarkets {
                for market in markets {
                    if market.active {
                        selectedItems.append(market.id)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(isSaving)
        .navigationTitle("Sales Channels")
    }
    
    func update() async {
        let storeMarketPlaces = selectedItems.map { id in
            return StoreMarketPlace(id: id, active: true)
        }
        
        if let user = userInfo.user {
            self.isSaving = true
            Task {
                let data = storeMarketPlaces.map { market in
                    return market.dictionary()
                }
                
                try? await StoresDao().update(id: user.storeId, hashMap: ["listMarkets" : data])
                
                DispatchQueue.main.async {
                    user.store?.listMarkets = storeMarketPlaces
                    UserInformation.shared.updateUser(user)
                    self.isSaving = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct StoreMarketPlacesSheet: View {
    @Binding var selectedItems:[String]
    @State var myUser:UserData?
    
    var body: some View {
        VStack {
            List(MarketsManager().getAllMarketPlaces()) { market in
                VStack(alignment: .leading) {
                    MarketCheckCard(market: market, checked: bindingForMarket(market))
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
