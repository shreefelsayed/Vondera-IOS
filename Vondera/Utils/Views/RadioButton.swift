//
//  RadioButton.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import SwiftUI

struct RadioButton: View {
    var imageName: ImageResource? = nil
    var text: LocalizedStringKey
    var isSelected: Bool
    var action: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .foregroundColor(isSelected ? .accentColor : .gray)
                .imageScale(.medium)
            
            Text(text)
                .font(.body)
                .padding(.leading, 4)
            
            Spacer()
        }
        .onTapGesture {
            if let action = action {
                action()
            }
        }
    }
}
