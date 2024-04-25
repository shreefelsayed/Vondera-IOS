//
//  ProductDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI

struct ProductBuyingSheet: View {
    @Binding var product:StoreProduct
    var onAddedToCard:((StoreProduct, [String:String]) -> ())
    
    @State private var selectedDetent = PresentationDetent.large
    @State private var selectedVariant:VariantsDetails?
    @State private var listOption:[String] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack (alignment: .leading) {
                ZStack (alignment: .bottom){
                    // MARK : Slider
                    ZStack (alignment: .topLeading) {
                        
                        if let selectedVariant = selectedVariant, !selectedVariant.image.isBlank, selectedVariant.image != product.defualtPhoto() {
                            CachedImageView(imageUrl: selectedVariant.image, scaleType: .centerCrop)
                                .id(selectedVariant.image)
                        } else {
                            NavigationLink(destination: FullScreenImageView(imageURLs: product.listPhotos)) {
                                SlideNetworkView(imageUrls: product.listPhotos)
                            }
                        }
                        
                        // --> Back button
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .onTapGesture {
                                dismiss()
                            }
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
                                
                                Text("\(selectedVariant != nil ? selectedVariant!.price.toString() : product.price.toString()) LE")
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
                    
                    if !product.canAddToCart(variant: selectedVariant) {
                        ButtonLarge(label: "Preorder Product", background: .red ,textColor: .white) {
                            ToastManager.shared.showToast(msg: "Added to cart", toastType: .success)
                            onAddedToCard(product, getVariantsMap())
                            dismiss()
                        }
                        
                        HStack {
                            Spacer()
                            Text("This variant is out of stock right now !")
                            Spacer()
                        }
                    } else {
                        ButtonLarge(label: "Add to cart") {
                            ToastManager.shared.showToast(msg: "Added to cart", toastType: .success)
                            onAddedToCard(product, getVariantsMap())
                            dismiss()
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            setDefaultOptions()
        }
        .onChange(of: listOption) { newValue in
            if let variant = product.getVariantInfo(getVariantsMap()) {
                self.selectedVariant = variant
            }
        }
        .navigationTitle("Product info")
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
