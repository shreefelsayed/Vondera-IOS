//
//  ProductOrder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import NetworkImage

struct CartAdapter: View {
    @State private var priceText: String
    @Binding var orderProduct: OrderProductObject
    
    init(orderProduct: Binding<OrderProductObject>) {
        _orderProduct = orderProduct
        _priceText = State(initialValue: String(orderProduct.wrappedValue.price))
    }
    
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                ZStack {
                    NetworkImage(url: URL(string: orderProduct.image ?? "" )) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    } fallback: {
                        Color.gray
                    }
                    .background(Color.white)
                    .frame(width: 120, height: 160)
                    
                    
                    
                }
                .cornerRadius(20)
                
                
                VStack(alignment: .leading) {
                    Text(orderProduct.name.uppercased())
                        .font(.title3.bold())
                    
                    Text(orderProduct.getVarientsString())
                        .font(.subheadline)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Text("Price")
                        
                        Spacer()
                        
                        TextField("Price", text: $priceText)
                            .onChange(of: priceText) { newValue in
                                if let price = Double(newValue) {
                                    orderProduct.price = price
                                }
                            }
                            .keyboardType(.numberPad)
                        
                            .frame(width: 100)
                        
                    }
                    
                    HStack(alignment: .center) {
                        Text("Quantity")
                        
                        Spacer()
                        
                        Stepper(value: $orderProduct.quantity, in: 1...5000) {
                            Text("\(orderProduct.quantity)")
                                .font(.caption)
                        }
                    }
                    
                }
                
                Spacer()
            }
            Divider()
        }
    }
}

struct CartAdapter_Previews: PreviewProvider {
    static var previews: some View {
        CartAdapter(orderProduct: .constant(OrderProductObject.example()))
    }
}
