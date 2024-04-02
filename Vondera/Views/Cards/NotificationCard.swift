//
//  NotificationCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/03/2024.
//

import Foundation
import SwiftUI

struct NotificationCard : View {
    var notification:NotificationModel
    
    var body: some View {
        HStack {
            Image(notification.getImage())
                .frame(width: 40, height: 40)
                .padding(.trailing, 12)
            
            VStack(alignment:.leading) {
                Text(notification.title)
                    .font(.headline)
                    .bold()
                
                
                Text(notification.body)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(notification.date.toString())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            }
            
            Spacer()
            
            if !notification.read {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .cardView()
        .onTapGesture {
            DynamicNavigation.shared.navigate(to: notification.getDestination())
        }
        .task {
            if let id = UserInformation.shared.user?.id {
                try? await NotificationsDao(userId: id).markAsRead(id: notification.id)
            }
        }
    }
}
