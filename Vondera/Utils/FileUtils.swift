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
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        } else {
            print("Error: Unable to find the file to share")
        }
    }
}
