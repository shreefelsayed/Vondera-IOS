//
//  StoreOrdersCount.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct StoreOrdersCount: View {
    var user:UserData?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                NavigationLink(destination: FullfillOrdersFragment()) {
                    HStack {
                        Text("Orders to fulfill")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(user?.store?.ordersCountObj?.fulfill ?? 0)")
                    }
                }.buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: StoreCouriers(storeId: user!.storeId)) {
                    HStack {
                        Text("With Courier")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(user?.store?.ordersCountObj?.OutForDelivery ?? 0)")
                    }
                }.buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: UserOrders(id: user!.id, storeId: user!.storeId)) {
                    HStack {
                        Text("My Orders")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(user?.ordersCount ?? 0)")
                    }
                }.buttonStyle(.plain)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        
    }
}

struct StoreOrdersCount_Previews: PreviewProvider {
    static var previews: some View {
        StoreOrdersCount(user:UserData.example())
    }
}
