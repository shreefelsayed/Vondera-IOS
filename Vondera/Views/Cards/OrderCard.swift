//
//  OrderCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import SwipeCell
import PDFViewer

struct OrderCardSkelton: View {
    var body: some View {
        HStack {
            SkeletonCellView(isDarkColor: true)
            .frame(width: 70, alignment: .trailing)
            .frame(maxHeight: .infinity)
            .cornerRadius(8)
            
            
            // MARK : Card Content
            VStack(alignment: .leading) {
                // MARK : First Row
                HStack(alignment: .center) {
                    SkeletonCellView(isDarkColor: false)
                        .frame(width: 30, height: 30)
                        .cornerRadius(30)
                    
                    SkeletonCellView(isDarkColor: true)
                        .frame(width:80, height: 15)
                    
                    Spacer()
                    
                    SkeletonCellView(isDarkColor: true)
                        .frame(width:40, height: 15)
                }
                
                // MARK : Address & Name
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
                
               
                // MARK : Second Row
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
                
                // MARK : Forth Row
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
            }
            .padding(.leading, 6)
            
        }
        .cardView()
        
    }
}

struct OrderCard: View {
    @Binding var order:Order
    var showPreview:Bool = true
    var allowSelect:(() -> ())?
    
    @State private var sheetHeight: CGFloat = .zero
    @State private var contact = false
    @State private var options = false
    @State private var openOrderDetails = false
        
    var body: some View {
        HStack {
            if showPreview {
                ZStack(alignment: .bottom) {
                    CachedImageView(imageUrl: order.defaultPhoto, scaleType: .centerCrop)
                        .id(order.defaultPhoto)
                    
                    HStack {
                        Text("\(order.productsCount) Items")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                }
                .frame(width: 70, alignment: .trailing)
                .frame(maxHeight: .infinity)
                .background(Color.gray)
                .cornerRadius(8)
            }
            
            // MARK : Card Content
            VStack(alignment: .leading) {
                // MARK : First Row
                HStack(alignment: .center) {
                    if order.marketPlaceId != nil && !order.marketPlaceId!.isBlank {
                        MarketHeaderCard(marketId: order.marketPlaceId!, withText: false)
                    }
                    
                    Text("#\(order.id)")
                        .font(.caption)
                        .bold()
                    
                    
                    Spacer()
                    
                    Text(order.getStatueLocalized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
                
                // MARK : Address & Name
                Text("\(order.name), \(order.gov)")
                    .font(.caption)
                
               
                // MARK : Second Row
                HStack {
                    Text("By : \(order.owner ?? "")")
                    Spacer()
                    Text(order.date.toString())
                }
                .font(.caption)
                
                // MARK : Forth Row
                HStack {
                    Text(order.getPaymentStatue)
                        .font(.caption)
                        .foregroundStyle(order.getPaymentStatueColor)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(order.getPaymentStatueColor.opacity(0.2))
                        )
                    
                    Spacer()
                    
                    Text("EGP \(order.orderPrice.toString())")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.leading, 6)
        }
        .navigationCardView(destination: OrderDetails(order: $order))
        .blur(radius: order.hidden ?? false ? 8 : 0)
        .overlay(alignment: .center) {
            if order.hidden ?? false {
                Text("This order is hidden")
            }
        }
        .swipeActions(edge:.trailing, allowsFullSwipe: false) {
            if !(order.hidden ?? false) {
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
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if !(order.hidden ?? false) {
                Button {
                    contact = true
                } label: {
                    Image(systemName: "ellipsis.message.fill")
                }
                .tint(.green)
            }
        }
        .sheet(isPresented: $contact) {
            ContactDialog(phone: order.phone, toggle:$contact)
            
        }
        .sheet(isPresented: $options) {
            OrderOptionsSheet(order: $order, isPreseneted: $options)
        }
    }
}

#Preview {
    List {
        OrderCard(order: .constant(Order.example()))
        OrderCardSkelton()
    }
    .listStyle(.plain)
}
