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
    var onDelete:((StoreProduct) -> ())?
    @State var myUser = UserInformation.shared.getUser()
    
    @State var settings = false
    @Environment(\.presentationMode) private var presentationMode
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack (alignment: .leading) {
                ZStack (alignment: .bottom){
                    NavigationLink(destination: FullScreenImageView(imageURLs: product.listPhotos)) {
                        SlideNetworkView(imageUrls: product.listPhotos, autoChange: true)
                            .id(product.id)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(product.name.uppercased())
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: (product.visible ?? true) ? "eye" : "eye.slash")
                                        .foregroundStyle(.white)
                                }
                                
                                
                                Text(product.categoryName?.uppercased() ?? "None")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack {
                                    if let crossedPrice = product.crossedPrice, crossedPrice > 0 {
                                        Text("\(Int(crossedPrice)) LE")
                                            .foregroundColor(.white)
                                            .font(.body)
                                            .strikethrough()
                                    }
                                    
                                    Text("\(Int(product.price)) LE")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                
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
                        
                        Text((product.desc?.isBlank ?? true) ? "No Description provided".localize() : (product.desc ?? "").localize())
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment:.leading)
                    }
                    Spacer().frame(height: 12)
                    
                    
                    // MARK : Product Varients
                    if let options = product.hashVarients, !options.isEmpty  {
                        VStack(alignment: .leading) {
                            Text("Varients")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment:.leading)
                            
                            Spacer().frame(height: 8)
                            
                            
                            ForEach(options, id: \.self) { hash in
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
                            VStack(alignment: .leading) {
                                Text("Margin")
                                    .bold()
                                
                                Text("\(product.getMargin())%")
                            }
                            .padding(24)
                            .background(.secondary.opacity(0.2))
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading) {
                                Text("Profit")
                                    .bold()
                                
                                Text("EGP \(product.getProfit())")
                            }
                            .padding(24)
                            .background(.secondary.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .refreshable {
            await refreshProduct()
        }
        .sheet(isPresented: $settings) {
            NavigationStack {
                ProductSettings(product: product, onDeleted: { value in
                    if let onDelete = onDelete {
                        onDelete(value)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if (myUser?.store?.websiteEnabled ?? false) && (product.visible ?? true) {
                        if let storeUrl =  myUser?.store?.merchantId {
                            ShareLink(item: product.getProductLink(mId: storeUrl)) {
                                Label("Share Product", systemImage: "square.and.arrow.up")
                            }
                            
                            Link(destination: product.getProductLink(mId: storeUrl)) {
                                Label("Visit Product", systemImage: "link")
                            }
                        }
                    }
                    
                    if (myUser?.canAccessAdmin ?? false) {
                        Button {
                            settings.toggle()
                        } label: {
                            Label("Options", systemImage: "gearshape")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
        .navigationTitle("Product info")
    }
    
    func refreshProduct() async {
        if let productData = try? await ProductsDao(storeId: product.storeId).getProduct(id: product.id) {
            DispatchQueue.main.async {
                self.product = productData
            }
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
