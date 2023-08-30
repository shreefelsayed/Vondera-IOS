//
//  ClientCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct ClientCard: View {
    var client:Client
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(client.name)
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Text("\(client.ordersCount ?? 0) 📦")
            }
            
            VStack(alignment: .leading) {
                Text(client.gov)
                    .font(.caption)
                
                HStack {
                    Text("Last order \(client.lastOrder.toString())")
                        .font(.caption)
                    
                    Spacer()
                    
                    if client.total != nil && !client.total!.isNaN && !client.total!.isInfinite{
                        Text("Spent \(Int(client.total ?? 0)) EGP")
                            .font(.caption)
                    }
                    
                }
            }
            
            Divider()
        }
    }
}

struct ClientCard_Previews: PreviewProvider {
    static var previews: some View {
        ClientCard(client: Client.example())
    }
}
