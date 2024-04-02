//
//  StoreCategoryLinearCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import SwiftUI

struct StoreCategoryLinearCard: View {
    var storeCategory:StoreCategory
    @Binding var selected:Int
    var onClicked:(() -> ())?
    
    var body: some View {
        HStack {
            Label {
                Text(storeCategory.name)
            } icon: {
                Image(storeCategory.drawableId)
            }
            .bold(selected == storeCategory.id ? true : false)
            
            Spacer()
            
            if storeCategory.id == selected {
                Image(systemName: "checkmark")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding()
        .onTapGesture {
            selected = storeCategory.id
            if onClicked != nil {
                onClicked!()
            }
        }
    }
}


#Preview {
    StoreCategoryLinearCard(storeCategory: StoreCategory.example(), selected: .constant(0))
}
