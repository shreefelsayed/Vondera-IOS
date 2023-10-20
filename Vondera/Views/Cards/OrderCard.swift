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
    @Binding var order:Order
    var allowSelect:(() -> ())?

    @State private var sheetHeight: CGFloat = .zero
    @State private var contact = false
    @State private var options = false
    
    var body: some View {
        NavigationLink(destination: NavigationLazyView(OrderDetails(order: $order))) {
            VStack(alignment: .leading, spacing: 2) {
                //MARK : Top View
                HStack {
                    if order.marketPlaceId != nil && !order.marketPlaceId!.isBlank {
                        MarketHeaderCard(marketId: order.marketPlaceId!, withText: false)
                    }
                    
                    Text("#\(order.id)")
                        .bold()
                    
                    
                    Text(order.date.toString())
                        .font(.caption)
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
                        HStack(spacing: 0) {
                            Text("\(order.name)")
                                .foregroundColor(.secondary)
                            
                            Text(" , \(order.requireDelivery ?? true ? order.gov : "Not Shipping")")
                                .foregroundColor((order.requireDelivery ?? true) ? .secondary : .red)
                                .bold((order.requireDelivery ?? true) ? false : true)
                        }
                        
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
        .buttonStyle(.plain)
        .swipeActions(edge:.trailing, allowsFullSwipe: false) {
            if allowSelect != nil {
                Button {
                    allowSelect!()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .tint(.blue)
            }
            
            Button {
                options = true
            } label: {
                Image(systemName: "ellipsis.circle.fill")
            }
            .tint(Color.accentColor)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                contact = true
            } label: {
                Image(systemName: "ellipsis.message.fill")
            }
            .tint(.green)
        }
        .sheet(isPresented: $contact) {
            ContactDialog(phone: order.phone, toggle:$contact)
                .fixedInnerHeight($sheetHeight)
        }
        .sheet(isPresented: $options) {
            
            OrderOptionsSheet(order: $order, isPreseneted: $options)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
}

struct OrderCard_Previews: PreviewProvider {
    static var previews: some View {
        OrderCard(order: .constant(Order.example()))
    }
}
