//
//  UserCircle.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI
import NetworkImage

struct UserCircle: View {
    var user:UserData
    
    var body: some View {
        VStack (alignment: .center, spacing: 8){
            NetworkImage(url: URL(string: user.userURL)) { image in
                image.centerCropped()
            } placeholder : {
                Color.gray
            } fallback: {
                Image("defaultPhoto")
                    .resizable()
                    .centerCropped()
            }
            .background {
                Color.white
            }
            .id(user.userURL)
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .fill(user.online ?? false ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                    .offset(x: 20, y: -20)
            )
            
            Text(user.name)
                .font(.body)
                .bold()
                .lineLimit(1)
            
        }
    }
}

struct UserCircle_Previews: PreviewProvider {
    static var previews: some View {
        UserCircle(user: UserData.example())
    }
}
