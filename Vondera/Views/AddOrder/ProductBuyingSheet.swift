//
//  ProductDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI
import NetworkImage

struct ProductBuyingSheet: View {
    var product:Product
    
    @State private var selectedDetent = PresentationDetent.large
    @State var listOption:[String] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack (alignment: .leading) {
                ZStack (alignment: .bottom){
                    // MARK : Slider
                    NavigationLink(destination: FullScreenImageView(imageURLs: product.listPhotos)) {
                        
                        SlideNetworkView(imageUrls: product.listPhotos)
                    }
                    
                    // MARK : Info
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
                .frame(height: 260)
                
                // MARK : Product options
                Spacer().frame(height: 8)
                
                
                // MARK : Product Desc
                VStack(alignment: .leading) {
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
                }
                .padding()
                
                // MARK : Product Varients
                VStack(alignment: .leading) {
                    if !listOption.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Varients")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment:.leading)
                            
                            Spacer().frame(height: 8)
                            
                            ForEach(Array(product.hashVarients!.indices), id: \.self) { index in
                                if let hash = product.hashVarients?[index],
                                   let firstKey = hash.keys.first,
                                   let values = hash[firstKey] {
                                    
                                    HStack {
                                        Text(firstKey.capitalizeFirstLetter())
                                            .bold()
                                        
                                        Spacer()
                                        
                                        Picker(firstKey.capitalizeFirstLetter(), selection: $listOption[index]) {
                                            
                                            ForEach(values, id: \.self) { value in
                                                Text(value)
                                                    .tag(value)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                    
                                    
                                    Divider()
                                }
                            }
                            
                            
                            
                        }
                        
                        Spacer().frame(height: 12)
                    }
                    
                    
                    ButtonLarge(label: "Add to cart") {
                        Task {
                            let savedItem = SavedItems(randomId: generatePIN(), productId: product.id, hashMap: getVariantsMap())
                            await CartManager().addItem(savedItems: savedItem)
                            dismiss()
                        }
                    }
                    
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
        .onAppear {
            setDefaultOptions()
        }
        .navigationTitle("Product info")
    }
    
    func generatePIN() -> String {
        let number = Int.random(in: 0...99999999)
        return String(format: "%08d", number)
    }
    
    func getVariantsMap() -> [String: String] {
        var hash: [String: String] = [:]
        
        if let hashVariants = product.hashVarients, !hashVariants.isEmpty {
            for index in hashVariants.indices {
                let item = hashVariants[index]
                if let firstKey = item.keys.first {
                    hash[firstKey] = self.listOption[index]
                }
            }
        }
        
        return hash
    }
    
    
    func setDefaultOptions() {
        if let hashVarients = product.hashVarients, !hashVarients.isEmpty {
            for item in hashVarients {
                if let firstKey = item.keys.first, let firstValue = item[firstKey]?.first {
                    listOption.append(firstValue)
                    print("add item to list \(firstValue)")
                }
            }
        } else {
            print("List is empty")
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
