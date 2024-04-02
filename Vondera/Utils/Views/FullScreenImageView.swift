//
//  FullScreenImageView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI

struct FullScreenImageView: View {
    let imageURLs: [String]
    @State var currentIndex = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            NetworkImageView(currentIndex: $currentIndex, imageUrls: imageURLs)
            PageIndicatorView(currentIndex: $currentIndex, pageCount: imageURLs.count)
                .padding(.top, 8)
        }
    }
}

struct NetworkImageView: View {
    @Binding var currentIndex: Int
    let imageUrls: [String]
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<imageUrls.count, id: \.self) { index in
                GeometryReader { geometry in
                    ScrollView(.init()) {
                        VStack {
                            CachedImageView(imageUrl: imageUrls[index], scaleType: .scaleFit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { scaleValue in
                                            scale = scaleValue.magnitude
                                        }
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { dragValue in
                                            offset.width = dragValue.translation.width
                                            offset.height = dragValue.translation.height
                                        }
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id(imageUrls[index])
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            currentIndex = 0
        }
        .edgesIgnoringSafeArea(.all)
    }
}

