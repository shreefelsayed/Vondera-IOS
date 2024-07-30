//
//  Cursor.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2024.
//

import Foundation
import SwiftUI
import Combine

class CursorPosition: ObservableObject {
    @Published var position: Int?
}

struct CursorTrackingTextView: UIViewRepresentable {
    @Binding var text: String
    @ObservedObject var cursorPosition: CursorPosition

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CursorTrackingTextView

        init(parent: CursorTrackingTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            if let selectedRange = textView.selectedTextRange {
                let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                parent.cursorPosition.position = cursorPosition
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
