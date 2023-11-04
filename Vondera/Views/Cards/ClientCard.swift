//
//  ClientCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct ClientCard: View {
    var client:Client
    var storeId:String
    @State var showContact = false
    @State private var sheetHeight: CGFloat = .zero

    
    var body: some View {
        NavigationLink(destination: ClientOrders(client: client, storeId: storeId)) {
            VStack (alignment: .leading) {
                HStack {
                    Text(client.name)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    
                    Text("\(client.ordersCount ?? 0) 📦")
                }
                VStack(alignment: .leading) {
                    Text(client.gov)
                        .font(.caption)
                    
                    HStack {
                        Text("Last order \(client.lastOrder.toString())")
                            .font(.caption)
                        
                        Spacer()
                        
                        if client.total != nil && !client.total!.isNaN && !client.total!.isInfinite{
                            Text("Spent \(Int(client.total ?? 0)) EGP")
                                .font(.caption)
                        }
                        
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                showContact.toggle()
            } label: {
                Image(systemName: "ellipsis.message.fill")
            }
            .tint(.green)
        }
        .sheet(isPresented: $showContact) {
            ContactDialog(phone: client.phone, toggle: $showContact)
        }
        
    }
}
