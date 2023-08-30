//
//  DateExtenstions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestore


extension Date {
    func toFirestoreTimestamp() -> Timestamp {
        return Timestamp(date: self)
    }
}

extension Timestamp {
    func toDate() -> Date {
        return self.dateValue()
    }
}
