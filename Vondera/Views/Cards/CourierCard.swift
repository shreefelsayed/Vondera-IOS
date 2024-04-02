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

struct CourierCardSkelton : View {
    var body: some View {
        HStack {
            SkeletonCellView(isDarkColor: true)
            .frame(width: 45, height: 45)
            .cornerRadius(45)
            
            VStack {
                SkeletonCellView(isDarkColor: true)
                    .frame(height: 15)
            }
        }
    }
}
struct CourierCard: View {
    var courier:Courier
    
    @State private var sheetHeight: CGFloat = .zero
    @State private var showContact = false

    var body: some View {
        HStack {
            CachcedCircleView(imageUrl: courier.imageUrl ?? "", scaleType: .centerCrop, placeHolder: defaultCourier)
                .frame(width: 45, height: 45)
            
            VStack(alignment: .leading) {
                Text(courier.name)
                    .bold()
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
