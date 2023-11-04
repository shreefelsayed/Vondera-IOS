//
//  AgelWallet.swift
//  Vondera
//
//  Created by Shreif El Sayed on 04/10/2023.
//

import SwiftUI

struct AgelWallet: View {
    var myUser = UserInformation.shared.user
    
    let min = 10000
    let max = 150000
    let agel = "https://www.agel.io"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // MARK : Wallet Card
                VStack(alignment: .center) {
                    Image("agel")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    
                    Text("Available Balance")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.bottom, 24)
                    
                    Text("EGP \(myUser?.store?.agelWallet ?? 0)")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.5))
                .cornerRadius(30)
                
                //MARK : Button
                ButtonLarge(label: "Withdraw from Agel", background: (myUser?.store?.agelWallet ?? 0) >= min ? Color.accentColor : Color.gray) {
                    // Open Agel Link
                    if let url = URL(string: agel) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                .disabled((myUser?.store?.agelWallet ?? 0) < min)
                
                if (myUser?.store?.agelWallet ?? 0) < min {
                    Text("You need at least 10,000 LE in your wallet to withdraw fund")
                        .foregroundStyle(.red)
                }
               
                
                Text("After the partnership between Vondera and Agel Company, you can purchase goods from any supplier you choose and pay through the Agel Cash wallet. You can also finance the price of the goods for Agel Company for a small fee of 1.5% of the invoice amount. Your Agal wallet balance depends on your sales volume.")
                    .font(.caption)
                    .padding(.top, 12)
            }
            
        }
        .padding()
        .navigationTitle("Agel Wallet")
    }
}

#Preview {
    NavigationView {
        AgelWallet(myUser: UserData.example())
    }
}
