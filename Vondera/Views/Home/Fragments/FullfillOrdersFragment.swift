//
//  OrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI

struct FullfillOrdersFragment: View {
    //
    @State var selectedTab = 0
    @State var user:UserData?
    
    @State private var tabsInited = false
    @State private var tabs = [OrderCustomPaginationScreen]()

    
    var body: some View {
        VStack(spacing: 0){
            CustomTopTabBar(tabIndex: $selectedTab, titles: ["New Orders", "Confirmed", "Ready"])
                .padding(.leading, 12)
                .padding(.top, 12)
                .padding(.bottom, 2)
            
            // MARK : Views
            if !tabs.isEmpty {
                tabs[selectedTab]
                    .id(selectedTab)
            }
            
            Spacer()
        }
        .task {
            self.user = UserInformation.shared.getUser()
            initTabs()
        }
        .navigationTitle("Orders to fulfill")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    printScreen()
                }, label: {
                    Image(.icPrint)
                })
            }
        }
        
        .background(Color.background.ignoresSafeArea())
    }
    
    private func printScreen() {
        tabs[selectedTab].print()
    }
    
    private func initTabs() {
        guard !tabsInited else {
            return
        }
        
        var orderScreens = [OrderCustomPaginationScreen]()
        for statue in OrderStatues.allCases.prefix(3) {
            let screen = OrderCustomPaginationScreen(statue: statue.rawValue, navTitle: "\(statue.rawValue) Orders", isPaginated: false)
            orderScreens.append(screen)
        }
        
        self.tabs = orderScreens
        self.tabsInited = true
    }
}

