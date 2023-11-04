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
    
    @State private var sheetHeight: CGFloat = .zero
    @State var showContact = false
    
    var body: some View {
        NavigationLink(destination: EmployeeProfile(user: user)) {
            HStack(alignment: .center) {
                ImagePlaceHolder(url: user.userURL, placeHolder: UIImage(named: "defaultPhoto"), reduis: 60, iconOverly: nil)
                
                VStack(alignment:.leading) {
                    Text(user.name)
                        .bold()
                    
                    Text(user.stringAccountType())
                    
                    Text("Orders \(user.ordersCount ?? 0)")
                        .font(.caption)
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                showContact.toggle()
            } label: {
                Image(systemName: "ellipsis.message.fill")
            }
            .tint(.green)
        }
        .sheet(isPresented: $showContact) {
            ContactDialog(phone: user.phone, toggle: $showContact)
        }
        .buttonStyle(.plain)
        
    }
}

struct EmployeeCard_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeCard(user: UserData.example())
    }
}
