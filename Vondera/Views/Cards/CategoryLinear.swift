//
//  CategoryLinearAdapter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import NetworkImage

struct CategoryLinear: View {
    @Binding var category:Category
    var isSelected:Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
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
