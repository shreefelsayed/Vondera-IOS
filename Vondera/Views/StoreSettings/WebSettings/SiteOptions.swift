//
//  SiteOptions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast

struct SiteOptions: View {
    
    @State var sendEmails = true
    @State var stocks = true
    @State var requireMails = true
    @State var showWhatsapp = true
    @State var lastPiece = true
    @State var askForAddress = true
    @State var productReviews = true

    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:LocalizedStringKey?
    @Environment(\.presentationMode) private var presentationMode
    
    
    var body: some View {
        List {
            Toggle("Enable Product Reviews", isOn: $productReviews)
            
            Toggle("Send email to customer", isOn: $sendEmails)
            
            Toggle("Customers can prepaid out of stock products", isOn: $stocks)
            
            Toggle("Require user to input email address", isOn: $requireMails)
            
            Toggle("Show whatsapp contact button", isOn: $showWhatsapp)
            
            Toggle("Last piece label on products", isOn: $lastPiece)

            Toggle("Require user to add his address at checkout", isOn: $askForAddress)

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(saving)
            }
        }
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .task {
            if let siteData = user.user?.store?.siteData {
                productReviews = siteData.reviewsEnabled ?? true
                sendEmails = siteData.sendEmailToCustomer ?? true
                stocks = siteData.prePaidProducts ?? true
                requireMails = siteData.requireEmail ?? true
                showWhatsapp = siteData.whatsappButton ?? true
                lastPiece = siteData.lastPiece ?? true
                askForAddress = siteData.askForAddress ?? true
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        }
        .navigationTitle("Site Options")
        
    }
    
    func update() {
        Task {
            if let id = UserInformation.shared.user?.storeId {
                saving = true
                
                let data = [
                    "siteData.sendEmailToCustomer" : sendEmails,
                    "siteData.prePaidProducts" : stocks,
                    "siteData.requireEmail" : requireMails,
                    "siteData.whatsappButton" : showWhatsapp,
                    "siteData.lastPiece" : lastPiece,
                    "siteData.askForAddress" : askForAddress,
                    "siteData.reviewsEnabled": productReviews
                ]
                
                if let _ = try? await StoresDao().update(id: id, hashMap: data) {
                    DispatchQueue.main.async { [self] in
                        UserInformation.shared.user?.store?.siteData?.sendEmailToCustomer = sendEmails
                        UserInformation.shared.user?.store?.siteData?.prePaidProducts = stocks
                        UserInformation.shared.user?.store?.siteData?.requireEmail = requireMails
                        UserInformation.shared.user?.store?.siteData?.whatsappButton = showWhatsapp
                        UserInformation.shared.user?.store?.siteData?.lastPiece = lastPiece
                        UserInformation.shared.user?.store?.siteData?.askForAddress = askForAddress
                        UserInformation.shared.updateUser()
                        presentationMode.wrappedValue.dismiss()
                        msg = "Updated"
                    }
                } else {
                    msg = "Error Happened"
                }
                
                saving = false
            }
            
        }
    }
}

#Preview {
    SiteOptions()
}
