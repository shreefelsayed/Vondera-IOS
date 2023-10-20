//
//  WarehouseCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI
import NetworkImage

struct WarehouseCard: View {
    @Binding var prod:StoreProduct
    var body: some View {
        NavigationLink(destination: ProductDetails(product: $prod)) {
            HStack(alignment: .center) {
                NetworkImage(url: URL(string: prod.listPhotos[0] )) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                } fallback: {
                    Color.gray
                }
                .background(Color.white)
                .frame(width: 80, height: 60)
                .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(prod.name.uppercased())
                        .font(.headline.bold())
                        .lineLimit(1)
                    
                    Text(prod.categoryName?.uppercased() ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("\(prod.quantity) Pieces")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

struct WarehouseCard_Previews: PreviewProvider {
    static var previews: some View {
        WarehouseCard(prod: .constant(StoreProduct.example()))
    }
}
