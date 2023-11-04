//
//  ViewExt.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/06/2023.
//

import SwiftUI
import SwiftUIGenericDialog

extension UIImage {
    func compress(h:CGFloat = 1024, w:CGFloat = 1024) -> Data? {
        var compression: CGFloat = 1.0
        let maxSize: CGFloat = h * w // 1MB
        guard var imageData = self.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        while imageData.count > Int(maxSize) && compression > 0.1 {
            compression -= 0.1
            guard let newImageData = self.jpegData(compressionQuality: compression) else {
                return nil
            }
            imageData = newImageData
        }
        
        return imageData
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
    
    func circleImage(padding:CGFloat, redius:CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: redius, height: redius)
            .padding(padding)
            .clipShape(Circle())
        
    }
}


// Disable the view and show a progress dialog
extension View {
    func willProgress(saving: Bool, handleBackButton:Bool = true) -> some View {
        
        ZStack {
            if handleBackButton {
                self
                .navigationBarBackButtonHidden(saving)
            } else {
                self
            }
            
            if saving {
                NonDismiss()
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .disabled(saving)
    }
    
    func eraseToAnyView() -> AnyView {
           return AnyView(self)
    }
}

extension Array where Element: Equatable {
    func previousItem(of item: Element) -> Element? {
        guard let currentIndex = self.firstIndex(of: item),
              currentIndex > 0
        else {
            return nil
        }
        
        return self[currentIndex - 1]
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self
            .hidden()
        } else {
            self
        }
    }
}

extension ScrollView {
    func onScrolledToBottom(perform action: @escaping() -> Void) -> some View {
        return ScrollView<LazyVStack> {
            LazyVStack {
                self.content
                Rectangle().size(.zero).onAppear {
                    action()
                }
            }
        }
    }
}


extension View {
    func roundedTextFieldStyle() -> some View {
        self.modifier(FloatingLabelTextFieldStyle())
    }
}

struct FloatingLabelTextFieldStyle: ViewModifier {
    @State private var isEditing = false
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isEditing {
                content
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
            } else {
                content
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(isEditing ? .accentColor : .secondary)
        }
        .animation(.spring())
        .onTapGesture {
            withAnimation {
                isEditing = true
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorners(radius: radius, corners: corners) )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RoundedCorners: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension TextField {
    func clearButton(text: Binding<String>) -> some View {
        HStack {
            self
            if !text.wrappedValue.isEmpty {
                Button(action: {
                    text.wrappedValue = ""
                }) {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        self
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension SecureField {
    func withVisibilityToggle() -> some View {
        @State var isSecureTextEntry = true
        
        return HStack {
            if isSecureTextEntry {
                self
                    .textContentType(.password)
            } else {
                self
                    .textFieldStyle(PlainTextFieldStyle())
            }
            
            Button(action: {
                isSecureTextEntry.toggle()
            }) {
                Image(systemName: isSecureTextEntry ? "eye.slash" : "eye")
            }
        }
    }
}

