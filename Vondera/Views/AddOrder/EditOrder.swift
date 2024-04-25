//
//  EditOrder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/10/2023.
//

import SwiftUI
import AlertToast

struct EditOrder: View {
    @Binding var order:Order
    @Binding var isPreseneted:Bool
    
    // --> UI
    @State private var msg:LocalizedStringKey?
    @State private var isSaving = false
    
    // --> VARS
    @State private var myUser = UserInformation.shared.getUser()
    @State private var store:Store?
    
    
    // --> Input Variables
    @State private var marketPlaceId = ""
    @State private var phone = ""
    @State private var name = ""
    @State private var otherPhone = ""

    @State private var gov = ""
    @State private var address = ""
    @State private var notes = ""
    @State private var clientShippingFees = 0.0
    @State private var discount = 0.0
    @State private var paid = false

    init(order: Binding<Order>, isPreseneted:Binding<Bool>) {
        _order = order
        _isPreseneted = isPreseneted
        updateUI()
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                if let store = store {
                    // MARK : Market Places
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(MarketsManager().getEnabledMarkets(storeMarkets: store.listMarkets ?? [])) { market in
                                MarketHeaderCard(marketId: market.id, turnedOff: marketPlaceId != market.id)
                                    .onTapGesture {
                                        withAnimation {
                                            marketPlaceId = market.id
                                        }
                                    }
                            }
                        }
                    }
                    
                    // MARK : Client Info
                    VStack(alignment: .leading) {
                        Text("Client info")
                            .font(.title2)
                            .bold()
                        
                        FloatingTextField(title: "Phone Number", text: $phone, required: true, keyboard: .phonePad)
                        FloatingTextField(title: "Full Name", text: $name, required: true, autoCapitalize: .words)
                        FloatingTextField(title: "Another Phone", text: $otherPhone, required: true, keyboard: .phonePad)
                        
                        Divider()
                    }
                    
                    // Shipping Info
                    if (order.requireDelivery ?? true) {
                        VStack(alignment: .leading) {
                            Text("Shipping info")
                                .font(.title2)
                                .bold()
                            
                            if let areas = store.listAreas?.uniqueElements() {
                                HStack {
                                    Text("Government")
                                    
                                    Spacer()
                                    
                                    Picker("Government", selection: $gov) {
                                        ForEach(areas, id: \.self) { area in
                                            Text(area.govName)
                                                .tag(area.govName)
                                        }
                                    }
                                }
                            }
                            
                            FloatingTextField(title: "Address", text: $address, required: true, multiLine: true, autoCapitalize: .sentences)
                            
                            Divider()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        FloatingTextField(title: "Notes", text: $notes, required: false, multiLine: true, autoCapitalize: .sentences)
                        
                        Divider()
                    }
                    
                    // MARK : Order Pricing
                    if order.canEditPrice() {
                        VStack(alignment: .leading) {
                            Text("Payment")
                                .font(.title2)
                                .bold()
                            
                            if (order.requireDelivery ?? true) {
                                FloatingTextField(title: "Shipping Fees", text: .constant(""), required: true, isNumric: true, number:$clientShippingFees)
                            }
                            
                            FloatingTextField(title: "Discount", text: .constant(""), required: false, isNumric: true, number: $discount)
                            
                            
                            Divider()
                        }
                    }
                    
                    
                    // MARK : Payment Option
                    if (store.canPrePaid ?? false) && order.canEditPrice() {
                        VStack(alignment: .leading) {
                            Text("Options")
                                .font(.title2)
                                .bold()
                            
                            
                            Toggle("Order prepaid", isOn: $paid)
                            
                            Divider()
                        }
                    }
                    
                    // MARK : Summery
                    VStack(alignment: .leading) {
                        Text("Summery")
                            .font(.title2)
                            .bold()
                        
                        HStack {
                            Text("Products prices")
                            Spacer()
                            Text("+\(order.totalPrice.toString()) LE")
                        }
                        
                        if (order.requireDelivery ?? true) {
                            HStack {
                                Text("Shipping Fees")
                                Spacer()
                                Text("+\(clientShippingFees.toString()) LE").foregroundColor(.yellow)
                                
                            }
                        }
                        
                        
                        HStack {
                            Text("Discount")
                            Spacer()
                            Text("-\(discount.toString()) LE").foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("COD")
                            Spacer()
                            Text("\((order.totalPrice + clientShippingFees - discount).toString()) LE").foregroundColor(.green)
                        }
                    }
                    .bold()
                }
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    Task {
                        await saveOrder()
                    }
                }
                .disabled(isSaving)
            }
        }
        .willProgress(saving: isSaving)
        .toast(isPresenting: Binding(value: $msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: msg?.toString())
        }
        .navigationBarBackButtonHidden(isSaving)
        .navigationTitle("Edit Order Info")
        .task {
            if let user = UserInformation.shared.getUser() {
                myUser = user
            }
            if let storeId = order.storeId {
                let store = try! await StoresDao().getStore(uId: storeId)
                DispatchQueue.main.async {
                    self.store = store
                }
            }
            
            DispatchQueue.main.async {
                updateUI()
            }
        }
    }
    
    func updateUI() {
        marketPlaceId = order.marketPlaceId ?? ""
        phone = order.phone
        name = order.name
        otherPhone = order.otherPhone ?? ""

        gov = order.gov
        address = order.address
        notes = order.notes ?? ""
        clientShippingFees = order.clientShippingFees
        discount = (order.discount ?? 0)
        paid = order.paid ?? false
    }
    
    func saveOrder() async {
        guard check() else {
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            let data:[String: Any] = [
                "name" : name,
                "phone": phone,
                "otherPhone": otherPhone,
                "address": address,
                "gov": gov,
                "paid":paid ,
                "marketPlaceId":marketPlaceId,
                "discount":discount,
                "notes":notes,
                "clientShippingFees":clientShippingFees,
            ]
            
            try await OrdersDao(storeId: order.storeId ?? "").update(id: order.id, hashMap: data)
            
            DispatchQueue.main.async {
                self.isSaving = false
                self.msg = "Order Updated"
                self.updateOrder()
                self.isPreseneted = false
            }
        } catch {
            msg = error.localizedDescription.localize()
        }
    }
    
    func updateOrder() {
        order.marketPlaceId = marketPlaceId
        order.phone = phone
        order.name = name
        order.otherPhone = otherPhone
        order.gov = gov
        order.address = address
        order.notes = notes
        order.clientShippingFees = clientShippingFees
        order.discount = Double(discount)
        order.paid = paid
    }
    
    func check() -> Bool {
        guard myUser != nil else {
            return false
        }
        
        if !phone.isPhoneNumber {
            msg = "Please enter the client phone"
            return false
        }
        
        if name.isBlank {
            msg = "Please enter the client name"
            return false
        }
        
        if gov.isBlank && (order.requireDelivery ?? true) {
            msg = "Please enter the client state"
            return false
        }
        
        if address.isBlank && (order.requireDelivery ?? true) {
            msg = "Please enter the client address"
            return false
        }
        return true
    }
}

#Preview {
    EditOrder(order : .constant(Order.example()), isPreseneted: .constant(true))
}
