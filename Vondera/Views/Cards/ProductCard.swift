//
//  ProductCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductCard: View {
    var product:Product
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
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
            .background(Color.white)
            .shadow(radius: 15)
            .cornerRadius(15)
            .frame(height: 240)
            
            Spacer().frame(height: 16)
            
            Text(product.name.uppercased())
                .font(.title3)
                .lineLimit(1)
                .bold()
            
            Text(product.categoryName)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundColor(.secondary)
            
            Text("\(Int(product.price)) LE")
                .font(.title2)
                .multilineTextAlignment(.center)
                .bold()
           
            
        }
        .padding()
        .background(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.03))
        .cornerRadius(15)
        
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductCard(product: Product.example())
    }
}
