//
//  FloatingTextField.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/09/2023.
//

import SwiftUI

struct FloatingTextField: View {
    let title: String
    let text: Binding<String>
    var caption:String?
    var required:Bool = false
    var secure:Bool = false
    var multiLine:Bool = false


    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            if !text.wrappedValue.isEmpty {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(.placeholderText))
                    .opacity(text.wrappedValue.isEmpty ? 0 : 1)
                    .offset(y: text.wrappedValue.isEmpty ? 20 : 0)
            }
            
            
            HStack {
                if secure {
                    SecureField(title, text: text)
                } else {
                    if multiLine {
                        TextField(title, text: text)
                            .lineLimit(5, reservesSpace: true)
                            .textInputAutocapitalization(.sentences)
                            .multilineTextAlignment(.leading)
                    } else {
                        TextField(title, text: text)
                    }
                        
                }
                
                Text(required ? "Required" : "Optional")
                    .foregroundStyle(.gray)
            }
            
            
            if caption != nil {
                Text(caption!)
                    .font(.caption)
            }
            
        }.animation(.default)
    }
}

