//
//  FloatingTextField.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/09/2023.
//

import SwiftUI

struct FloatingTextField: View {
    let title: LocalizedStringKey
    let text: Binding<String>
    var caption:LocalizedStringKey?
    var required:Bool? = false
    var secure:Bool = false
    var multiLine:Bool = false
    var autoCapitalize:TextInputAutocapitalization = .never
    var keyboard:UIKeyboardType = .default
    var isNumric = false
    var number: Binding<Double>?
    var enableNegative = false
    var isDiabled = false
    @State private var isFocused = false
    


    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            if !text.wrappedValue.isEmpty || multiLine || isNumric {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(.placeholderText))
                    .opacity(text.wrappedValue.isEmpty && !multiLine && !isNumric ? 0 : 1)
                    .offset(y: text.wrappedValue.isEmpty && !multiLine && !isNumric ? 20 : 0)
                    .padding(.leading, 6)
            }
            
            HStack {
                if secure {
                    HybridTextField(text: text, isFocused: $isFocused, titleKey: title)
                } else {
                    if multiLine {
                        TextEditor(text: text)
                            .keyboardType(keyboard)
                            .frame(height: 100)
                            .textInputAutocapitalization(autoCapitalize)
                            .disabled(isDiabled)
                            .submitLabel(.done)
                        
                            //.textInputAutocapitalization(autoCapitalize)
                    } else {
                        if isNumric && number != nil {
                            TextField(title, value: number!, formatter: NumberFormatter(), onEditingChanged: { focus in
                                isFocused = focus
                            })
                            .keyboardType(enableNegative ? .asciiCapableNumberPad : .numberPad)
                            .disabled(isDiabled)
                            .submitLabel(.done)
                        } else {
                            TextField(title, text: text, onEditingChanged: { focus in
                                isFocused = focus
                            })
                            .keyboardType(keyboard)
                            .textInputAutocapitalization(autoCapitalize)
                            .disabled(isDiabled)
                            .submitLabel(.done)
                        }
                    }
                }
                
                if required != nil && !secure {
                    Text(required! ? "Required" : "Optional")
                        .foregroundStyle(.gray)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10) // Adjust the corner radius as needed
                    .stroke(!isFocused ? Color.gray.opacity(0.1) : Color.accentColor, lineWidth: 1)
            )
            
            if caption != nil {
                Text(caption!)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    
            }
            
        }
    }
}

