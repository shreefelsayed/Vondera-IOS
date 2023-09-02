//
//  ContactDialog.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI

struct ContactDialog: View {
    var phone:String
    var message = ""
    @Binding var toggle:Bool
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose your contact method")
                    .font(.title)
                    .bold()
                
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "phone.arrow.up.right.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Phone Call")
                    
                    Spacer()
                }
                .onTapGesture {
                    Contact().makePhoneCall(phoneNumber: phone)
                    toggle.toggle()
                }
                
                Divider()
                
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "message.badge.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Send SMS")
                    
                    Spacer()
                }
                .onTapGesture {
                    Contact().openMessagesApp(phoneNumber: phone, message: message)
                    toggle.toggle()
                }
                
                Divider()
                
                HStack(alignment: .center, spacing: 8) {
                    Image("whatsapp")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Send Whatsapp Message")
                    
                    Spacer()
                }
                .onTapGesture {
                    Contact().openWhatsApp(phoneNumber: phone, message: message)
                    toggle.toggle()
                }
                
                Divider()
                
                HStack(alignment: .center, spacing: 8) {
                    Image("telegram")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Send Telegram Message")
                    
                    Spacer()
                }.onTapGesture {
                    Contact().openTelegramApp(phone: phone)
                    toggle.toggle()
                }
            }
        }
        .padding(.vertical, 26)
        .padding(.horizontal, 16)
    }
}

