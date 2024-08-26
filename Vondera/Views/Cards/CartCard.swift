//
//  ProductOrder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct CartCard: View {
    @Binding var orderProduct: OrderProductObject
    @State private var maxQuantity = 1000
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                CachedImageView(imageUrl: orderProduct.image, scaleType: .scaleFit)
                    .frame(width: 120, height: 150)
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

                        if maxQuantity >= 1 {
                            Stepper(value: $orderProduct.quantity, in: 1...maxQuantity) {
                                Text("Quantity \(orderProduct.quantity)")
                                    .font(.caption)
                            }
                        } else {
                            Text("Out Of Stock")
                                .bold()
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            Spacer()
                        }
                    }
                    
                }
                .padding()
                
            }
        }
        .cardView(padding: 0)
        .task {
            guard !(UserInformation.shared.user?.store?.localOutOfStock ?? true) else {
                checkCurrentQuantity()
                return
            }
            
            maxQuantity = orderProduct.product?.getMaxQuantity(variant: orderProduct.product?.getVariantInfo(orderProduct.hashVaraients)) ?? 1000
            
            checkCurrentQuantity()
        }
    }
    
    private func checkCurrentQuantity() {
        if orderProduct.quantity > maxQuantity {
            orderProduct.quantity = maxQuantity
        }
        
        if orderProduct.quantity <= 0 {
            orderProduct.quantity = 1
        }
    }
}


#Preview {
    List {
        CartCard(orderProduct: .constant(OrderProductObject.example()))
    }
}
