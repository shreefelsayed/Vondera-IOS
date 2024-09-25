//
//  NewButton.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/09/2024.
//

import SwiftUI

struct NewLabel: View {
    var body: some View {
        Text("NEW")
            .font(.caption)
            .bold()
            .foregroundStyle(.blue)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.2))
            )
            .overlay(
                Capsule()
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

#Preview {
    NewLabel()
}
