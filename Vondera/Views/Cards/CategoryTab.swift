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
            ImagePlaceHolder(url: category.url, placeHolder: UIImage(named: "defaultCategory"), reduis: 60, iconOverly: nil)
                .overlay(
                    Circle().stroke(selected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
            
            Text(category.name)
                .lineLimit(2, reservesSpace: false)
                .minimumScaleFactor(0.2) // value is up to you
                .multilineTextAlignment(.center)
                .foregroundColor(selected ? .accentColor : .gray)
                .font(.body)
                .bold(selected)
        }
        .frame(width: 80)
        .onTapGesture {
            onClick()
        }
    }
}
