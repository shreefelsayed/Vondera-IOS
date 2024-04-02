//
//  WarehouseView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI
import SlidingTabView

struct WarehouseView: View {
    var storeId: String = UserInformation.shared.user?.storeId ?? ""
    @State private var selectedTab = 0
    @State private var inStockView: InStock
    @State private var almostOutView: AlmostOut
    @State private var outOfStockView: OutOfStock
    
    init(storeId: String) {
        self.storeId = storeId
        _inStockView = State(wrappedValue: InStock(storeId: storeId))
        _almostOutView = State(wrappedValue: AlmostOut(storeId: storeId))
        _outOfStockView = State(wrappedValue: OutOfStock(storeId: storeId))
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTopTabBar(tabIndex: $selectedTab, titles: ["In Stock", "Almost Out", "Out of Stock"])
                .padding(.leading, 12)
                .padding(.top, 12)
            
            if selectedTab == 0 {
                inStockView
            } else if selectedTab == 1 {
                almostOutView
            } else {
                outOfStockView
            }
            Spacer()
        }
       
        .padding()
        .background(Color.background)
        .navigationTitle("Warehouse")
    }
}


#Preview {
    NavigationView {
        WarehouseView(storeId: Store.Qotoofs())
    }
}
