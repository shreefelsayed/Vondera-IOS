//
//  DownloadManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 04/07/2023.
//

import Foundation
import UIKit
import Photos

class DownloadManager {
    
    func saveImagesToDevice(imageURLs:[URL]) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadGroup = DispatchGroup()

        for imageURL in imageURLs {
            downloadGroup.enter()
            
            URLSession.shared.downloadTask(with: imageURL) { location, response, error in
                defer {
                    downloadGroup.leave()
                }
                
                guard let location = location else {
                    print("Download error for URL \(imageURL):", error ?? "")
                    return
                }
                
                do {
                    try FileManager.default.moveItem(at: location, to: documents.appendingPathComponent(response?.suggestedFilename ?? imageURL.lastPathComponent))
                    print("Image saved successfully:", imageURL.lastPathComponent)
                } catch {
                    print("Error saving image:", error)
                }
            }.resume()
        }

        downloadGroup.notify(queue: .main) {
            print("All images downloaded and saved.")
        }

    }
}
