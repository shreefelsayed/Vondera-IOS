//
//  WBNewOrderSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2024.
//

import SwiftUI
import Flow

struct WBNewOrderSettings: View {
    @State private var msg = ""
    @State private var isActive = false
    @StateObject private var cursorPosition = CursorPosition()
    
    @State var wbInfo:WbInfo? = nil
    
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("This will send a message when a new order is made")
                    .bold()
                
                Toggle("Active this message", isOn: $isActive)
                
                
                CursorTrackingTextView(text: $msg, cursorPosition: cursorPosition)
                    .frame(height: 180)
                    .border(Color.gray)
                    .disabled(!isActive)
                
                
                Text("Insert variables : ")
                    .bold()
                
                VariablesAdder(text: $msg, cursorPosition: cursorPosition)
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await update() }
                }
            }
        }
        .navigationTitle("New Order Message")
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .task {
            await fetchData()
        }
        
    }
    
    private func update() async {
        guard var wbInfo = wbInfo, let storeId = UserInformation.shared.user?.storeId else { return }
        
        self.isSaving = true
        
        do {
            wbInfo.newOrder = WBMessage(active: isActive, msg: msg)
            try await StoresDao().update(id: storeId, hashMap: ["wbInfo": wbInfo.asDicitionry()])
            DispatchQueue.main.async {
                ToastManager.shared.showToast(msg: "Whatsapp info updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
                self.isSaving = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            self.isSaving = false
        }
    }
    
    private func fetchData() async {
        self.isLoading = true
        
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            guard let store = store else { return }
            DispatchQueue.main.async {
                self.wbInfo = store.wbInfo ?? WbInfo()
                self.isActive = store.wbInfo?.newOrder?.active ?? false
                self.msg = store.wbInfo?.newOrder?.msg ?? ""
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
}

struct VariablesAdder : View {
    @Binding var text:String
    @ObservedObject var cursorPosition:CursorPosition

    let items = [
        MessageVariable(hint: "Order No", value: "$orderId"),
        MessageVariable(hint: "Name", value: "$name"),
        MessageVariable(hint: "Phone", value: "$phone"),
        MessageVariable(hint: "Products", value: "$products"),
        MessageVariable(hint: "Action Date", value: "$date"),
        MessageVariable(hint: "Notes", value: "$notes"),
        MessageVariable(hint: "Shipping Fees", value: "$shippingFees"),
        MessageVariable(hint: "Price", value: "$price"),
        MessageVariable(hint: "Discount", value: "$discount"),
        MessageVariable(hint: "Deposit", value: "$deposit"),
        MessageVariable(hint: "Payment Method", value: "$paymentMethod"),
    ]
    
    var body: some View {
        HFlow {
            ForEach(items, id: \.value) { obj in
                item(hint: obj.hint, value: obj.value)
            }
        }
    }
    
    @ViewBuilder func item(hint:LocalizedStringKey, value:String) -> some View {
        Text(hint)
            .bold()
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .clipShape(Capsule())
            .onTapGesture {
                addTextAtCursor(" " + value + " ")
            }
    }
    
    func addTextAtCursor(_ newText: String) {
        guard let position = cursorPosition.position else { return }
        let index = text.index(text.startIndex, offsetBy: position)
        text.insert(contentsOf: newText, at: index)
    }
}

struct MessageVariable {
    var hint:LocalizedStringKey
    var value:String
}

#Preview {
    WBNewOrderSettings()
}
