//
//  StringExtenstions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestore

extension Timestamp {
    func toString(format: String = "yyyy MMMM, dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: dateValue())
    }
}

extension String {
    var isValidEmail: Bool {
        // Regular expression pattern to match the email format
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            
        // Create a predicate with the email regex pattern
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            
        // Evaluate the predicate for the current string
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPassword:Bool {
        return self.count >= 6
    }
    
    var isNumeric: Bool {
        let numericSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: self)
        return numericSet.isSuperset(of: characterSet)
    }
    
    var isPhoneNumber: Bool {
        let requiredLength = 11
        let prefix = "01"
                
        guard count == requiredLength else {
            return false
        }
        
        guard self.isNumeric else {
            return false
        }
                
        return hasPrefix(prefix)
    }
    
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func capitalizeFirstLetter() -> String {
            guard let firstLetter = self.first else {
                return self
            }
            
            let restOfString = String(self.dropFirst())
            return String(firstLetter).uppercased() + restOfString.lowercased()
        }
    
    func containsNoNumbers() -> Bool {
        let numberCharacterSet = CharacterSet.decimalDigits
        return self.rangeOfCharacter(from: numberCharacterSet) == nil
    }
}
