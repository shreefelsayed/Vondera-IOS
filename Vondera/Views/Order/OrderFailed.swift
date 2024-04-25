//
//  OrderFailed.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/11/2023.
//

import SwiftUI
import FirebaseFirestore

struct OrderFailed: View {
    @Binding var order: Order
    @State private var isSaving = false
    
    @State private var clientShippingFees:Double = 0
    @State private var courierShippingFees:Double = 0
    @State private var partialReturn = false
    
    @State private var items:[OrderProductObject] = []
    @Environment(\.presentationMode) private var presentationMode


    var body: some View {
        VStack{
            List {
                FloatingTextField(title: "Paid Shipping fees", text: .constant(""), caption: "How much money did the client paid for the courier", required: true, isNumric: true, number: $clientShippingFees)
                
                FloatingTextField(title: "Courier Shipping fees", text: .constant(""), caption: "How much money will the courier take from you", required: true, isNumric: true, number: $courierShippingFees)
                
                if (order.listProducts?.getTotalQuantity() ?? 0 > 1) {
                    Toggle("Partial Return", isOn: $partialReturn)
                }
                
                if partialReturn {
                    Section {
                        ForEach($items.indices, id: \.self) { index in
                            CartCard(orderProduct: $items[index])
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                        }
                        
                        .onDelete { index in
                            items.remove(atOffsets: index)
                        }
                    }

                }
            }
            
            // MARK : Pricing
            VStack (alignment: .leading) {
                HStack {
                    Text("Total Sold items")
                    
                    Spacer()
                    
                    Text(partialReturn ? "\(items.count) Pieces" : "0 Pieces")
                }
                
                Divider()
                
                HStack {
                    Text("Total Cash from Courier")
                    
                    Spacer()
                    
                    //TODO
                    /*Text(partialReturn ? "\(clientShippingFees - courierShippingFees - (order.discount ?? 0) + items.getTotalPrice()) LE" : "\((clientShippingFees - courierShippingFees)) LE")*/
                }
            }
            .padding()
            .ignoresSafeArea()
            .background(Color.background)
        }
        .padding()
        .listStyle(.plain)
        .navigationTitle("Failed Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(items.isEmpty || isSaving)
            }
        }
        .willProgress(saving: isSaving)
        .task {
            courierShippingFees = order.courierShippingFees ?? 0
            clientShippingFees = order.clientShippingFees 
            
            if let items = order.listProducts {
                self.items = items
            }
        }
    }
    
    func update() {
        Task {
            if (order.storeId ?? "").isEmpty {
                order.storeId = UserInformation.shared.user?.storeId ?? ""
            }
            
            guard let storeId = order.storeId, !storeId.isEmpty else {
                ToastManager.shared.showToast(msg: "Store id is empty")
                return
            }
            
            self.isSaving = true
            
            let data = [
                "statue" : "Failed",
                "clientShippingFees": clientShippingFees,
                "courierShippingFees": courierShippingFees,
                "part" : partialReturn,
                "storeId": storeId,
                "dateDelivered": Date(),
                "listProducts": try items.map { try Firestore.Encoder().encode($0) }
            ]
            
            do {
                try await OrdersDao(storeId: storeId).update(id:order.id, hashMap: data)
                DispatchQueue.main.async { [self] in
                    order.statue = "Failed"
                    order.storeId = storeId
                    order.clientShippingFees = clientShippingFees
                    order.courierShippingFees = courierShippingFees
                    order.part = partialReturn
                    order.dateDelivered = Date().toFirestoreTimestamp()
                    order.listProducts = items
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
                    
                }
            }
            
            self.isSaving = false
        }
    }
}

#Preview {
    NavigationStack {
        OrderFailed(order: .constant(Order.example())) 
    }
}
