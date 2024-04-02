//
//  CustomTopTapBar.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import SwiftUI


struct CustomTopTabBar: View {
    @Binding var tabIndex: Int
    var titles:[LocalizedStringKey]
    var body: some View {
        ScrollView(.horizontal ,showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(titles.indices, id: \.self) { index in
                    TabBarButton(text: titles[index], isLast: titles.count - 1 == index, isSelected: .constant(tabIndex == index))
                        .onTapGesture { onButtonTapped(index: index) }
                }
            }
        }
    }
    
    private func onButtonTapped(index: Int) {
        withAnimation(.interactiveSpring) {
            tabIndex = index
        }
    }
}

struct TabBarButton: View {
    let text: LocalizedStringKey
    let isLast:Bool
    @Binding var isSelected: Bool
    
    var body: some View {
        Text(text)
            .foregroundStyle(isSelected ? Color.accentColor : .black)
            .fontWeight(isSelected ? .heavy : .regular)
            .padding(.bottom,10)
            .border(width: isSelected ? 2 : 0, edges: [.bottom], color: .accentColor)
            .padding(.trailing, isLast ? 12 : 0)
    }
}

struct EdgeBorder: Shape {
    
    var width: CGFloat
    var edges: [Edge]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }
            
            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }
            
            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }
            
            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: SwiftUI.Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
#Preview {
    CustomTopTabBar(tabIndex: .constant(0), titles: ["First", "Second", "Third"])
}
