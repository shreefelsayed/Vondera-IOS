//
//  TipCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct TipCard: View {
    var tip:Tip
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Tip of the day 💭")
                    .font(.title2)
                    .bold()
                
                Text(LocalizedStringKey(tip.en))
                    .multilineTextAlignment(.leading)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.accentColor, lineWidth: 2)
        )
    }
}

struct TipCard_Previews: PreviewProvider {
    static var previews: some View {
        TipCard(tip: Tip.example())
    }
}
