//
//  StoreOrdersCount.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct StoreOrdersCount: View {
    @ObservedObject var user = UserInformation.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = user.user, let store = myUser.store {
                NavigationLink(destination: FullfillOrdersFragment()) {
                    HStack {
                        Text("Orders to fulfill")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(store.ordersCountObj?.fulfill ?? 0)")
                    }
                }.buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: StoreCouriers()) {
                    HStack {
                        Text("With Courier")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(store.ordersCountObj?.OutForDelivery ?? 0)")
                    }
                }.buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: UserOrders()) {
                    HStack {
                        Text("My Orders")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        Text("\(myUser.ordersCount ?? 0)")
                    }
                }
                .buttonStyle(.plain)
            }
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StoreOrdersCount_Previews: PreviewProvider {
    static var previews: some View {
        StoreOrdersCount()
    }
}
