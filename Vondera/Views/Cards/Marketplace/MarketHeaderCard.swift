//
//  MarketHeaderCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct MarketHeaderCard: View {
    var marketId:String
    var withText:Bool = true
    var turnedOff:Bool = false
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                if MarketsManager().getById(id: marketId) != nil {
                    Image(MarketsManager().getById(id: marketId)!.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16)
                        .colorMultiply(Color.white)
                    
                    if withText && !turnedOff {
                        Text(MarketsManager().getById(id: marketId)!.name)
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
                    MarketsManager().getById(id: marketId) != nil && !turnedOff ?
                    Gradient(colors: [
                        Color(hex: MarketsManager().getById(id: marketId)!.startColor),
                        Color(hex: MarketsManager().getById(id: marketId)!.endColor)
                    ])
                    : Gradient(stops: [Gradient.Stop(color: Color(hex: "#D3D3D3"), location: 0), Gradient.Stop(color: Color(hex: "#D3D3D3"), location: 1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    MarketHeaderCard(marketId: Markets.example().id)
}
