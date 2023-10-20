//
//  ProductDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductDetails: View {
    @Binding var product:StoreProduct
    @State var myUser:UserData?
    
    @Environment(\.presentationMode) private var presentationMode

    
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
                    
                    //MARK : Settings
                    if (myUser?.canAccessAdmin ?? false) {
                        HStack {
                            Spacer()
                            
                            NavigationLink("Settings") {
                                ProductSettings(product: product, onDeleted: { value in
                                    self.presentationMode.wrappedValue.dismiss()
                                })
                            }
                            
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .refreshable {
            await refreshProduct()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if (myUser?.store?.websiteEnabled ?? false) {
                    if let storeUrl =  myUser?.store?.storeLink() {
                        ShareLink(item: product.getProductLink(storeLink: storeUrl)) {
                            Image(systemName : "square.and.arrow.up.fill")
                                .font(.title2)
                                .bold()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task {
            if let user = UserInformation.shared.getUser() {
                self.myUser = user
            }
        }
        .navigationTitle("Product info")
    }
    
    func refreshProduct() async {
        do {
            if let productData = try await ProductsDao(storeId: product.storeId).getProduct(id: product.id) {
                DispatchQueue.main.async {
                    self.product = productData
                }
            }
        } catch {
            print(error.localizedDescription)
        }
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
        ProductDetails(product: .constant(StoreProduct.example()))
    }
}
