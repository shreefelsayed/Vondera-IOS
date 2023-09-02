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
}

extension Date {
    func isSameDay(as otherDate: Date?) -> Bool {
        guard otherDate != nil else {
            return false
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let otherComponents = calendar.dateComponents([.year, .month, .day], from: otherDate!)
        
        return components.year == otherComponents.year &&
        components.month == otherComponents.month &&
        components.day == otherComponents.day
    }
    
    func isSameWeek(as otherDate: Date?) -> Bool {
        guard otherDate != nil else {
            return false
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let otherComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: otherDate!)
        
        return components.yearForWeekOfYear == otherComponents.yearForWeekOfYear &&
        components.weekOfYear == otherComponents.weekOfYear
    }
    
    func isSameMonth(as otherDate: Date?) -> Bool {
        guard otherDate != nil else {
            return false
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let otherComponents = calendar.dateComponents([.year, .month], from: otherDate!)
        
        return components.year == otherComponents.year &&
        components.month == otherComponents.month
    }
    
    func isSameYear(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        let otherComponents = calendar.dateComponents([.year], from: otherDate)
        
        return components.year == otherComponents.year
    }
    
    func timeAgoString() -> String {
            let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
            
            if let year = interval.year, year > 0 {
                return year == 1 ? "1 yr ago" : "\(year) yrs ago"
            } else if let month = interval.month, month > 0 {
                return month == 1 ? "1 month ago" : "\(month) months ago"
            } else if let day = interval.day, day > 0 {
                return day == 1 ? "1 day ago" : "\(day) days ago"
            } else if let hour = interval.hour, hour > 0 {
                return hour == 1 ? "1 hr ago" : "\(hour) hrs ago"
            } else if let minute = interval.minute, minute > 0 {
                return minute == 1 ? "1 min ago" : "\(minute) mins ago"
            } else if let second = interval.second, second > 0 {
                return second < 5 ? "Just now" : "\(second) seconds ago"
            } else {
                return "Just now"
            }
        }
}

// Disable the view and show a progress dialog
extension View {
    func willProgress(saving: Bool) -> some View {
        ZStack {
            self
            
            if saving {
                NonDismiss()
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .disabled(saving)
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

