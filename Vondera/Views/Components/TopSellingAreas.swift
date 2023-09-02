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
        ScrollView {
            VStack(alignment: .leading) {
                Text("Top Selling Areas 🏙️")
                    .font(.title2.bold())
            
                ForEach(list, id: \.self) { govStatic in
                    AreaCount(govStatic: govStatic)
                }
            }

        }
    }
}

struct TopSellingAreas_Previews: PreviewProvider {
    static var previews: some View {
        TopSellingAreas(list: GovStatics.listExample())
    }
}

struct AreaCount: View {
    var govStatic: GovStatics
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(govStatic.name ?? "")
                    .bold()
                Spacer()
                Text("\(govStatic.count) Orders")
                    .foregroundColor(.secondary)
            }
            
            Divider()
        }.padding(2)
    }
}
