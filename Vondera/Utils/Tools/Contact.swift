//
//  Contact.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import Foundation
import UIKit

class Contact {
    func openTelegramApp(phone: String) {
        let usernameEncoded = phone.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let url = URL(string: "tg://resolve?domain=\(usernameEncoded)")
        
        if let telegramURL = url, UIApplication.shared.canOpenURL(telegramURL) {
            UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        } else {
            // Telegram app is not available or URL is invalid
            // Handle the error or show an alert to the user
        }
    }
    


    
    func openWhatsApp(phoneNumber: String, message: String) -> Bool {
        let urlWhats = "whatsapp://send?phone=+2\(phoneNumber)&text=\(message)"
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        UIApplication.shared.openURL(whatsappURL)
                        return true
                    } else {
                       return false
                    }
                }
            }
        
        return false
    }
    
    func makePhoneCall(phoneNumber: String) {
        print("Making phone call to \(phoneNumber)")
        if let phoneURL = URL(string: "tel:\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            // Handle the error or show an alert to the user
        }
    }
    
    
    func openMessagesApp(phoneNumber: String, message: String) {
        let phoneNumberWithCountryCode = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let messageEncoded = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let url = URL(string: "sms:\(phoneNumberWithCountryCode)&body=\(messageEncoded)")
        
        if let messagesURL = url, UIApplication.shared.canOpenURL(messagesURL) {
            UIApplication.shared.open(messagesURL, options: [:], completionHandler: nil)
        } else {
            // Messages app is not available or URL is invalid
            // Handle the error or show an alert to the user
        }
    }
}
