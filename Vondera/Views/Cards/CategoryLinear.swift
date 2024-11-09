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
                
                if category.hidden ?? false {
                    Image(systemName: "eye.slash")
                        .padding(.trailing, 18)
                }
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
                                
                Image(systemName: "arrow.up.arrow.down")
                    .opacity(0.5)
                    .font(.body)
            }
        }
    }
}

struct SubCategoryLinear: View {
    @Binding var category:SubCategory
    var isSelected:Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
               
                Text(category.name)
                    .font(.headline)
                    .padding(.horizontal)
                    .bold()
                
                Spacer()
                
                
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
                                
                Image(systemName: "arrow.up.arrow.down")
                    .opacity(0.5)
                    .font(.body)
            }
        }
    }
}


#Preview {
    CategoryLinear(category: .constant(Category.example()))
}
