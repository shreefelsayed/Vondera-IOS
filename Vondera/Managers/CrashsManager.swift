//
//  CrashsManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/04/2024.
//

import Foundation
import FirebaseCrashlytics

class CrashsManager {
    func addLogs(_ message:String, _ screen:String) {
        Crashlytics.crashlytics().log("Error : \(message) at : \(screen)")
    }
}
