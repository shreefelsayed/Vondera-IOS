//
//  ProductOrder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct ProductOrderCard: View {
    var orderProduct:OrderProductObject
    var body: some View {
        
        HStack(alignment: .center) {
            CachedImageView(imageUrl: orderProduct.image, scaleType: .centerCrop)
            .frame(width: 120, height: 100)
            .id(orderProduct.image)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(orderProduct.name)
                    .font(.headline.bold())
                
                Text(orderProduct.getVarientsString())
                    .font(.subheadline)
                
                HStack {
                    Spacer()
                    
                    Text("EGP \(orderProduct.price.toString()) x \(orderProduct.quantity)")
                        .foregroundColor(.accentColor)
                        .font(.body)
                        .bold()
                }
            }
            .padding(.horizontal, 6)
        }
        .cardView(padding: 6)
    }
}

#Preview {
    ProductOrderCard(orderProduct: OrderProductObject.example())
    
}
