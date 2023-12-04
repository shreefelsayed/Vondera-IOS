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
        
        return shouldEnable
    }
}
