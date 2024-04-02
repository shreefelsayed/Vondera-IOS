//
//  NewAllOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/03/2024.
//

import SwiftUI

struct NewAllOrders: View {
    @State private var tabsInited = false
    @State private var selectedTab = 0
    @State private var tabs = [OrderCustomPaginationScreen]()
    
    @State private var filterDisplayed = false
    @State private var filterModel = FilterModel()
    
    var body: some View {
        VStack(alignment:.leading) {
            // MARK : Search Bar
            
            // MARK : Tabs
            CustomTopTabBar(tabIndex: $selectedTab, titles: OrderStatues.allCases.map { $0.rawValue.localize() })
                .padding(.leading, 12)
                .padding(.top, 12)
            
            // MARK : Views
            if !tabs.isEmpty {
                tabs[selectedTab]
                    .id(selectedTab)
            }
            
            Spacer()
        }
        .overlay {
            if filterDisplayed {
                FilterScreen(currentlyFiltered: filterModel, filterDisplayed: $filterDisplayed) { model in
                    self.filterModel = model
                }
            }
        }
        
        .background(Color.background)
        .task {
            initTabs()
        }
    }
    
    private func initTabs() {
        guard !tabsInited else {
            return
        }
        
        var orderScreens = [OrderCustomPaginationScreen]()
        for statue in OrderStatues.allCases {
            let screen = OrderCustomPaginationScreen(statue: statue.rawValue, navTitle: "\(statue.rawValue) Orders")
            orderScreens.append(screen)
        }
        
        self.tabs = orderScreens
        self.tabsInited = true
    }
}

#Preview {
    NewAllOrders()
}
