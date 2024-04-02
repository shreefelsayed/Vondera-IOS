//
//  TopSellingAreas.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct TopSellingAreas: View {
    var list = [GovStatics]()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Places where you sell the most")
                .font(.title2.bold())
        
            ForEach(list.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text("\(index + 1). \(list[index].name ?? "")")
                            .bold()
                        
                        Spacer()
                        
                        Text("\(list[index].count) Orders")
                            .foregroundColor(.secondary)
                    }
                    
                    if index != list.count - 1 {
                        Divider()
                    }
                    
                }
                .padding(2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
