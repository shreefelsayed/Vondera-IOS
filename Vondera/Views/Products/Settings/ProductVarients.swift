//
//  ProductVarients.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import FirebaseFirestore

struct ProductVarients: View {
    @Binding var product:StoreProduct
    @Environment(\.presentationMode) private var presentationMode
    
    @State var isSaving = false
    
    @State var listTitles = [String]()
    @State var listOptions = [[String]]()
    
    
    var body: some View {
        List {
            ForEach($listTitles.indices, id: \.self) { i in
                Section {
                    FloatingTextField(title: "Variant Title", text: $listTitles[i], required: nil, autoCapitalize: .words)
                    
                    OptionsView(items: $listOptions[i])
                } header: {
                    HStack {
                        Text("Option \(i + 1) : \(listTitles[i])")
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            withAnimation {
                                deleteVarient(i : i)
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            
            HStack {
                Button {
                    withAnimation {
                        addVarient()
                    }
                } label: {
                    Label("New Option", systemImage: "plus")
                }
                Spacer()
            }
        }
        .willProgress(saving: isSaving)
        .navigationBarBackButtonHidden(isSaving)
        .navigationTitle("Product Varients")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(isSaving)
            }
        }
        .task {
            setArrayData()
        }
    }
    
    func update() {
        Task {
            await update()
        }
    }
    
    func setArrayData() {
        listOptions.removeAll()
        listTitles.removeAll()
        
        guard product.hashVarients != nil else {
            return
        }
        
        for item in product.hashVarients! {
            if let firstKey = item.keys.first, let arrayValue = item[firstKey] {
                listTitles.append(firstKey)
                listOptions.append(arrayValue)
            }
        }
    }
    
    func update() async {
        let list = listVarient()
        guard canAddVarient(), let storeId = UserInformation.shared.user?.storeId else {
            showTosat(msg: "Fill the current variant first")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            let map:[String:Any] = ["hashVarients": list]
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: map)
            self.product.hashVarients = list
            
            let map2:[String:[VariantsDetails]] = ["variantsDetails": product.getVariant()]
            let encoded: [String: Any] = try! Firestore.Encoder().encode(map2)
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: encoded)
            self.product.variantsDetails = product.getVariant()
            
            let map3:[String:Any] = ["quantity":  product.getVariant().totalQuantity()]
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: map3)
            self.product.quantity = product.getVariant().totalQuantity()
            
            DispatchQueue.main.async {
                self.product.hashVarients = list
                self.showTosat(msg: "Product variants updated")
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            showTosat(msg: error.localizedDescription.localize())
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func deleteVarient(i:Int) {
        listTitles.remove(at: i)
        listOptions.remove(at: i)
    }
    
    func canAddVarient() -> Bool {
        if listTitles.isEmpty { return true }
        
        if listTitles.last!.isEmpty || listOptions.last!.isEmpty {
            return false
        }
        
        return true
    }
    
    func addVarient() {
        guard canAddVarient() else {
            showTosat(msg: "Fill the current variant first")
            return
        }
        
        
        listTitles.append("")
        listOptions.append([String]())
    }
    
    func listVarient() -> [[String: [String]]] {
        var listVars = [[String: [String]]]()
        for (index, title) in listTitles.enumerated() {
            listVars.append([title:listOptions[index]])
        }
        
        return listVars
    }
    
    func showTosat(msg: LocalizedStringKey) {
        ToastManager.shared.showToast(msg: msg)
    }
}

struct OptionsView : View {
    @Binding var items: [String]
    @State private var newOption: String = ""
    
    var body: some View {
        ForEach($items, id: \.self) { item in
            if let index = items.firstIndex(of: item.wrappedValue) {
                FloatingTextField(title: "Option \(index + 1)", text: item, required: nil, autoCapitalize: .words, isDiabled: false)
                    .listRowSeparator(.hidden)
                    .listRowSpacing(6)
            }
        }
        .onMove { indexSet, index in
            withAnimation {
                items.move(fromOffsets: indexSet, toOffset: index)
            }
        }
        .onDelete { index in
            withAnimation {
                items.remove(atOffsets: index)
            }
        }
                
        HStack(alignment: .center) {
            FloatingTextField(title: "Option \(items.count + 1)", text: $newOption, required: nil, autoCapitalize: .words)
            
            Button {
                if newOption.isBlank {
                    return
                }
                
                items.append(newOption)
                newOption = ""
            } label: {
                Image(systemName: "plus")
            }
            .disabled(newOption.isBlank)
            .padding(.horizontal, 6)
        }
    }
}
