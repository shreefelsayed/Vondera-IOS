//
//  ProductCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductCard: View {
    @Binding var product:StoreProduct
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                NetworkImage(url: URL(string: product.defualtPhoto() )) { image in
                    image.centerCropped()
                } placeholder: {
                    ZStack(alignment: .center) {
                        Color.gray
                        ProgressView()
                    }
                    
                } fallback: {
                    Color.gray
                }
                .id(product.id)
                .background(Color.white)
                .shadow(radius: 15)
                .cornerRadius(15)
                .frame(height: 200)
                
                if !(product.alwaysStocked ?? false) {
                    Text(product.quantity > 0 ? "\(product.quantity)" : "Out of stock")
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(product.quantity > 0 ? Color.accentColor : .red)
                        .cornerRadius(6)
                }
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
            }
            .padding(12)
        }
        .background(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.03))
        .cornerRadius(15)
        .padding(6)
        
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductCard(product: .constant(StoreProduct.example()))
    }
}
