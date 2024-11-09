//
//  AdvancedColors.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import SwiftUI

struct ColorTempObject {
    var id:String = ""
    var color:String?
    var display:LocalizedStringKey = ""
}

struct AdvancedColors: View {
    var storeId:String
    
    @State private var colors:[ColorTempObject] = []
    
    @State private var isLoading = false
    @State private var isSaving = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach($colors, id: \.id) { $color in
                    buildColorRow(model: $color)
                    
                    if $color.id.wrappedValue != $colors.last?.id.wrappedValue {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .task { await fetch() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await update() }
                }
            }
        }
        .scrollIndicators(.hidden)
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
    }
    
    func update() async {
        DispatchQueue.main.async { self.isSaving = true }
        
        do {
            var data:[String:Any] = [:]
            
            for color in colors {
                data["siteData.\(color.id)"] = color.color ?? "#FFFFFF"
            }
            
            try await StoresDao().update(id: storeId, hashMap: data)
            
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Colors Updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            DispatchQueue.main.async { self.isSaving = false }
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    @ViewBuilder
    func buildColorRow(model: Binding<ColorTempObject>) -> some View {
        HStack {
            Text(model.wrappedValue.display)
            Spacer()
            
            ColorPicker(selection: Binding(
                get: {
                    Color(hex: model.wrappedValue.color ?? "#FFFFFF")
                },
                set: { newColor in
                    model.wrappedValue.color = newColor.toHex()
                }
            )) {
                Image(systemName: "eyedropper")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(6)
                    .clipShape(.circle)
            }
        }
    }
    
    
    func fetch() async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            guard let store = store else { return }
            
            DispatchQueue.main.async {
                self.updateUI(store)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUI(_ store: Store) {
        colors.removeAll()
        
        // Add ColorTempObject for each color setting with string values
        colors.append(ColorTempObject(id: "productTextColor",
                                      color: store.siteData?.productTextColor ?? "#FFFFFF",
                                      display: "Product Text Color"))
        
        colors.append(ColorTempObject(id: "bgColor",
                                      color: store.siteData?.bgColor ?? "#FFFFFF",
                                      display: "Background Color"))
        
        colors.append(ColorTempObject(id: "listBannerBgColor",
                                      color: store.siteData?.listBannerBgColor ?? "#FFFFFF",
                                      display: "List Banner Background Color"))
        
        colors.append(ColorTempObject(id: "listBannerTextColor",
                                      color: store.siteData?.listBannerTextColor ?? "#FFFFFF",
                                      display: "List Banner Text Color"))
        
        colors.append(ColorTempObject(id: "productImageBgColor",
                                      color: store.siteData?.productImageBgColor ?? "#FFFFFF",
                                      display: "Product Image Background Color"))
        
        colors.append(ColorTempObject(id: "buttonBgColor",
                                      color: store.siteData?.buttonBgColor ?? "#FFFFFF",
                                      display: "Button Background Color"))
        
        colors.append(ColorTempObject(id: "buttonTextColor",
                                      color: store.siteData?.buttonTextColor ?? "#FFFFFF",
                                      display: "Button Text Color"))
        
        colors.append(ColorTempObject(id: "floatingBgColor",
                                      color: store.siteData?.floatingBgColor ?? "#FFFFFF",
                                      display: "Floating Background Color"))
        
        colors.append(ColorTempObject(id: "footerBgColor",
                                      color: store.siteData?.footerBgColor ?? "#FFFFFF",
                                      display: "Footer Background Color"))
        
        colors.append(ColorTempObject(id: "footerTextColor",
                                      color: store.siteData?.footerTextColor ?? "#FFFFFF",
                                      display: "Footer Text Color"))
        
        self.isLoading = false
    }
    
    
}
