//
//  ReportCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI

struct ReportCard: View {
    var title:String
    var amount:Int
    var prefix:String?
    var iconName:String?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (alignment: .center, spacing: 12) {
                if iconName != nil {
                    Image(iconName)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                
                Text(title)
                    .bold()
                
                Spacer()
                
                Text("\(amount) \(prefix ?? "")")
                    .foregroundStyle(amount > 0 ? Color.green : Color.red)
                
            }
                    }
    }
}

#Preview {
    ReportCard(title: "Net Profit", amount: 7000, iconName: "whatsapp")
}
