//
//  VPayScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/12/2023.
//

import SwiftUI

struct VPayScreen: View {
    @Environment(\.presentationMode) private var presentationMode

    @State var selectedTab = 0
    
    @State private var store:Store?
    @State private var showSheet = false
    @State private var isLoading = true
    @State private var vPayouts: VPayoutsScreen?
    @State private var vTransactions: VTrasnactionsScreen?
    
    
    var body: some View {
        VStack {
            if let store = store {
                CreditCardView(amount: Int(store.vPayWallet ?? 0), storeName: store.name) {
                    showSheet.toggle()
                }
                
                CustomTopTabBar(tabIndex: $selectedTab, titles: ["Transactions", "Payouts"])
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
                
                
                if selectedTab == 0 {
                    vTransactions
                } else {
                    vPayouts
                }
                
                Spacer()
            }
            
        }
        .isHidden(isLoading)
        .overlay(content: {
            if isLoading {
                ProgressView()
            }
        })
        .task {
            vPayouts = VPayoutsScreen(showSheet: $showSheet)
            vTransactions = VTrasnactionsScreen()
            await getData()
        }
        .sheet(isPresented: $showSheet) {
            PayoutRequest(isPresenting: $showSheet) {
                Task {
                    await getData()
                }
            }
        }
        .navigationTitle("VPay Wallet")
        .withAccessLevel(accessKey: .vPayRead, presentation: presentationMode)
    }
    
    func getData() async {
        isLoading = true
        if let storeId = UserInformation.shared.user?.storeId {
            if let store = try? await StoresDao().getStore(uId: storeId) {
                DispatchQueue.main.async {
                    self.store = store
                    self.isLoading = false
                }
            }
        }
    }
}

struct CreditCardView: View {
    var amount:Int = 120
    var storeName:String = "Qotoofs"
    var onClicked:(() -> ())?
    
    var body: some View {
        VStack {
            HStack {
                Image(.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                    .padding(.top, 10)
                    .foregroundColor(Color.white)
                
                Text("V Pay")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            
            Text("Current Balance")
                .foregroundColor(.white)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Spacer()
                Text("\(amount) EGP")
                    .foregroundColor(.white)
                    .font(.title)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.accentColor, Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                VStack {
                    Text("Card Holder")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(storeName)
                        .foregroundColor(.white)
                        .font(.caption)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let onClicked = onClicked {
                    Button("Payout") {
                        onClicked()
                    }
                    .buttonStyle(.borderedProminent)
                }
               
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.accentColor, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding()
    }
}

