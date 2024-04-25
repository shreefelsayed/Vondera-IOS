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
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                CachedImageView(imageUrl: prod.defualtPhoto() , scaleType: .centerCrop)
                .id(prod.defualtPhoto())
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
                            let stock = (prod.alwaysStocked ?? false) ? "Always Stocked" : "\(prod.getQuantity()) Pieces"
                            Text(stock)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("EGP \(prod.price.toString())")
                    }
                }
                
                Spacer()
            }
            .cardView(padding: 0)
            
            if !sold {
                ForEach(prod.getVariant().sorted(by: {$0.quantity > $1.quantity}), id: \.self) { varient in
                    HStack {
                        let image = varient.image.isBlank ? prod.defualtPhoto() : varient.image
                        CachedImageView(imageUrl: image, scaleType: .centerCrop, placeHolder: nil)
                            .id(image)
                            .frame(width: 42, height: 60)
                        
                        VStack(alignment: .leading) {
                            Text(varient.formatOptions())
                                .bold()
                            HStack {
                                let stock = (prod.alwaysStocked ?? false) ? "Always Stocked" : "\(varient.quantity) Pieces"

                                Text(stock)
                                Spacer()
                                
                                Text("EGP \(varient.price.toString())")
                            }
                            
                        }
                    }
                    .padding(.leading, 24)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        
    }
}

#Preview {
    List {
        WarehouseCard(prod: .constant(StoreProduct.example()), sold: true)
        
        WarehouseCardSkelton()
    }
    
}
