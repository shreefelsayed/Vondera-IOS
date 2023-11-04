//
//  PaymentsOptions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import Foundation

struct PaymentsOptions : Codable {
    var paytabs:Paytabs? = Paytabs()
    var cash:CashOnDelivery? = CashOnDelivery()
    
    func mustEnableCOD() -> Bool {
        if let paytabs = paytabs {
            if (paytabs.connected ?? false) && (paytabs.selected ?? false) {
                return false
            }
        }
        
        return true
    }
}
