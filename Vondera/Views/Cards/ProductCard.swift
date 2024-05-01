//
//  ProductCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct ProductCardSkelton : View {
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            SkeletonCellView(isDarkColor: true)
                .frame(height: 200)
            
            VStack {
                SkeletonCellView(isDarkColor: true)
                    .frame(height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
        }
    }
}
struct ProductCard: View {
    @Binding var product:StoreProduct
    var showBuyButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Image
                CachedImageView(imageUrl: product.defualtPhoto(), scaleType: .centerCrop)
                    .id(product.defualtPhoto())

                // Product Image Info
                HStack {
                    // MARK : Quantity
                    if let stocked = product.alwaysStocked, stocked {
                        Text("\(product.quantity)")
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(product.quantity > 0 ? Color.black : .red)
                            .cornerRadius(6)
                            .frame(alignment: .topLeading)
                    }
                    
                    Spacer()
                    
                    // MARK : Hidden
                    if let visible = product.visible, !visible {
                        Image(systemName: "eye.slash")
                            .bold()
                            .foregroundStyle(.black)
                            .frame(alignment: .topTrailing)
                            .padding(4)
                    }
                }
                
                // MARK : OUT OF STOCK
                if !(product.alwaysStocked ?? false) && product.quantity <= 0 {
                    HStack {
                        Text("Out of stock")
                            .foregroundStyle(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
                }
            }
            .background(Color.white)
            .frame(height: 200)
            
            
            VStack(alignment: .leading) {
                Text(product.name.capitalizeFirstLetter())
                    .font(.body)
                    .lineLimit(1)
                    .bold()
                
                Text(product.categoryName ?? "")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(product.price.toString()) LE")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    if let crossedPrice = product.crossedPrice, crossedPrice > 0 {
                        Text("\(crossedPrice.toString()) LE")
                            .font(.body)
                            .foregroundStyle(.red)
                            .strikethrough()
                    }
                }
                
                if showBuyButton {
                    Button("Add to cart") {
                        
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.black
                    )
                    .cornerRadius(8)
                }
                
            }
            .padding(.top, 12)
            .padding(.bottom, 6)
            .padding(.horizontal, 6)
        }
        .background(Color.white)
        .cornerRadius(6)
    }
}

#Preview {
    List {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ProductCard(product: .constant(StoreProduct.example()))
            ProductCard(product: .constant(StoreProduct.example()))
        }
        .listStyle(.plain)
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ProductCardSkelton()
            ProductCardSkelton()
        }
        .listStyle(.plain)
    }
    .listStyle(.plain)
    .background(Color.background)
}
