//
//  TopSellingProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import NetworkImage

struct TopSellingProducts: View {
    var prodsList:[Product] = [Product]()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Top Selling Products 📦")
                    .font(.title2.bold())
            
                ForEach(prodsList) { prod in
                    ProductSoldView(prod: prod)
                }
            }

        }
    }
}



struct TopSellingProducts_Previews: PreviewProvider {
    static var previews: some View {
        ProductSoldView(prod: Product.example())
    }
}

