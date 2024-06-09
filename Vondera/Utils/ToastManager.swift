//
//  ToastManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/03/2024.
//

import Foundation
import SwiftUI

import Foundation
import AlertToast

enum types {
    case normal, error, success
}

class ToastManager: ObservableObject {
    @Published var isPresented = false
    @Published var msg:LocalizedStringKey?
    var toastType:AlertToast.AlertType = .regular
    
    static let shared = ToastManager()
    
    init(){}
    
    func showToast(msg:LocalizedStringKey, toastType:types = .normal) {
        DispatchQueue.main.async {
            var type = AlertToast.AlertType.regular
            if toastType == .error {
                type = AlertToast.AlertType.error(.red)
            } else if toastType == .success {
                type = .complete(.green)
            }
            self.toastType = type
            self.isPresented = true
            self.msg = msg
        }
    }
}
