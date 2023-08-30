//
//  ProductDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductDetails: View {
    var product:Product
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack (alignment: .leading) {
                ZStack (alignment: .bottom){
                    NavigationLink(destination: FullScreenImageView(imageURLs: product.listPhotos)) {
                        
                        SlideNetworkView(imageUrls: product.listPhotos)
                    }
                    
                    
                    HStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text(product.name.uppercased())
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(product.categoryName?.uppercased() ?? "None")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                
                                Text("\(Int(product.price)) LE")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        Spacer()
                    }
                    .background{
                        Rectangle()
                            .foregroundColor(.black.opacity(0.4))
                        
                    }
                    
                }
                .frame(height: 400)
                
                
                // MARK : Product options
                Spacer().frame(height: 8)
                
                VStack(alignment: .leading) {
                    
                    // MARK : Product Desc
                    
                    VStack(alignment: .leading) {
                        Text("Product Description")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment:.leading)
                        
                        Spacer().frame(height: 8)
                        
                        let description = product.desc ?? ""
                        let isEmptyOrBlank = description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        
                        Text(isEmptyOrBlank ? "No Description provided" : description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment:.leading)
                    }
                    Spacer().frame(height: 12)
                    
                    
                    // MARK : Product Varients
                    if product.hashVarients != nil && !product.hashVarients!.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Varients")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment:.leading)
                            
                            Spacer().frame(height: 8)
                            
                            if product.hashVarients != nil {
                                ForEach(product.hashVarients!, id: \.self) { hash in
                                    VStack {
                                        HStack {
                                            Text("\(hash.keys.first?.capitalizeFirstLetter() ?? "")")
                                                .font(.headline)
                                                .bold()
                                            
                                            Spacer()
                                            
                                            Text("\(getVarientOptions(hash: hash))")
                                            
                                        }
                                        
                                        Divider()
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        Spacer().frame(height: 12)
                    }
                    
                    
                    // MARK : Product Options
                    VStack(alignment: .leading) {
                        Text("Info")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment:.leading)
                        
                        Spacer().frame(height: 8)
                        
                        HStack {
                            Text("Sold Products")
                                .font(.headline)
                                .bold()
                            
                            Spacer()
                            
                            Text("\(product.sold ?? 0) Pieces")
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("In Stock")
                                .font(.headline)
                                .bold()
                            
                            Spacer()
                            
                            Text(product.alwaysStocked ?? false ? "Always Stokced" : "\(product.quantity) Pieces")
                                .font(.headline)
                        }
                    }
                    Spacer().frame(height: 12)
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProductSettings(product: product, storeId: product.storeId)) {
                    Text("Settings")
                }
            }
        }
        .navigationTitle("Product info")
    }
    
    func getVarientOptions(hash:[String:[String]]) -> String {
        guard let arr = hash[hash.keys.first!] else {
            return ""
        }
        
        let capitalizedArr = arr.map { $0.capitalizeFirstLetter() }
        return capitalizedArr.joined(separator: ", ")
    }
}

struct ProductDetails_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetails(product: Product.example())
    }
}
