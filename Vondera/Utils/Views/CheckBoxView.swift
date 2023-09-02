//
//  CheckBox.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import SwiftUI

struct CheckBoxView: View {
    @Binding var checked: Bool
    var onSelected:(() -> ())
    var onDeselect:(() -> ())


    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color.accentColor : Color.secondary)
            .onTapGesture {
                if self.checked {
                    onDeselect()
                } else {
                    onSelected()
                }
                
                self.checked.toggle()
            }
    }
}

