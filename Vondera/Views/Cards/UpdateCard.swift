//
//  UpdateCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import NetworkImage
struct UpdateCard: View {
    var update:Updates
    
    @State var user:UserData?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if user != nil {
                    NetworkImage(url: URL(string: user?.userURL ?? "")) { image in
                        image.centerCropped()
                    } placeholder : {
                        Image("defaultPhoto")
                            .resizable()
                            .centerCropped()
                    }
                    .background(Color.white)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    if update.uId == "Shopify" {
                        Image("shopify")
                            .resizable()
                            .frame(width: 60, height: 60)
                    } else if update.uId == "System" ||  update.uId == "Website"{
                        Image("app_icon")
                            .resizable()
                            .frame(width: 60, height: 60)
                    } else {
                        Circle()
                            .foregroundColor(.gray)
                            .frame(width: 60, height: 60)
                    }
                }
                 
                
                VStack(alignment:.leading) {
                    Text(update.desc())
                        .font(.body)
                    
                    HStack {
                        Text("By : \(getBy())")
                        
                        Spacer()
                        
                        Text(update.date.toDate().timeAgoString())
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding(2)
            
            Divider()
        }
        .onAppear {
            Task {
                do {
                    user = try await UsersDao().getUser(uId: update.uId)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getBy() -> String {
        if update.uId == "Shopify" {
            return "Shopify"
        } else if update.uId == "System" {
            return "Vondera"
        } else if update.uId == "Website" {
            return "Website"
        }
        
        return user?.name ?? ""
    }
}

struct UpdateCard_Previews: PreviewProvider {
    static var previews: some View {
        UpdateCard(update: Updates.example())
    }
}
