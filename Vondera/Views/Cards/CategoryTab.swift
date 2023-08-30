//
//  CategoryTab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import NetworkImage

struct CategoryTab: View {
    var category:Category
    var onClick: (() -> ())
    @Binding var selected:Bool
    
    init(category: Category, onClick: @escaping () -> Void, selected: Binding<Bool>) {
        self.category = category
        self.onClick = onClick
        self._selected = selected
    }
    
    var body: some View {
        VStack(alignment: .center) {
            NetworkImage(url: URL(string: category.url)) { image in
                image.centerCropped()
            } placeholder : {
                Color.gray
            } fallback: {
                Color.gray
            }
            .background(Color.white)
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(selected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            
            Text(category.name)
                .foregroundColor(selected ? .accentColor : .gray)
                .font(.headline)
                .bold(selected)
        }
        .onTapGesture {
            onClick()
        }
    }
}
