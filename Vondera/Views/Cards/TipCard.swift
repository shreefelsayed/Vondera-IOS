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
                
                Text(LocalizationService.shared.currentLanguage == .english_us ? tip.en.localize() : tip.ar.localize())
                    .multilineTextAlignment(.leading)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TipCard_Previews: PreviewProvider {
    static var previews: some View {
        TipCard(tip: Tip.example())
    }
}
