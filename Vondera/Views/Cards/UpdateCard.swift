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
    @State var deleted = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if let user  = user {
                    ImagePlaceHolder(url: user.userURL, placeHolder: UIImage(named: "defaultPhoto"), reduis: 60, iconOverly: nil)
                } else if update.uId == "Shopify" {
                    Image("shopify")
                        .resizable()
                        .frame(width: 60, height: 60)
                } else if update.uId == "System" ||  update.uId == "Website"{
                    Image("app_icon")
                        .resizable()
                        .frame(width: 60, height: 60)
                } else if deleted {
                    ImagePlaceHolder(url: "", placeHolder: UIImage(named: "defaultPhoto"), reduis: 60, iconOverly: nil)
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                }
                
                
                VStack(alignment:.leading) {
                    Text(update.desc())
                        .font(.headline)
                    
                    HStack {
                        Text("By : \(getBy().toString())")
                            .font(.body)
                            .foregroundStyle(deleted ? .red : .black)
                        
                        Spacer()
                        
                        Text(update.date.toDate().timeAgoString())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding(2)
            
            Divider()
        }
        .task {
            do {
                let result = try await UsersDao().getUser(uId: update.uId)
                DispatchQueue.main.async {
                    if result.exists {
                        self.user = result.item
                        return
                    }
                    self.deleted = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getBy() -> LocalizedStringKey {
        if update.uId == "Shopify" {
            return "Shopify"
        } else if update.uId == "System" {
            return "Vondera"
        } else if update.uId == "Website" {
            return "Website"
        } else if let user = user {
            return user.name.localize()
        } else if deleted {
            return "Deleted User"
        }
        
        return "Unknown"
    }
}

struct UpdateCard_Previews: PreviewProvider {
    static var previews: some View {
        UpdateCard(update: Updates.example())
    }
}
