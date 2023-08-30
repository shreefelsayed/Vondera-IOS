//
//  OrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import SlidingTabView

struct OrdersFragment: View {    
    //
    @State var selectedTab = 0
    @State var user:UserData?
    @State private var latest = LatestOrdersFragment()
    @State private var confirmed = ConfirmedOrdersFragment()
    @State private var ready = ReadyOrdersFragment()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                TopTaps(selection: $selectedTab, tabs: ["Latest Orders", "Confirmed", "Ready"])
                if selectedTab == 0 {
                    latest
                } else if selectedTab == 1 {
                    confirmed
                } else {
                    ready
                }
                
                Spacer()
            }
            
            if user != nil {
                NavigationLink(destination: AddToCart(storeId: user!.storeId)) {
                    FloatingActionButton(symbolName: "cart.badge.plus", action: nil)
                }
            }
            
        }
        .onAppear {
            Task {
                self.user = await LocalInfo().getLocalUser()
            }
        }
        .navigationTitle("Fullfilment 📦")
        .padding()
        
        
    }
}

struct OrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        OrdersFragment()
    }
}
