//
//  CategoryLinearAdapter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CategoryLinear: View {
    @Binding var category:Category
    var isSelected:Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                CachedImageView(imageUrl: category.url, scaleType: .centerCrop, placeHolder: defaultCategoryImage)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .id(category.url)
                
                
                Text(category.name)
                    .font(.headline)
                    .padding(.horizontal)
                    .bold()
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct CategoryLinear_Previews: PreviewProvider {
    static var previews: some View {
        CategoryLinear(category: .constant(Category.example()))
    }
}
