//
//  ImageSliderView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI
import NetworkImage

struct SlideNetworkView: View {
    @State private var currentIndex: Int = 0
    var imageUrls = [String]()
    var autoChange = false
    
    @State private var timerPaused = false
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
        
    var body: some View {
        ZStack(alignment: .bottom) {
            SliderView(currentIndex: $currentIndex, imageUrls: imageUrls)
                .onReceive(timer) { _ in
                    if autoChange && imageUrls.count > 1 && !timerPaused {
                        withAnimation {
                            currentIndex = (currentIndex + 1) % imageUrls.count
                        }
                    }
                }
            PageIndicatorView(currentIndex: $currentIndex, pageCount: imageUrls.count)
                .padding(.bottom, 8)
        }
        .onAppear {
            timerPaused = false
        }
        .onDisappear {
            timerPaused = true
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

