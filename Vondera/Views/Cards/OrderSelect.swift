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

struct OrderSelect: View {
    @Binding var order:Order
    @Binding var checked:Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            NavigationLink(destination: NavigationLazyView(OrderDetails(order: $order))) {
                VStack {
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
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            // MARK : Statue
                            HStack {
                                Text(order.getStatueLocalized())
                                    .bold()
                                
                                Text(order.paid ?? false ? "Paid" : "Not Paid")
                                    .foregroundColor(order.paid ?? false ? Color.green : Color.red)
                                
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
                        
                        CheckBoxView(checked: $checked)
                        .padding(.horizontal)
                        
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
           
        }
    }
}
