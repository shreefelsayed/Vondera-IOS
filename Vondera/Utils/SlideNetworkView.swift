//
//  ImageSliderView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI
import NetworkImage

struct SlideNetworkView: View {
    @State  var currentIndex: Int = 0
    var imageUrls: [String] = [
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg",
        "https://example.com/image3.jpg"
    ]

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
                NetworkImage(url: URL(string: imageUrls[index])) { image in
                    image.centerCropped()

                } placeholder: {
                    Color.gray
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } fallback: {
                    Color.gray
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color.gray)
                .tag(index)
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
        if pageCount < 2 {
            EmptyView()
        } else {
            HStack(spacing: 4) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(currentIndex == index ? .blue : .gray)
                }
            }
        }
        
    }
}

