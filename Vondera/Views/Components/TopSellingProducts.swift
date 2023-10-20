//
//  TopSellingProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import NetworkImage

struct TopSellingProducts: View {
    @Binding var prodsList:[StoreProduct]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Top Selling Products 📦")
                    .font(.title2.bold())
            
                ForEach($prodsList.indices, id: \.self) { index in
                    ProductSoldView(prod: $prodsList[index])
                }
            }

        }
    }
}
