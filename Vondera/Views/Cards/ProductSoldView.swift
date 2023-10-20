//
//  ProductSoldView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductSoldView: View {
    @Binding var prod:StoreProduct
    
    var body: some View {
        NavigationLink(destination: ProductDetails(product: $prod)) {
            VStack {
                HStack(alignment: .center) {
                    NetworkImage(url: URL(string: prod.listPhotos[0] )) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    } fallback: {
                        Color.gray
                    }
                    .background(Color.white)
                    .frame(width: 120, height: 80)
                    .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(prod.name.uppercased())
                            .font(.title3.bold())
                        
                        Text("\(prod.sold ?? 0) Sold")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                Divider()
            }

        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductSoldView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSoldView(prod: .constant(StoreProduct.example()))
    }
}
