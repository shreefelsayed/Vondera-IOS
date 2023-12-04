//
//  CourierCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct CourierCardWithNavigation: View {
    var courier:Courier
        
    var body: some View {
        NavigationLink(destination: CourierProfile(storeId: courier.storeId ?? "", courier: courier)) {
            CourierCard(courier: courier)
        }
    }
}

struct CourierCard: View {
    var courier:Courier
    
    @State private var sheetHeight: CGFloat = .zero
    @State private var showContact = false
    @State private var ordersCount = 0

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(courier.name)
                    .font(.title2)
                    .bold()
                
                Text("\(ordersCount) Orders with Courier")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .buttonStyle(.plain)
        .task {
            if let storeId = courier.storeId {
                if let count = try? await OrdersDao(storeId: storeId)
                    .getPendingCouriersOrderCount(id: courier.id) {
                    ordersCount = count
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                showContact.toggle()
            } label: {
                Image(systemName: "ellipsis.message.fill")
            }
            .tint(.green)
        }
        .sheet(isPresented: $showContact) {
            ContactDialog(phone: courier.phone, toggle: $showContact)
        }
    }
}

struct CourierCard_Previews: PreviewProvider {
    static var previews: some View {
        CourierCard(courier: Courier.example())
    }
}
