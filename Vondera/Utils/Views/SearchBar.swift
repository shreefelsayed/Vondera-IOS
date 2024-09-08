//
//  SearchBar.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var hint = "Search ..."
    
    @State private var isEditing = false
    var body: some View {
        HStack {
            HStack {
                HStack {
                    Image(.icSearch)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    TextField(hint, text: $text)
                }
                .onTapGesture {
                    self.isEditing = true
                }
                
                Spacer()
                
                if isEditing && !text.isEmpty {
                    Button {
                        self.text = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .padding(7)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            if isEditing {
                Button("Cancel") {
                    withAnimation {
                        self.isEditing = false
                        self.text = ""
                    }
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
