//
//  PaymentsOptions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import Foundation

struct PaymentsOptions : Codable {
    var paytabs:Paytabs? = Paytabs()
    var paymob:Paymob? = Paymob()
    var vPay:VPay? = VPay()
    var kashier:Kashier? = Kashier()
    var myFatoorah:MyFatoorah? = MyFatoorah()

    var cash:CashOnDelivery? = CashOnDelivery()
    
    func mustEnableCOD() -> Bool {
        var shouldEnable = true
        
        if let paytabs = paytabs {
            if (paytabs.connected ?? false) && (paytabs.selected ?? false) {
                shouldEnable = false
            }
        }
        
        if let paymob = paymob {
            if (paymob.connected ?? false) && (paymob.selected ?? false) {
                shouldEnable = false
            }
        }
        
        if let kashier = kashier {
            if (kashier.connected ?? false) && (kashier.selected ?? false) {
                shouldEnable = false
            }
        }
        
        if let myFatoorah = myFatoorah {
            if (myFatoorah.connected ?? false) && (myFatoorah.selected ?? false) {
                shouldEnable = false
            }
        }
        
        if let vPay = vPay {
            if (vPay.selected ?? true) {
                shouldEnable = false
            }
        } else {
            shouldEnable = false
        }
        
        return shouldEnable
    }
}
