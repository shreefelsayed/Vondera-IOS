import Foundation
import SwiftUI
struct TextLabelWithHyperlink: UIViewRepresentable {
    @State var tintColor: UIColor = UIColor.black
    @State var arrTapableString: [String] = []
    @State var selectedRange: NSRange?

    var configuration = { (view: UITextView) in }
    var openlink = { (strtext: String) in }
    var onTextSelectionChanged: ((String?, CGPoint?, NSRange?) -> Void)

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.tintColor = self.tintColor
        textView.delegate = context.coordinator
        //context.coordinator.uiView = textView

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        configuration(uiView)
        let stringarr = NSMutableAttributedString(attributedString: uiView.attributedText)
        for strlink in arrTapableString {
            let link = strlink.replacingOccurrences(of: " ", with: "_")
            stringarr.addAttribute(.link, value: String(format: "https://%@", link), range: (stringarr.string as NSString).range(of: strlink))
        }
        uiView.attributedText = stringarr

        // Keep the selection
        if let restoredRange = self.selectedRange {
            uiView.selectedRange = restoredRange

            // Show custom context menu
            if let selectedText = uiView.text(in: uiView.selectedTextRange!) {
                //showContextMenu(text: selectedText, point: uiView.caretRect(for: uiView.selectedTextRange!.start).origin)
            }
        }
    }


    func copyAction() {
        // Handle copy action here
        print("Copy action")
        UIMenuController.shared.hideMenu()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate, UIEditMenuInteractionDelegate {
        var parent: TextLabelWithHyperlink

        init(parent: TextLabelWithHyperlink) {
            self.parent = parent
        }

        func editMenuInteraction(_ interaction: UIEditMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            // Implement menu configuration
            return nil
        }

        func editMenuInteractionDidEnd(_ interaction: UIEditMenuInteraction) {
            // Implement menu dismissal
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let range = textView.selectedTextRange else { return }
            let startOffset = textView.offset(from: textView.beginningOfDocument, to: range.start)
            let endOffset = textView.offset(from: textView.beginningOfDocument, to: range.end)
            let selectedRange = NSRange(location: startOffset, length: endOffset - startOffset)
            self.parent.selectedRange = selectedRange
            let startRect = textView.caretRect(for: range.start)
            let centerX = startRect.midX
            let centerY = startRect.midY
            let startPoint = CGPoint(x: centerX, y: centerY)
            let convertedPoint = textView.convert(startPoint, to: textView.superview)
            self.parent.onTextSelectionChanged(textView.text, convertedPoint, self.parent.selectedRange)
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            let strPlain = URL.absoluteString.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "_", with: " ")

            if (self.parent.arrTapableString.contains(strPlain)) {
                self.parent.openlink(strPlain)
            }

            return false
        }
    }
}


struct HighlightedTextView: View {
    let paragraph: String
    let highlightedWords: [String]
    @Binding var speakedWordRange: NSRange?
    @State private var selectedRange: NSRange?
    let onWordTapped: ((String) -> ())
    let onWordsSelected: ((String?, CGPoint?) -> ())
    
    
    var body: some View {
        let words = paragraph.components(separatedBy: .whitespacesAndNewlines)
        
        let attributedText = NSMutableAttributedString(string: paragraph)
        
        for word in highlightedWords {
            let range = (paragraph as NSString).range(of: word)
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributedText.addAttribute(.foregroundColor, value: UIColor.green, range: range)
            attributedText.addAttribute(.underlineColor, value: UIColor.green, range: range)
        }
        
        if let selectedRange = speakedWordRange {
            attributedText.addAttribute(.foregroundColor, value: UIColor.orange, range: selectedRange)
        }
        
        return TextLabelWithHyperlink(arrTapableString: highlightedWords) { view in
            view.attributedText = attributedText
        } openlink: { strtext in
            onWordTapped(strtext)
        } onTextSelectionChanged: { selectedText, point, restoredRange in
            if restoredRange != nil {
                self.selectedRange = restoredRange
            }
        }
        .multilineTextAlignment(.leading)
        .eraseToAnyView()
    }
}


struct PlaygroundView: View {
    @State private var speakedWordRange: NSRange? // This is the index range of the current word in the audio
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isContextMenuVisible = false
    @State private var selectionText:String?
    @State private var selectionPoint: CGPoint? = .zero
    
    var paragraph =  "This is a sample text for highlighting in SwiftUI" // This is the pragraph it self
    var body: some View {
        HighlightedTextView(paragraph: paragraph, highlightedWords: ["sample", "highlighting"], speakedWordRange: $speakedWordRange, onWordTapped: { word in
            print("You tapped \(word)")
        }, onWordsSelected: { (sentence, point) in
            
        })
        .onReceive(timer) { _ in
            if var range = self.speakedWordRange {
                if range.location < self.paragraph.count - 1 {
                    range.location += 1
                } else {
                    range.location = 0
                }
                self.speakedWordRange = range
            } else {
                self.speakedWordRange = NSRange(location: 0, length: 1)
            }
        }
        .padding()
    }
    
    struct CustomContextMenu: View {
        @Binding var isPresented:Bool
        var text:String?
        
        var body: some View {
            HStack {
                ForEach(0..<7) { index in
                    Button(action: {
                        // TODO : Handle actions here
                        print("Icon \(index) tapped!")
                        isPresented = false
                    }) {
                        Image(systemName: "star")
                    }
                    .foregroundColor(.white)
                    .font(.caption)
                }
            }
            .padding(4)
            .background(Color.gray)
            .cornerRadius(4)
            .padding(4)
        }
    }
}


#Preview {
    PlaygroundView()
}

extension NSRange {
    init(startIndex: Int, endIndex: Int) {
        self.init(location: startIndex, length: endIndex - startIndex)
    }
}

extension Text {
    init(_ astring: NSAttributedString) {
        self.init("")
        
        astring.enumerateAttributes(in: NSRange(location: 0, length: astring.length), options: []) { (attrs, range, _) in
            var t = Text(astring.attributedSubstring(from: range).string)
            
            if let color = attrs[NSAttributedString.Key.foregroundColor] as? UIColor {
                t  = t.foregroundColor(Color(color))
            }
            
            if let font = attrs[NSAttributedString.Key.font] as? UIFont {
                t  = t.font(.init(font))
            }
            
            if let underlineStyle = attrs[NSAttributedString.Key.underlineStyle] as? Int {
                t = t.underline(underlineStyle == NSUnderlineStyle.single.rawValue, color: Color.black)
            }
            
            self = self + t
        }
    }
}

extension String {
    func lineRange(for range: NSRange) -> NSRange? {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: NSMutableAttributedString(string: self))
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: 0, effectiveRange: nil)
        return NSRange(location: layoutManager.glyphIndex(for: lineFragmentRect.origin, in: textContainer), length: layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil).length)
    }
}
