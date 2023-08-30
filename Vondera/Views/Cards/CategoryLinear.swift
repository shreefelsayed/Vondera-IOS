//
//  CategoryLinearAdapter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import NetworkImage

struct CategoryLinear: View {
    var category:Category
    var isSelected:Bool = false
    var onClick: (() -> ())
    
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
            
            Divider()
            
        }
        .onTapGesture {
            onClick()
        }
    }
}

struct CategoryLinear_Previews: PreviewProvider {
    static var previews: some View {
        CategoryLinear(category: Category.example()) {
            
        }
    }
}
