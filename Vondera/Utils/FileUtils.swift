//
//  FileUtils.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation
import SwiftUI

class FileUtils {
    
    func shareFile(url:URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let window =  UIApplication.shared.keyWindowPresentedController {
                    window.present(activityViewController, animated: true, completion: nil)
                } else {
                    print("Couldn't view the share button")
                }
            }
            
        } else {
            print("Error: Unable to find the file to share")
        }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        
        return viewController
    }
    
}
