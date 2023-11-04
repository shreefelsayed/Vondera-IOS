//
//  OrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import SlidingTabView

struct FullfillOrdersFragment: View {
    //
    @State var selectedTab = 0
    @State var user:UserData?
    
    @State private var latest = LatestOrdersFragment()
    @State private var confirmed = ConfirmedOrdersFragment()
    @State private var ready = ReadyOrdersFragment()
    
    
    var body: some View {
        VStack(spacing: 0){
            CustomTopTabBar(tabIndex: $selectedTab, titles: ["New Orders", "Confirmed", "Ready"])
                .padding(.leading, 12)
                .padding(.top, 12)
            
            NavigationStack {
                if selectedTab == 0 {
                    latest
                } else if selectedTab == 1 {
                    confirmed
                } else {
                    ready
                }
            }
            
            Spacer()
        }
        .onAppear {
            self.user = UserInformation.shared.getUser()
        }
        .navigationTitle("Orders to fullfil")
    }
}

struct OrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        FullfillOrdersFragment()
    }
}

