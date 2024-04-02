//
//  WarehouseCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI

struct WarehouseCardSkelton : View {
    var body: some View {
        HStack {
            SkeletonCellView(isDarkColor: true)
                .frame(width: 80, height: 100)
            
            VStack(alignment: .leading) {
                SkeletonCellView(isDarkColor: true)
                    .frame(height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
            }
        }
        .cardView()
    }
}
struct WarehouseCard: View {
    @Binding var prod:StoreProduct
    @State var showDetails = false
    var sold = false
    
    var body: some View {
        HStack(alignment: .center) {
            CachedImageView(imageUrl: prod.listPhotos[0] , scaleType: .centerCrop)
            .id(prod.listPhotos[0])
            .frame(width: 80, height: 100)
            .clipped()
        
            VStack(alignment: .leading, spacing: 6) {
                Text(prod.name.uppercased())
                    .font(.headline.bold())
                    .lineLimit(1)
                
                Text(prod.categoryName ?? "")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if sold {
                        Text("\(prod.sold ?? 0) Pieces Sold")
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(prod.quantity) Pieces")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("EGP \(prod.price)")
                }
                
                
            }
            
            Spacer()
        }
        .cardView(padding: 0)
    }
}

#Preview {
    List {
        WarehouseCard(prod: .constant(StoreProduct.example()), sold: true)
        
        WarehouseCardSkelton()
    }
    
}
