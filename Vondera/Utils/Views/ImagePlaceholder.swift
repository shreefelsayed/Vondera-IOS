//
//  ImagePlaceholder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import SwiftUI

struct ImagePickupHolder: View {
    var currentImageURL:String?
    var selectedImage:UIImage?
    var currentImagePlaceHolder:UIImage?
    
    var reduis:CGFloat = 60
    var iconOverly:String? = "photo.fill.on.rectangle.fill"
    
    var body: some View {
        if let selectedImage = selectedImage {
            Image(uiImage: selectedImage)
                .centerCropped()
                .overlay(alignment: .center) {
                    if let iconOverly = iconOverly {
                        Image(systemName: iconOverly)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .opacity(0.4)
                    }
                }
                .background(Color.gray)
                .frame(width: reduis, height: reduis)
                .clipShape(Circle())
        } else {
            CachedImageView(imageUrl: currentImageURL ?? "", scaleType: .centerCrop, placeHolder: currentImagePlaceHolder)
            
            .overlay(alignment: .center) {
                if let iconOverly = iconOverly {
                    Image(systemName: iconOverly)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .opacity(0.4)
                }
            }
            .background(Color.gray)
            .frame(width: reduis, height: reduis)
            .clipShape(Circle())
        }
        
    }
}
struct ImagePlaceHolder: View {
    var url:String
    var placeHolder:UIImage?
    var reduis:CGFloat = 60
    var iconOverly:String?
    
    var body: some View {
        CachedImageView(imageUrl: url, scaleType: .centerCrop, placeHolder: placeHolder)
        .overlay(alignment: .center) {
            if let iconOverly = iconOverly {
                Image(systemName: iconOverly)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .opacity(0.4)
            }
        }
        .background(Color.gray)
        .frame(width: reduis, height: reduis)
        .clipShape(Circle())
        .id(url)
    }
}


