//
//  PullToRefresh.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import SwiftUI

struct PullToRefreshScrollView<Content>: View where Content: View {
    @Binding var isRefreshing: Bool
    var onBottomReached: (() -> ())
    
    private var showsIndicators: Bool
    let content: () -> Content
    
    @State private var contentOffset: CGFloat = 0
    
    init(
        isRefreshing: Binding<Bool>,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> Void
    ) {
        self._isRefreshing = isRefreshing
        self.showsIndicators = showsIndicators
        self.content = content
        self.onBottomReached = action
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: showsIndicators) {
                PullToRefresh(
                    isRefreshing: $isRefreshing,
                    coordinateSpaceName: "pullToRefresh",
                    onScrollChange: {
                        if isRefreshing {
                            contentOffset = 50
                        } else {
                            contentOffset = $0
                        }
                        
                        // Check if reached bottom
                        if $0 > getContentHeight() - UIScreen.main.bounds.height {
                            // Perform action for reaching the bottom
                            onBottomReached()
                        }
                    }
                ).onChange(of: isRefreshing, perform: {
                    if !$0 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            contentOffset = 0
                        }
                    } else {
                        withAnimation(.easeOut(duration: 0.3)) {
                            contentOffset = 50
                        }
                    }
                })
                
                content().offset(y: contentOffset)
            }
            .coordinateSpace(name: "pullToRefresh")
        }
    }
    
    private func getContentHeight() -> CGFloat {
        let frame = UIApplication.shared.windows.first?.rootViewController?.view.bounds
        let scrollViewFrame = frame?.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        return scrollViewFrame?.height ?? 0
    }
}



struct PullToRefresh: View {
    
    private static let PULL_OFFSET: CGFloat = 70
    private static let REFRESH_OFFSET: CGFloat = 30
    
    @Binding var isRefreshing: Bool
    var coordinateSpaceName: String
    var onScrollChange: (CGFloat) -> Void
    
    @State private var needRefresh: Bool = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center) {
                ZStack {
                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
                    } else {
                        HStack {
                            if !needRefresh {
                                Text("Pull to refresh")
                                    .foregroundColor(Color.primary)
                            } else {
                                Text("Release to refresh")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                }
                .frame(height: 50)
                .opacity(isRefreshing ? 1 : fraction(minBound: 0, maxBound: 25, value: max(0, scrollOffset)))
                .offset(y: -scrollOffset)
            }
            .frame(maxWidth: .infinity)
            .onChange(of: scroll(geo).minY, perform: {
                scrollOffset = max($0, 0)
            })
            .onChange(of: scrollOffset, perform: {
                let offset = $0
                onScrollChange(offset)
                if !needRefresh && offset > PullToRefresh.PULL_OFFSET {
                    needRefresh = true
                    return
                }
                
                if needRefresh && offset < PullToRefresh.REFRESH_OFFSET {
                    needRefresh = false
                    isRefreshing = true
                }
            })
        }
    }
    
    func scroll(_ geometryProxy: GeometryProxy) -> CGRect {
        return geometryProxy.frame(in: .named(coordinateSpaceName))
    }
    
    func fraction(minBound: CGFloat, maxBound: CGFloat, value: CGFloat) -> CGFloat {
        return min(max((value - minBound) / (maxBound - minBound), 0), 1)
    }
}

struct PullToRefreshOld: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 78) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("⬇️")
                }
                Spacer()
            }
        }.padding(.top, -70)
    }
}
