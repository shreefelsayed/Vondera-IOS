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
    var number: Binding<Int>?
    var isDiabled = false


    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            if !text.wrappedValue.isEmpty || multiLine || isNumric {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(.placeholderText))
                    .opacity(text.wrappedValue.isEmpty && !multiLine && !isNumric ? 0 : 1)
                    .offset(y: text.wrappedValue.isEmpty && !multiLine && !isNumric ? 20 : 0)
            }
            
            
            HStack {
                if secure {
                    HybridTextField(text: text, titleKey: title)
                } else {
                    if multiLine {
                        TextEditor(text: text)
                            .keyboardType(keyboard)
                            .frame(height: 100)
                            .textInputAutocapitalization(autoCapitalize)
                            .disabled(isDiabled)
                        
                            //.textInputAutocapitalization(autoCapitalize)
                    } else {
                        if isNumric && number != nil {
                            TextField(title, value: number!, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .disabled(isDiabled)
                        } else {
                            TextField(title, text: text)
                                .keyboardType(keyboard)
                                .textInputAutocapitalization(autoCapitalize)
                                .disabled(isDiabled)
                        }
                    }
                }
                
                if required != nil && !secure {
                    Text(required! ? "Required" : "Optional")
                        .foregroundStyle(.gray)
                }
            }
            
            
            if caption != nil {
                Text(caption!)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    
            }
            
        }
        .animation(.default)
    }
}

