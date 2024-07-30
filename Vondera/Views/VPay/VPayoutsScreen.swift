//
//  VPayoutsScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/12/2023.
//

import SwiftUI
import FirebaseFirestore
import AlertToast

struct VPayoutsScreen: View {
    @Binding var showSheet:Bool
    @State private var items = [VPayout]()
    @State private var isLoading = false
    @State private var canLoadMore = true
    @State private var lastSnapshot:DocumentSnapshot?
    
    var body: some View {
        List {
            ForEach(items) { item in
                
                PayoutCardView(item: item)
                
                if canLoadMore && items.last?.id == item.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        loadItems()
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .task {
            loadItems()
        }
        .refreshable {
            await refreshItems()
        }
        .overlay(alignment: .center) {
            if isLoading && items.isEmpty {
                ProgressView()
            } else if !isLoading && items.isEmpty {
                VStack {
                    Spacer()
                    EmptyMessageViewWithButton(systemName: "arrow.down.app.fill", msg: "No payouts requests were made yet") {
                        Button("New payout request") {
                            showSheet.toggle()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    func loadItems() {
        Task {
            if let storeId = UserInformation.shared.user?.storeId {
                guard !isLoading && canLoadMore else {
                    return
                }
                
                do {
                    self.isLoading = true
                    let result = try await VPayoutsDao(storeId: storeId).getAll(lastSnapshot: lastSnapshot)
                    self.lastSnapshot = result.1
                    self.items.append(contentsOf: result.0)
                    self.canLoadMore = !result.0.isEmpty
                    
                } catch {
                    print(error.localizedDescription)
                    CrashsManager().addLogs(error.localizedDescription, "Payouts")

                }
                
                self.isLoading = false
            }
        }
    }
    
    func refreshItems() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        loadItems()
    }
}

struct PayoutCardView : View {
    var item:VPayout
    var body: some View {
        HStack(alignment: .center) {
            Image(item.method == "instapay" ? .btnInstapay : .btnWallet)
                .font(.headline)
            
            VStack(alignment:.leading) {
                Text("Paid by \(item.method)")
                    .bold()
                
                Text("@\(item.identifier)")
                    .font(.body)
                
                Text(item.date.toString())
                    .font(.caption)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("EGP \(Int(item.amount))")
                    .bold()
                    .foregroundStyle(item.statue == "Cancelled" || item.statue == "Failed" ? .red : .green)
                    .strikethrough(item.statue == "Cancelled" || item.statue == "Failed", color: .red)
                
                Text(item.statue)
                    .bold()
                    .foregroundStyle(item.statue == "Success" ? .green : item.statue == "Pending" ? .yellow : .red)
            }
            
        }
    }
}

struct PayoutRequest: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isPresenting:Bool
    var onRequestMade:(() -> ())
    let methods = ["Instapay", "Wallet"]
    
    @State private var msg:String?
    @State private var method = "Instapay"
    @State private var amount = 0.0
    @State private var identifier = ""
    
    @State private var showConfirmation = false
    @State private var store:Store?
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let store = store {
                    CreditCardView(amount: Int(store.vPayWallet ?? 0), storeName: store.name, onClicked: nil)
                    
                    HStack {
                        Text("Payout method")
                        
                        Spacer()
                        Picker("Payout method", selection: $method) {
                            ForEach(methods, id: \.self) { method in
                                Text(method)
                                    .tag(method)
                            }
                        }
                    }
                    
                    FloatingTextField(title: "Amount", text: .constant(""), caption: "This is how much balance you want to withdraw", isNumric: true, number: $amount)
                    
                    FloatingTextField(title: "Identifier", text: $identifier, caption: "This is your wallet number, or your instapay ipa")
                    
                    Button("Send payout request") {
                        if check() {
                            showConfirmation.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .confirmationDialog("Confirm payout request", isPresented: $showConfirmation) {
                Button("Send request", role: .none) {
                    Task {
                        await sendPayoutRequest()
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    
                }
            } message: {
                Text("Are you sure you want to send this payout request ?")
            }
        }
        .willProgress(saving: isSaving)
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: msg)
        })
        .navigationTitle("Payout info")
        .task {
            await getData()
        }
        .withAccessLevel(accessKey: .vPayPayouts, presentation: presentationMode)
    }
    
    func check() -> Bool {
        guard amount > 0 else {
            msg = "Enter a valid amount"
            return false
        }
        
        guard Double(amount) <= (store?.vPayWallet ?? 0) else {
            msg = "Not enough funds"
            return false
        }
        
        guard !identifier.isBlank else {
            msg = "Enter a valid handler for your payment method"
            return false
        }
        
        if identifier.count != 11 && method == "Wallet" {
            msg = "Enter a valid wallet mobile number"
            return false
        }
        
        return true
    }
    func sendPayoutRequest() async {
        if let storeId = UserInformation.shared.user?.storeId {
            let data:[String:Any] = [
                "number": identifier.replacingOccurrences(of: " ", with: ""),
                "method" : method,
                "amount" : Int(amount),
                "storeId": storeId
            ]
            self.isSaving = true
            do {
                let result = try await FirebaseFunctionCaller().callFunction(functionName: "vpay-createPayout", data: data)
                DispatchQueue.main.async {
                    if let resultData = result.data as? [String: Any], let error = resultData["error"] as? String {
                        self.msg = error
                        self.isSaving = false
                    } else {
                        self.isSaving = false
                        let data = result.data as? [String: Any]
                        let success:Bool = (data?["success"] != nil)
                        let resultMsg:String = data?["msg"] as! String
                        
                        if !success {
                            self.msg = resultMsg
                            return
                        }
                        
                        self.msg = "Payout request created"
                        onRequestMade()
                        isPresenting = false
                    }
                }
            } catch {
                self.isSaving = false
                self.msg = error.localizedDescription
                CrashsManager().addLogs(error.localizedDescription, "Payout")

                return
            }
        }
    }
    
    func getData() async {
        if let storeId = UserInformation.shared.user?.storeId {
            if let store = try? await StoresDao().getStore(uId: storeId) {
                DispatchQueue.main.async {
                    self.store = store
                }
            }
        }
    }
}
