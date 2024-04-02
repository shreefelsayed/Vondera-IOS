//
//  SkeltonManager.swift
//  examateapp
//
//  Created by Shreif El Sayed on 17/03/2024.
//

import SwiftUI

struct SkeltonManager: View {
    var isLoading: Bool = true
    let count: Int // Count of the skeletons object
    let skeltonView: any View
    var body: some View {
        if isLoading {
            ForEach((0..<count), id: \.self) { index in
                skeltonView.eraseToAnyView()
            }
            .padding(.vertical, 16)
        } else {
            EmptyView()
        }
    }
}


struct SkeletonCellView: View {
    var isDarkColor:Bool = true
    var duration:Double = 0.75
    private let primaryColor = Color(.init(gray: 0.9, alpha: 1.0))
    private let secondaryColor  = Color(.init(gray: 0.8, alpha: 1.0))
    
    var body: some View {
        Rectangle()
            .fill(isDarkColor ? secondaryColor : primaryColor)
            .blinking(duration: duration)
    }
}

struct BlinkViewModifier: ViewModifier {
    let duration: Double
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0.3 : 1)
            .animation(.easeInOut(duration: duration).repeatForever(), value: blinking)
            .onAppear {
                // Animation will only start when blinking value changes
                blinking.toggle()
            }
    }
}

extension View {
    func blinking(duration: Double = 1) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}

#Preview {
    VStack {
        SkeltonManager(isLoading: true, count: 8, skeltonView: OrderCardSkelton())
    }
    .padding()
    .background(Color.background)
    
}
