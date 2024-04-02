//
//  Copying.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import UIKit


class CopyingData {
    func copyToClipboard(_ list: [String]) {
        var text = ""
        for item in list {
            text = text + item + "\n"
        }
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
        
        ToastManager.shared.showToast(msg: text.localize(), toastType: . normal)
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
        
        ToastManager.shared.showToast(msg: text.localize(), toastType: . normal)
    }
}
