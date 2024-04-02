//
//  ImageSliderView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI

struct SlideNetworkView: View {
    @State private var currentIndex: Int = 0
    var imageUrls = [String]()
    var autoChange = false
            
    var body: some View {
        ZStack(alignment: .bottom) {
            SliderView(currentIndex: $currentIndex, imageUrls: imageUrls)
            PageIndicatorView(currentIndex: $currentIndex, pageCount: imageUrls.count)
                .padding(.bottom, 8)
        }
    }
}


struct SliderView: View {
    @Binding var currentIndex: Int
    let imageUrls: [String]
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<imageUrls.count, id: \.self) { index in
                CachedImageView(imageUrl: imageUrls[index], scaleType: .centerCrop)
                .id(imageUrls[currentIndex])
                
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            currentIndex = 0
        }
    }
}

struct PageIndicatorView: View {
    @Binding var currentIndex: Int
    let pageCount: Int
    
    var body: some View {
        if pageCount < 1 {
            EmptyView()
        } else {
            HStack(spacing: 4) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(currentIndex == index ? .accentColor : .gray)
                        .onTapGesture {
                            withAnimation {
                                currentIndex = index
                            }
                        }
                }
            }
        }
        
    }
}

