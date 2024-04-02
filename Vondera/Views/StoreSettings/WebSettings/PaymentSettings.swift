//
//  PaymentSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI

struct PaymentSettings: View {
    @StateObject var user = UserInformation.shared
    @State var cod = true
    
    var body: some View {
        List {
            Toggle("Cash on Delivery", isOn: $cod)
                .onChange(of: cod) { newValue in
                    updateCod(newValue)
                }
                .disabled(user.user?.store?.paymentOptions?.mustEnableCOD() ?? true)
            
            Section("Gateways") {
                NavigationLink {
                    VPaySettings()
                } label: {
                    HStack {
                        if (user.user?.store?.paymentOptions?.vPay?.selected ?? true) {
                            Label("VPay Gateway", systemImage: "checkmark")
                        } else {
                            Text("VPay Gateway")
                        }
                        
                        Spacer()
                        
                        Image(.mastercard)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Image(.visa)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                    
                }
                
                NavigationLink {
                    Paytab()
                } label: {
                    HStack {
                        if let selected = user.user?.store?.paymentOptions?.paytabs?.selected, selected == true {
                            Label("Paytabs Gateway", systemImage: "checkmark")
                        } else {
                            Text("Paytabs Gateway")
                        }
                        
                        Spacer()
                        
                        Image(.mastercard)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Image(.visa)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                }
                
                NavigationLink {
                    KashierSettings()
                } label: {
                    HStack{
                        if let selected = user.user?.store?.paymentOptions?.kashier?.selected, selected == true {
                            Label("Kashier Gateway", systemImage: "checkmark")
                        } else {
                            Text("Kashier Gateway")
                        }
                        
                        Spacer()
                        
                        Image(.wallet)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Image(.mastercard)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Image(.visa)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                }
                
                NavigationLink {
                    MyFatoorahSettings()
                } label: {
                    HStack{
                        if let selected = user.user?.store?.paymentOptions?.myFatoorah?.selected, selected == true {
                            Label("My Fatoorah Gateway", systemImage: "checkmark")
                        } else {
                            Text("My Fatoorah Gateway")
                        }
                        
                        Spacer()
                        
                        Image(.mastercard)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Image(.visa)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                }
                
                NavigationLink {
                    PaymobSettings()
                } label: {
                    HStack {
                        if let selected = user.user?.store?.paymentOptions?.paymob?.selected, selected == true {
                            Label("Paymob Gateway", systemImage: "checkmark")
                        } else {
                            Text("Paymob Gateway")
                        }
                        
                        Spacer()
                        
                        Image(.mastercard)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Image(.visa)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                }
            }
            .buttonStyle(.plain)
            
        }
        .navigationTitle("Payment Settings")
        .onAppear {
            refreshData()
        }
        .task {
            if let cashSelected = user.user?.store?.paymentOptions?.cash?.selected {
                cod = cashSelected
            }
        }
    }
    
    func refreshData() {
        Task {
            await UserInformation.shared.refetchUser()
        }
    }
    
    func updateCod(_ value:Bool) {
        let data = [
            "paymentOptions.cash.selected" : value,
            "paymentOptions.cash.gateway" : false
        ]
        
        if let storeId = user.user?.storeId {
            Task {
                try? await StoresDao().update(id:storeId, hashMap:data)
                DispatchQueue.main.async {
                    UserInformation.shared.user?.store?.paymentOptions?.cash?.selected = value
                    UserInformation.shared.updateUser()
                }
            }
        }
    }
}

#Preview {
    PaymentSettings()
}
