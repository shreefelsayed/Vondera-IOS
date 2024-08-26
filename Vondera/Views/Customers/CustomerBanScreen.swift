//
//  CustomerBanScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/03/2024.
//

import SwiftUI

struct CustomerBanScreen: View {
    var phone:String
    
    @State var isLoading = false
    @State var isBanned = false
    
    var body: some View {
        List {
            VStack {
                Toggle(isOn: $isBanned) {
                    Label {
                        Text("Customer banned ?")
                    } icon: {
                        Image(.btnBan)
                    }
                }
                .onChange(of: isBanned) { _ in
                    update()
                }
                
                Text("Banning a customer will notify you when you try to add an order with his info again, and auto delete orders made by his phone number or email from website")
                    .font(.caption)
            }
        }
        .willLoad(loading: isLoading)
        .navigationTitle("Ban customer")
        .task {
            await fetchData()
        }
    }
    
    private func update() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
                
        Task {
            do {
                try await ClientsDao(storeId: storeId).update(id: phone, hashMap: ["banned" : isBanned])
            } catch {
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            }
        }
    }
    
    private func fetchData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        if let result = try? await ClientsDao(storeId: storeId).getClient(phone: phone) {
            DispatchQueue.main.async {
                self.isBanned = result.banned ?? false
                self.isLoading = false
            }
        }
    }
}

#Preview {
    CustomerBanScreen(phone: "")
}
