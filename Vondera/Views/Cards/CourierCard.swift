//
//  CourierCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct CourierCard: View {
    var courier:Courier
    
    var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(courier.name)
                        .font(.title2)
                        .bold()
                    
                    Text("\(courier.withCourier ?? 0) Orders with Courier")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                }.padding(.horizontal)
                
                Spacer()
            }
    }
}

struct CourierCard_Previews: PreviewProvider {
    static var previews: some View {
        CourierCard(courier: Courier.example())
    }
}
