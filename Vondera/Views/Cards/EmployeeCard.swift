//
//  EmployeeCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import NetworkImage

struct EmployeeCard: View {
    var user:UserData
    var onClick: (() -> ())?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                NetworkImage(url: URL(string: user.userURL)) { image in
                    image.centerCropped()
                } placeholder : {
                    Color.gray
                } fallback: {
                    Image("defaultPhoto")
                        .resizable()
                        .centerCropped()
                }
                .background(Color.white)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                 
                
                VStack(alignment:.leading) {
                    Text(user.name)
                        .font(.title2)
                        .bold()
                    
                    Text(user.stringAccountType())
                        .font(.headline)
    
                }
            }
            .padding(2)
            
            Divider()
        }
    }
}

struct EmployeeCard_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeCard(user: UserData.example())
    }
}
