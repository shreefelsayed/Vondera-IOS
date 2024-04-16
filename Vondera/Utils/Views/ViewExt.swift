//
//  ViewExt.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/06/2023.
//

import SwiftUI
import SwiftUIGenericDialog

let defaultEmployeeImage = UIImage(resource: .defaultPhoto)
let defaultCategoryImage = UIImage(resource: .defaultCategory)
let defaultCourier = UIImage(resource: .defaultCourier)
let defaultStoreImage = UIImage(resource: .appIcon)

extension UIImage {
    func compress(h:CGFloat = 1024, w:CGFloat = 1024) -> Data? {
        var compression: CGFloat = 1.0
        let maxSize: CGFloat = h * w
        
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
    
    func compress(image: UIImage, maxByte: Int = 550000, completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else {
                return completion(nil)
            }
            
            var iterationImage: UIImage? = image
            var iterationImageSize = currentImageSize
            var iterationCompression: CGFloat = 1.0
            
            while iterationImageSize > maxByte && iterationCompression > 0.01 {
                let percentageDecrease = self.getPercentageToDecreaseTo(forDataCount: iterationImageSize)
                
                let canvasSize = CGSize(width: image.size.width * iterationCompression,
                                        height: image.size.height * iterationCompression)
                UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
                defer { UIGraphicsEndImageContext() }
                image.draw(in: CGRect(origin: .zero, size: canvasSize))
                iterationImage = UIGraphicsGetImageFromCurrentImageContext()
                
                guard let newImageSize = iterationImage?.jpegData(compressionQuality: 1.0)?.count else {
                    return completion(nil)
                }
                iterationImageSize = newImageSize
                iterationCompression -= percentageDecrease
            }
            completion(iterationImage)
        }
    }
    func getPercentageToDecreaseTo(forDataCount dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0..<5000000: return 0.03
        case 5000000..<10000000: return 0.1
        default: return 0.2
        }
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
    func navigationCardView<Destination: View>(destination: Destination) -> some View {
        self
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .background(
                NavigationLink("", destination: destination)
            )
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
    
    func cardView(padding:Int = 12) -> some View {
        self
            .padding(EdgeInsets(top: CGFloat(padding), leading: CGFloat(padding), bottom: CGFloat(padding), trailing: CGFloat(padding)))
            .background(Color.white)
            .cornerRadius(12)
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
    
    /// Show this while the user is saving something
    func willProgress(saving: Bool, handleBackButton:Bool = true, msg:String = "Loading ...") -> some View {
        ZStack {
            self
                .navigationBarBackButtonHidden(handleBackButton && saving)
                .blur(radius: saving ? 2 : 0)
            
            if saving {
                ZStack {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.trailing, 12)
                        
                        Text(msg)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                }
                
                .ignoresSafeArea()
            }
        }
        .disabled(saving)
    }
    
    /// Show this will user is loading content to the screen
    func willLoad(loading:Bool) -> some View {
        ZStack {
            self
            
            if loading {
                ZStack {
                    Color.background
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.trailing, 12)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                .ignoresSafeArea()
            }
        }
        .disabled(loading)
    }
    
    /// Empty message view that switches between a message view and search text
    func withEmptySearchView(searchText:String, resultCount:Int) -> some View {
        self
            .overlay {
                if !searchText.isBlank && resultCount == 0 {
                    SearchEmptyView(searchText: searchText)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .ignoresSafeArea()
                        .background(Color.background)
                }
            }
    }
    
    func withPaywall(accessKey:FeatureKeys, presentation:Binding<PresentationMode>) -> some View {
        return self
            .fullScreenCover(isPresented: .constant(!accessKey.canAccess())) {
                VStack(spacing: 24) {
                    // Close Button
                    HStack {
                        Spacer()
                        
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.gray)
                            .clipShape(Circle())
                            .onTapGesture {
                                presentation.wrappedValue.dismiss()
                            }
                    }
                    
                    Spacer()
                    // IMAGE
                    Image(accessKey.getDrawable())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(46)
                        
                    Spacer()
                    
                    // Title
                    Text(accessKey.getTitle())
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                    
                    
                    Text(accessKey.getDesc())
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button {
                        DynamicNavigation.shared.navigate(to: AnyView(AppPlans()))
                    } label: {
                        Text("Upgrade your plan")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                        .padding()
                        .background(.white)
                        .cornerRadius(32)
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.black.ignoresSafeArea())
            }
    }
    
    /// Empty view with a button
    func withEmptyViewButton(image: ImageResource? = nil, text: LocalizedStringKey, buttonText: LocalizedStringKey, count: Int, loading: Bool, onAction: @escaping () -> ()) -> some View {
        self.overlay {
            if !loading && count == 0 {
                EmptyMessageResourceWithButton(imageResource: image, msg: text) {
                    Button(action: {
                        onAction()
                    }) {
                        Text(buttonText)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                .background(Color.background)
            }
        }
    }
    
    /// This will display an empty message over the page
    func withEmptyView(image:ImageResource? = nil, text:LocalizedStringKey, count:Int, loading:Bool) -> some View {
        self
            .overlay {
                if !loading && count == 0 {
                    EmptyMessageWithResource(imageResource: image, msg: text)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .ignoresSafeArea()
                        .background(Color.background)
                }
            }
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

