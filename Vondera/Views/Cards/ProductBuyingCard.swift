//
//  ProductCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct ProductBuyingCard: View {
    @Binding var product:StoreProduct
    var action:(() -> ())
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = product.listPhotos.first {
                CachedImageView(imageUrl: url, scaleType: .centerCrop)
                .frame(height: 200)
            }
            
            VStack(alignment: .leading) {
                Text(product.name.uppercased())
                    .font(.body)
                    .lineLimit(1)
                    .bold()
                
                Text(product.categoryName)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                
                HStack {
                    if let crossedPrice = product.crossedPrice, crossedPrice > 0 {
                        Text("\(Int(crossedPrice)) LE")
                            .font(.body)
                            .strikethrough()
                    }
                    
                    Text("\(Int(product.price)) LE")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .bold()
                }
               
                ButtonLarge(label: "Add to Cart") {
                    action()
                }
            }
            .padding(12)
        }
        .background(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.03))
        .cornerRadius(15)
        .padding(6)
    }
}

struct ProductBuyingCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductBuyingCard(product: .constant(StoreProduct.example())) {
            
        }
    }
}
