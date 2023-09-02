//
//  FloatingActionButton.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/06/2023.
//

import SwiftUI

struct FloatingActionButton: View {
    let symbolName: String
    let action: (() -> ())?
    let foregroundColor: Color

    init(symbolName: String, action: (() -> ())?, foregroundColor: Color = Color.accentColor) {
        self.symbolName = symbolName
        self.action = action
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        if action != nil {
            Button {
                action!()
            } label: {
                Image(systemName: symbolName)
                    .foregroundColor(foregroundColor)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        } else {
            Image(systemName: symbolName)
                .foregroundColor(foregroundColor)
                .padding()
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        
    }
}
