//
//  ImagePlaceholder.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import SwiftUI
import NetworkImage

struct ImagePickupHolder: View {
    var currentImageURL:String?
    var selectedImage:UIImage?
    var currentImagePlaceHolder:UIImage?
    
    var reduis:CGFloat = 60
    var iconOverly:String? = "photo.fill.on.rectangle.fill"
    
    var body: some View {
        if selectedImage != nil {
            Image(uiImage: selectedImage)
                .centerCropped()
                .overlay(alignment: .center) {
                    Image(systemName: iconOverly)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .opacity(0.4)
                    
                }
                .background(Color.gray)
                .frame(width: reduis, height: reduis)
                .clipShape(Circle())
        } else {
            NetworkImage(url: URL(string: currentImageURL ?? "")) { image in
                image.centerCropped()
            } placeholder: {
                ProgressView()
            } fallback: {
                Image(uiImage: currentImagePlaceHolder)
                    .resizable()
            }
            .overlay(alignment: .center) {
                if iconOverly != nil {
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
        NetworkImage(url: URL(string: url )) { image in
            image.centerCropped()
        } placeholder: {
            Color.gray
        } fallback: {
            if placeHolder != nil {
                Image(uiImage: placeHolder)
                    .resizable()
            }
        }
        .overlay(alignment: .center) {
            if iconOverly != nil {
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


