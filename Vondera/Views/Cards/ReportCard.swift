//
//  ReportCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI

struct ReportCard: View {
    var title:LocalizedStringKey
    var amount:Int
    var prefix:LocalizedStringKey?
    var iconName:String?
    var desc:LocalizedStringKey?
    var nutural = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (alignment: .center, spacing: 12) {
                if let iconName = iconName {
                    Image(iconName)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                
                Text(title)
                    .bold()
                
                Spacer()
                
                Group {
                    Text("\(amount) ") + Text(prefix ?? "".localize())
                }
                .foregroundColor(nutural ? .black : amount > 0 ? Color.green : amount < 0 ? Color.red : Color.black)
                
            }
            
            if let desc = desc {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ReportCard(title: "Net Profit", amount: 7000, iconName: "whatsapp")
}
