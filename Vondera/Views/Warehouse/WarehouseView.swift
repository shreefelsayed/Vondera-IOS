//
//  WarehouseView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI
import SlidingTabView

struct WarehouseView: View {
    var storeId: String
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
            TopTaps(selection: $selectedTab, tabs: ["In Stock", "Almost Out", "Out of Stock"])
            if selectedTab == 0 {
                inStockView
            } else if selectedTab == 1 {
                almostOutView
            } else {
                outOfStockView
            }
            Spacer()
        }
        .navigationTitle("Warehouse")
        .padding()
    }
}


struct WarehouseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WarehouseView(storeId: "")
        }
    }
}
