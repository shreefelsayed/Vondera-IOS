//
//  ChipView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import WrappingStack

struct Chip: View {
    let text: String
    let onDelete: (String) -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 16))
                .fontWeight(.bold)
            
            Button {
                onDelete(text)
            } label: {
                Image(systemName: "x.circle")
                    .foregroundColor(.black)
                    .frame(width: 16, height: 18)
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 12)
        .foregroundColor(.accentColor.opacity(0.5)))
    }
}

struct ChipView: View {
    private static let zwsp = "\u{200B}"
    
    @Binding var chips: [String]
    var placeholder: String
    let useSpaces: Bool
    
    @State private var inputText = zwsp
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $inputText)
                .onSubmit(of: .text) {
                    handleTextSubmit()
                }
                .onChange(of: inputText) { _ in
                    handleTextChange()
                }
            
            Spacer().frame(height: 2)
            
            WrappingHStack(id: \.self, alignment: .leading) { // use the same id is in the `ForEach` below
                ForEach(chips, id: \.self) { chip in
                    Chip(text: chip) { text in
                        chips.removeAll(where: { $0 == text })
                    }
                    .padding(.trailing)
                }
            }.padding(.top, 4)
        }
    }
    
    private func handleTextSubmit() {
        if inputText.hasPrefix(ChipView.zwsp) {
            chips.append(String(inputText[inputText.index(after: inputText.startIndex)...]))
        } else {
            chips.append(inputText)
        }
        
        inputText = ChipView.zwsp
    }
    
    private func handleTextChange() {
        if useSpaces && inputText.hasSuffix(" ") {
            chips.append(String(inputText[..<inputText.index(before: inputText.endIndex)]))
            inputText = ChipView.zwsp
        } else if !chips.isEmpty && inputText.isEmpty {
            let last = chips.removeLast()
            inputText = last
        }
    }
}
