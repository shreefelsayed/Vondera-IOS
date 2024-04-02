//
//  CachedImageView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/03/2024.
//

import Foundation

import SwiftUI

enum ScaleType {
    case centerCrop, scaleFill, scaleFit
}

struct CachcedCircleView: View {
    let imageUrl: String
    var scaleType:ScaleType = .centerCrop
    var placeHolder:UIImage? = nil
    
    var body: some View {
        CachedImageView(imageUrl: imageUrl, scaleType: scaleType, placeHolder: placeHolder)
            .clipShape(Circle())
            .background(
                Circle()
                    .stroke(Color.accentColor, lineWidth: 1)
            )
            
    }
}

struct CachedImageView: View {
    let imageUrl: String
    var scaleType:ScaleType = .centerCrop
    var placeHolder:UIImage? = nil
    
    @State private var isLoading = true
    @State private var image: UIImage? = nil
    
    var body: some View {
        if let image = image {
            if scaleType == .centerCrop {
                Image(uiImage: image)
                    .centerCropped()
                    .id(imageUrl)
                    
                    
            } else if scaleType == .scaleFit {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .id(imageUrl)
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .id(imageUrl)
            }
        } else if isLoading {
            Color.gray
                .onAppear {
                    loadImage()
                }
        } else {
            if let placeHolder = placeHolder {
                Image(uiImage: placeHolder)
                    .resizable()
                    .id(UUID().uuidString)
            } else {
                Color.gray
            }
        }
    }
    
    private func loadImage() {
        // Check cache first
        self.isLoading = true
        guard let url = URL(string: imageUrl) else {
            self.isLoading = false
            return
        }
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let cachedImage = UIImage(data: cachedResponse.data) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Image not found in cache, download from server
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                // Cache the downloaded image
                let cachedData = CachedURLResponse(response: response!, data: data)
                URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: url))
                
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
            
            self.isLoading = false
        }.resume()
    }
}
