//
//  ProductOrder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductOrderCard: View {
    var orderProduct:OrderProductObject
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                ZStack {
                    NetworkImage(url: URL(string: orderProduct.image)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    } fallback: {
                        Color.gray
                    }
                    .background(Color.white)
                    .frame(width: 120, height: 100)
                    .id(orderProduct.image)
                    
                    
                }.overlay(alignment: .bottom) {
                    HStack {
                        Rectangle()
                            .foregroundColor(.accentColor)
                    }
                    .frame(height: 20)
                    
                    Text("\(Int(orderProduct.price)) x \(orderProduct.quantity)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                }
                .cornerRadius(20)
               
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(orderProduct.name.uppercased())
                        .font(.title3.bold())
                    
                    Text(orderProduct.getVarientsString())
                        .font(.subheadline)
                    
                }
                
                Spacer()
            }
            Divider()
        }
    }
}

struct ProductOrderCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductOrderCard(orderProduct: OrderProductObject.example())
    }
}
