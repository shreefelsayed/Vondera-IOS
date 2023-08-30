//
//  OrderCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import NetworkImage
import SwipeCell
import PDFViewer

struct OrderCard: View {
    var order:Order
    @State var url:URL?
    @State var viewLocalPDF = false
    
    var body: some View {
        NavigationLink(destination: NavigationLazyView(OrderDetails(id: order.id, storeId: order.storeId ?? ""))) {
            VStack(alignment: .leading, spacing: 2) {
                //MARK : Top View
                HStack {
                    Text("#\(order.id)")
                        .bold()
                    
                    
                    Text(order.date.toString())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$ \(order.COD)")
                        .font(.subheadline)
                        .bold()
                }
                
                //MARK
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        // MARK : Statue
                        HStack {
                            Text(order.statue)
                                .bold()
                            
                            Text(order.isPaid ?? false ? "Paid" : "Not Paid")
                                .foregroundColor(order.isPaid ?? false ? Color.green : Color.red)
                            
                            Spacer()
                            
                        }
                        
                        // MARK : Client Name
                        Text("\(order.name), \(order.gov)")
                            .foregroundColor(.secondary)
                        
                        // MARK : Client Name
                        Text("By : \(order.owner ?? "")")
                            .foregroundColor(.secondary)
                    }
                    
                    
                    Spacer()
                    
                    ZStack(alignment: .center) {
                        NetworkImage(url: URL(string: order.defaultPhoto )) { image in
                            image
                                .centerCropped()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        } fallback: {
                            Color.gray
                        }
                        .background(Color.gray)
                        
                        Rectangle()
                            .foregroundColor(.black.opacity(0.2))
                        
                        Text("\(order.productsCount)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60, alignment: .trailing)
                    .cornerRadius(8)
                    
                }
            }

        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderCard_Previews: PreviewProvider {
    static var previews: some View {
        OrderCard(order: Order.example())
    }
}
