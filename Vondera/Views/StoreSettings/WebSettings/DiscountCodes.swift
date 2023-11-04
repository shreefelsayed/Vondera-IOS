//
//  DiscountCodes.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast

struct DiscountCodes: View {
    @State var addItem = false
    @State var items = [DiscountCode]()
    @State var isLoading = false
    
    
    
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:LocalizedStringKey?
    @Environment(\.presentationMode) private var presentationMode
    @State var editedItem:DiscountCode?
    
    var body: some View {
        List {
            ForEach(items) { code in
                DiscountCodeItem(discountCode: code)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            editedItem = code
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.plain)
        .overlay {
            if isLoading {
                ProgressView()
            } else if !isLoading && items.isEmpty {
                EmptyMessageView(systemName: "book", msg: "No custom pages were added to your website")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Code") {
                    addItem.toggle()
                }
                .disabled(saving)
            }
        }
        .refreshable {
            await getData()
        }
        .task {
            isLoading = true
            await getData()
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        }
        .sheet(item: $editedItem, content: { item in
            NavigationStack {
                CreaetCodeView(item: item) { action, code in
                    if action == .update {
                        msg = "Code Updated"
                        Task {
                            await getData()
                        }
                    } else if action == .delete {
                        msg = "Code Deleted"
                        if let index = items.firstIndex(where: { $0.id == code.id }) {
                            items.remove(at: index)
                        }
                    }
                }
            }
        })
        .sheet(isPresented: $addItem) {
            NavigationStack {
                CreaetCodeView { action, item in
                    if action == .create {
                        msg = "Code added"
                        items.append(item)
                    }
                }
            }
            
        }
        .navigationTitle("Discount Codes")
    }
    
    func getData() async {
        if let storeId = UserInformation.shared.user?.storeId {
            if let items = try? await CodesDao(storeId: storeId).getActive() {
                DispatchQueue.main.async {
                    self.items = items
                    self.isLoading = false
                }
            }
        }
    }
}

struct CreaetCodeView : View {
    var item:DiscountCode?
    var callBack:((CRUD, DiscountCode) -> ())
    
    @State private var max:Int = 0
    @State private var discount:Int = 0
    @State private var id = ""
    
    
    @ObservedObject private var user = UserInformation.shared
    @State private var saving = false
    @State private var msg:LocalizedStringKey?
    @State private var deleteConfirmation = false
    @Environment(\.presentationMode) private var presentationMode
    
    @State var focus = false
    var body: some View {
        VStack {
            List {
                FloatingTextField(title: "Discount Code", text: $id, caption: "This is the discount code itself, it should be unique and never used before", required: true, autoCapitalize: .characters)
                
                FloatingTextField(title: "Max Uses", text: .constant(""), caption: "The maximum number this code will be used", required: true, isNumric: true, number: $max)
                
                FloatingTextField(title: "Discount", text: .constant(""), caption: "The discount percentage that will be applied to the order from 1 to 100", required: true, isNumric: true, number: $discount)
            }
        }
        .toolbar {
            if isEdit() {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Delete", role: .destructive) {
                        deleteConfirmation.toggle()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEdit() ? "Update" : "Add") {
                    if !check() {
                        return
                    }
                    
                    isEdit() ? update() : create()
                }
            }
        }
        .task {
            if isEdit() {
                updateUI()
            }
        }
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        }
        .confirmationDialog("Are you sure you want to delete this code ?", isPresented: $deleteConfirmation, titleVisibility: .visible, actions: {
            Button("Delete", role:.destructive) {
                delete()
            }
            
            Button("No Thanks !", role: .cancel) {
                
            }
        })
        .navigationTitle(isEdit() ? "Edit Code" : "New Code")
    }
    
    func check() -> Bool {
        guard id.containsOnlyEnglishLettersOrNumbers(), id.count > 3 else {
            msg = "Please make sure you inputed a valid promocode"
            return false
        }
        
        guard max > 0 else {
            msg = "max use number must be more than zero"
            return false
        }
        
        guard discount > 0, discount <= 100 else {
            msg = "Dicount must be between 1 and 100"
            return false
        }
        
        return true
    }
    
    func update() {
        saving = true
        
        Task {
            if let storeId = user.user?.storeId, let item = item {
                let newItem = DiscountCode(id: id.uppercased(), maxUsed: max, discount: Double(discount) / 100.0)
                
                if await CodesDao(storeId: storeId).doesExist(id: newItem.id.uppercased()) && newItem.id.uppercased() != item.id.uppercased() {
                    DispatchQueue.main.async {
                        self.saving = false
                        self.msg = "This code exists before"
                    }
                    return
                }
                
                if let _ = try? await CodesDao(storeId: storeId).delete(item.id.uppercased()) {
                    if let _ = try? await CodesDao(storeId: storeId).addCode(newItem) {
                        DispatchQueue.main.async {
                            self.callBack(.update, newItem)
                            self.saving = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    func create() {
        saving = true
        Task {
            if let storeId = user.user?.storeId {
                let newItem = DiscountCode(id: id.uppercased(), maxUsed: max, discount: Double(discount) / 100.0)
                
                if await !CodesDao(storeId: storeId).doesExist(id: id.uppercased()) {
                    if let _ = try? await CodesDao(storeId: storeId).addCode(newItem) {
                        DispatchQueue.main.async {
                            self.callBack(.create, newItem)
                            self.saving = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.saving = false
                        self.msg = "This Code exists before"
                    }
                }
                
            }
        }
    }
    
    func delete() {
        saving = true
        Task {
            if let storeId = user.user?.storeId, let item = item {
                if let _ = try? await CodesDao(storeId: storeId).delete(item.id) {
                    DispatchQueue.main.async {
                        self.callBack(.delete, item)
                        self.saving = false
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func updateUI() {
        if let item = item {
            self.id = item.id
            self.discount = Int(item.discount * 100)
            self.max = item.maxUsed
        }
    }
    
    func isEdit() -> Bool {
        return item != nil
    }
}

struct DiscountCodeItem: View {
    var discountCode:DiscountCode
    @State private var msg:String?
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text("#\(discountCode.id)")
                    .font(.headline)
                    .bold()
                
                Text("\(Int(discountCode.discount * 100)) %")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                Text("\(discountCode.currentUsed) Of \(discountCode.maxUsed) Used")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                if let mId = UserInformation.shared.user?.store?.merchantId {
                    msg = "Copied to clipboard"
                    CopyingData().copyToClipboard(discountCode.id)
                }
            } label: {
                Image(systemName: "doc.on.doc.fill")
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: msg)
        }
    }
}

#Preview {
    DiscountCodes()
}
