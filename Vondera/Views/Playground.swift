
import Foundation
import UIKit
import PlaygroundSupport

import SwiftUI

struct CustomTextView: UIViewRepresentable {
    @Binding var selectedText: String?

    let text: String
    let customMenuItems: [UIMenuItem]

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.delegate = context.coordinator
        textView.text = text
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView

        init(parent: CustomTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            let selectedRange = textView.selectedRange
            if selectedRange.length > 0 {
                let start = textView.position(from: textView.beginningOfDocument, offset: selectedRange.location)!
                let end = textView.position(from: start, offset: selectedRange.length)!
                let range = textView.textRange(from: start, to: end)
                let selectedText = textView.text(in: range!)
                parent.selectedText = selectedText
            } else {
                parent.selectedText = nil
            }
        }

        // Implement your custom menu handling here if needed
    }
}

struct PlaygroundView: View {
    @State private var selectedText: String?

    var body: some View {
        CustomTextView(selectedText: $selectedText,
                       text: "This is a long text. Select some text to see the custom menu.",
                       customMenuItems: [
                           //UIMenuItem(title: "Custom Action", action: #selector(customAction))
                       ])
            .contextMenu {
                Button("Copy") {
                    if let selectedText = selectedText {
                        UIPasteboard.general.string = selectedText
                    }
                }
            }
    }


}

#Preview {
    PlaygroundView(selectedText: nil)
}
