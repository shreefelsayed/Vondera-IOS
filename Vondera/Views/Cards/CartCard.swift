//
//  ProductOrder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct CartCard: View {
    @Binding var orderProduct: OrderProductObject
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                CachedImageView(imageUrl: orderProduct.image, scaleType: .centerCrop)
                    .frame(width: 80, height: 120)
                    .id(orderProduct.image)
                
                
                VStack(alignment: .leading) {
                    Text(orderProduct.name.uppercased())
                        .font(.title3.bold())
                    
                    Text(orderProduct.getVarientsString())
                        .font(.subheadline)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Text("Price")
                        
                        Spacer()
                        
                        TextField("Price", value: $orderProduct.price, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                    }
                    
                    HStack(alignment: .center) {
                        Text("")
                        
                        Spacer()

                        Stepper(value: $orderProduct.quantity, in: 1...1000) {
                            Text("Quantity \(orderProduct.quantity)")
                                .font(.caption)
                        }
                    }
                    
                }
            }
        }
        .cardView(padding: 0)
    }
}


#Preview {
    List {
        CartCard(orderProduct: .constant(OrderProductObject.example()))
    }
}
