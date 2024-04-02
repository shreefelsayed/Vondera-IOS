//
//  MarketHeaderCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct MarketHeaderCard: View {
    var marketId:String
    var withText:Bool = false
    var turnedOff:Bool = false
    
    @State var market:Markets?
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                if let market = market  {
                    Image(market.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16)
                        .colorMultiply(Color.white)
                    
                    if withText && !turnedOff {
                        Text(market.name)
                            .font(.callout)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(4)
        }
        .background(
            LinearGradient(
                gradient:
                Gradient(colors: [
                    Color(hex: market?.startColor ?? "#D3D3D3"),
                    Color(hex: market?.endColor ?? "#D3D3D3"),
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .task {
            if let market = MarketsManager().getById(id: marketId)  {
                self.market = market
            }
        }
    }
}

#Preview {
    MarketHeaderCard(marketId: Markets.example().id)
}
