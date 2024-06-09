//
//  WarehouseView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI

struct WarehouseView: View {
    var storeId: String = UserInformation.shared.user?.storeId ?? ""
    @State private var selectedTab = 0
    @State private var alwaysStocked: AlwaysStocked?
    @State private var inStockView: InStock?
    @State private var almostOutView: AlmostOut?
    @State private var outOfStockView: OutOfStock?
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTopTabBar(tabIndex: $selectedTab, titles: ["Always Stocked", "In Stock", "Almost Out", "Out of Stock"])
                .padding(.leading, 12)
                .padding(.top, 12)
            
            if let alwaysStocked = alwaysStocked, let inStockView = inStockView, let almostOutView = almostOutView, let outOfStockView = outOfStockView {
                
                if selectedTab == 0 {
                    alwaysStocked
                } else if selectedTab == 1 {
                    inStockView
                } else if selectedTab == 2 {
                    almostOutView
                } else {
                    outOfStockView
                }
            }
            
            Spacer()
        }
       
        .padding()
        .background(Color.background)
        .navigationTitle("Warehouse")
        .task {
            initPages()
        }
    }
    
    func initPages() {
        alwaysStocked = AlwaysStocked(storeId: storeId)
        inStockView = InStock(storeId: storeId)
        almostOutView = AlmostOut(storeId: storeId)
        outOfStockView = OutOfStock(storeId: storeId)
    }
}


#Preview {
    NavigationView {
        WarehouseView(storeId: Store.Qotoofs())
    }
}
