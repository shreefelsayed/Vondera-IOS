//
//  UserCircle.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI

struct UserCircle: View {
    var user:UserData
    
    var body: some View {
        VStack (alignment: .center, spacing: 8){
            CachcedCircleView(imageUrl: user.userURL, scaleType: .centerCrop, placeHolder: defaultEmployeeImage)
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .fill(user.online ?? false ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                    .offset(x: 20, y: -20)
            )
            
            Text(user.name.firstName)
                .font(.callout)
                .frame(maxWidth: 75)
                .lineLimit(2)
        }
    }
}

struct UserCircle_Previews: PreviewProvider {
    static var previews: some View {
        UserCircle(user: UserData.example())
    }
}
