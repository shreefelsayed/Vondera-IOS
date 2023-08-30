//
//  CategoryLinearAdapter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import NetworkImage

struct ExpansesCard: View {
    var expanse:Expense
    var showData:Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            if showData {
                Text(expanse.date?.toString(format: "MMMM"))
                    .foregroundColor(.white)
                    .bold()
                    .padding(5)
                    .background {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(5)
            }
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(expanse.description)
                        .font(.body)
                    
                    Text(expanse.date?.toString() ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
               
                
                Spacer()
                
                Text("-\(expanse.amount) LE")
                    .font(.body)
                    .foregroundColor(.red)
                    .bold()
            }
            Divider()
        }
    }
}

struct ExpansesCard_Previews: PreviewProvider {
    static var previews: some View {
        ExpansesCard(expanse: Expense.example())
    }
}
