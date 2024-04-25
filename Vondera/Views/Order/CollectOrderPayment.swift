//
//  ColletMoney.swift
//  Vondera
//
//  Created by Shreif El Sayed on 05/04/2024.
//

import SwiftUI

struct CollectOrderPayment: View {
    let orderId:String
    
    @State private var amount = 0.0
    @State private var cod = 0.0
    @State private var isSaving = false
    @State private var isLoading = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            Text("Order # \(orderId)")
                .font(.title)
                .bold()
            
            Text("Enter the amount you want to collect from the customer, the order will be updated once the customer pays")
            
            FloatingTextField(title: "Amount", text: .constant(""), required: nil, isNumric: true, number: $amount)
            
            ButtonLarge(label: "Collect \(amount) EGP") {
                Task {
                    await genrateAndCopy()
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Collect Payment")
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving, msg: "Genrating Link")
        .task {
            await fetchData()
        }
    }
    
    // --> Validate
    func validate() -> Bool {
        if amount <= 0 {
            ToastManager.shared.showToast(msg: "Enter a valid amount", toastType: .error)
            return false
        }
        
        if amount > cod {
            ToastManager.shared.showToast(msg: "Amount can't be more than the order cod", toastType: .error)
            return false
        }
        
        return true
    }
    
    func genrateAndCopy() async {
        guard validate(), let userId = UserInformation.shared.user?.id, let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        
        do {
            let data:[String:Any] = [
                "orderId": orderId,
                "storeId": storeId,
                "userId": userId,
                "amount": amount
            ]
            
            let result = try await FirebaseFunctionCaller().callFunction(functionName: "vpay-createPaymentLink", data: data)
            
            guard let resultData = result.data as? [String: Any] else {
                ToastManager.shared.showToast(msg: "Error happened", toastType: .error)
                return
            }
            
            let paymentUrl = resultData["url"] as! String
            
            // --> Copy Data
            DispatchQueue.main.async {
                self.isSaving = false
                CopyingData().copyToClipboard(paymentUrl)
                ToastManager.shared.showToast(msg: "Link Copied to clipboard", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func fetchData() async {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        self.isLoading = true
        do {
            let result = try await OrdersDao(storeId: storeId).getOrder(id: orderId)
            if !result.exists {
                ToastManager.shared.showToast(msg: "Order wasn't found", toastType: .error)
                return
            }
            
            DispatchQueue.main.async {
                self.amount = result.item.COD
                self.cod = result.item.COD
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

#Preview {
    CollectOrderPayment(orderId: "")
}
