//
//  CategoryTab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct CategoryTab: View {
    var category:Category
    @Binding var selected:Category?

    
    var body: some View {
        VStack(alignment: .center) {
            ImagePlaceHolder(url: category.url, placeHolder: UIImage(named: "defaultCategory"), reduis: 60, iconOverly: nil)
                .overlay(
                    Circle().stroke(selected?.id == category.id ? Color.accentColor : Color.clear, lineWidth: 2)
                )
                
            
            Text(category.name)
                .lineLimit(2, reservesSpace: false)
                .minimumScaleFactor(0.2) // value is up to you
                .multilineTextAlignment(.center)
                .foregroundColor(selected?.id == category.id ? .accentColor : .gray)
                .font(.body)
                .bold(selected?.id == category.id)
        }
        .frame(width: 80)
        .onTapGesture {
           selected = category
        }
    }
}
