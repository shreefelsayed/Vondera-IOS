//
//  MarketCheckCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct MarketCheckCard: View {
    var market:Markets
    @Binding var checked:Bool
    
    var body: some View {
        HStack() {
            Image(market.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40)
            
            Text(market.name)
                .bold()
            
            Spacer()
            
            Toggle("", isOn: $checked)
        }
        .padding()
    }
}

#Preview {
    MarketCheckCard(market: Markets.example(), checked: .constant(false))
}
