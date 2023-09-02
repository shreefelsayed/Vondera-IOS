//
//  StoreOrdersCount.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct StoreOrdersCount: View {
    var user:UserData
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                NavigationLink(destination: OrdersFragment()) {
                    HStack {
                        Text("Orders to fulfil")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(user.store!.ordersCountObj?.fulfill ?? 0)")
                        Image(systemName: "arrow.right")
                    }
                }
                Divider()
                NavigationLink(destination: StoreCouriers(storeId: user.storeId)) {
                    HStack {
                        Text("With Courier")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(user.store!.ordersCountObj?.OutForDelivery ?? 0)")
                        Image(systemName: "arrow.right")
                    }
                }
                
                Divider()
                
                NavigationLink(destination: UserOrders(id: user.id, storeId: user.storeId)) {
                    HStack {
                        Text("My Orders")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(user.ordersCount ?? 0)")
                        Image(systemName: "arrow.right")
                    }
                }
                

            }
            
            Spacer()
        }
        
    }
}

struct StoreOrdersCount_Previews: PreviewProvider {
    static var previews: some View {
        StoreOrdersCount(user: UserData.example())
    }
}
