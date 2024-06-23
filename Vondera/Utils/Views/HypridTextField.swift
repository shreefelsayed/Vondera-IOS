//
//  HypridTextField.swift
//  Vondera
//
//  Created by Shreif El Sayed on 17/10/2023.
//

import SwiftUI

///Contains all the code for the Secure and regular TextFields
struct HybridTextField: View {
    @Binding var text: String
    @State var isSecure: Bool = true
    @Binding var isFocused:Bool
    var titleKey: LocalizedStringKey
    
    var body: some View {
        HStack{
            Group{
                if isSecure{
                    SecureField(titleKey, text: $text, onCommit: {isFocused = false})
                        .onTapGesture {
                            isFocused = true
                        }
                    
                } else{
                    TextField(titleKey, text: $text) { focus in
                        isFocused = focus
                    }
                    .submitLabel(.done)
                }
            }
            //.animation(.easeInOut(duration: 0.2), value: isSecure)
            Button {
                withAnimation {
                    isSecure.toggle()
                }
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye" )
            }
            .buttonStyle(.plain)
        }
    }
}
