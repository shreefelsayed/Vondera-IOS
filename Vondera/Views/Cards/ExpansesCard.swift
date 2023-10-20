//
//  CategoryLinearAdapter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import NetworkImage

struct ExpansesCard: View {
    @Binding var expanse:Expense
    
    var body: some View {
        VStack(alignment: .center) {
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
        }
    }
}
