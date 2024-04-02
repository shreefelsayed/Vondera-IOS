//
//  EmployeeCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct EmployeeCardSkelton: View {
    var body: some View {
        HStack(alignment: .center) {
            SkeletonCellView(isDarkColor: true)
            .frame(width: 60, height: 60)
            .cornerRadius(60)
            
            VStack(alignment:.leading) {
                SkeletonCellView(isDarkColor: true)
                    .frame(height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
            }
        }
    }
}

struct EmployeeCard: View {
    var user:UserData
    
    @State private var sheetHeight: CGFloat = .zero
    @State var showContact = false
    
    var body: some View {
        NavigationLink(destination: EmployeeProfile(user: user)) {
            HStack(alignment: .center) {
                CachcedCircleView(imageUrl: user.userURL, scaleType: .centerCrop, placeHolder: defaultEmployeeImage)
                    .frame(width: 60, height: 60)
                
                VStack(alignment:.leading) {
                    Text(user.name)
                        .bold()
                    
                    Text(user.stringAccountType())
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

#Preview {
    NavigationStack {
        List {
            EmployeeCard(user: UserData.example())
            
            EmployeeCardSkelton()
        }
    }
}
