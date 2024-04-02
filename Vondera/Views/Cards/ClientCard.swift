//
//  ClientCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct ClientCardSkelton : View {
    var body: some View {
        VStack(alignment: .leading) {
            
            SkeletonCellView(isDarkColor: true)
                .frame(height: 24)
            
            SkeletonCellView(isDarkColor: false)
                .frame(height: 15)
            
            SkeletonCellView(isDarkColor: false)
                .frame(height: 15)
            
            SkeletonCellView(isDarkColor: false)
                .frame(height: 2)
            
            HStack {
                SkeletonCellView(isDarkColor: true)
                    .frame(width: 32, height: 32, alignment: .trailing)
                    .cornerRadius(32)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(width: 100, height: 15)
                
                Spacer()
                
                SkeletonCellView(isDarkColor: true)
                    .frame(width: 32, height: 32, alignment: .trailing)
                    .cornerRadius(32)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(width: 100, height: 15)
            }
        }
        .cardView()
    }
}

struct ClientCard: View {
    var client:Client
    @State private var showContact = false
    @State private var sheetHeight: CGFloat = .zero

    var body: some View {
        VStack (alignment: .leading) {
            Text(client.name)
                .font(.headline)
                .bold()
            
            Label {
                Text(client.phone)
            } icon: {
                Image(.icCall)
            }
            
            Label {
                Text("\(client.gov ?? "") - \(client.address ?? "")")
            } icon: {
                Image(.icLocation)
            }

            Divider()
            
            HStack {
                if let ordersCount = client.ordersCount {
                    HStack {
                        Image(.btnOrders)
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text("\(ordersCount) Orders")
                    }
                    
                    Spacer()
                }
                                
                if let total = client.total, !total.isNaN, !total.isInfinite {
                    HStack {
                        Image(.btnMoney)
                            .resizable()
                            .frame(width: 32, height: 32)
                                            
                        Text("\(Int(total)).0 EGP")
                    }
                }
            }
        }
        .navigationCardView(destination: CutomerProfile(client: client))
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

#Preview {
    NavigationStack {
        List {
            ClientCard(client: Client.example())
            ClientCardSkelton()
        }
        .listStyle(.plain)
        .padding()
        .background(Color.background)
    }
    .navigationTitle("Customers")
}
