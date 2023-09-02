//
//  ExpansesExt.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation

// MARK : Extenstions on lists
extension Array where Element == Expense {
    func total() -> Int {
        var amout = 0
        self.forEach { item in
            amout += item.amount
        }
        
        return amout
    }
}
