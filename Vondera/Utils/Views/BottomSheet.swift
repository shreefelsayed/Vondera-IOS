import SwiftUI
import Combine

struct BottomSheet: View {
    @Binding var isShowing: Bool
    var content: AnyView

    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
                .compactMap { notification in
                    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return nil
                    }
                    return frame.height
                },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if isShowing {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                        isShowing.toggle()
                    }

                content
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : 42)
                    .transition(.move(edge: .bottom))
                    .background(Color.background)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .onReceive(keyboardHeightPublisher) { height in
                        withAnimation {
                            keyboardHeight = height
                        }
                        
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
