//
//  StoreCategoryLinearCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import SwiftUI

struct StoreCategoryLinearCard: View {
    var storeCategory:StoreCategory
    @Binding var selected:Int?
    var onClicked:(() -> ())?
    
    var body: some View {
        HStack {
            Image(storeCategory.drawableId)
                .circleImage(padding:4, redius: 40)
            
            Spacer().frame(width: 6)
            
            Text(storeCategory.nameEn)
                .bold(selected == storeCategory.id ? true : false)
            
            Spacer()
            
            if selected == storeCategory.id {
                Image(systemName: "checkmark")
                    .font(.title2)
                    .foregroundStyle(Color.white)
            }
        }
        .padding()
        .background(selected == storeCategory.id ? Color.accentColor : Color.background)
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
