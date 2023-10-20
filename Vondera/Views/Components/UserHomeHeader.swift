//
//  UserHomeHeader.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/10/2023.
//

import SwiftUI
import NetworkImage

struct UserHomeHeader: View {
    var myUser: UserData
    @State var showSheet = false
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                ImagePlaceHolder(url: myUser.userURL, placeHolder: UIImage(named: "defaultPhoto"))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello again! 👋")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(myUser.name)
                        .font(.headline.bold())
                    
                    HStack {
                        Image(systemName: "bolt")
                        Text( myUser.getAccountTypeString() )
                    }
                    .font(.body)
                }
                Spacer()
            }
            
            if (myUser.store?.websiteEnabled ?? true) {
                HStack {
                    ShareLink(item: myUser.store!.storeLinkURL()) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title2)
                    }
                   
                    
                    Spacer()
                    
                    Link(destination: myUser.store!.storeLinkURL()) {
                        Text("Your website")
                    }
                    
                    
                    Spacer()
                    
                    Button {
                        showSheet.toggle()
                        
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2)
                    }
                }
                .padding()
                .foregroundColor(.accentColor)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
               
            }
        }
        .sheet(isPresented: $showSheet, content: {
            QRCodeSheet(myUser: myUser)
                .presentationDetents([.medium])
        })
    }
}

struct QRCodeSheet : View {
    var myUser:UserData
    
    var body: some View {
        VStack(alignment: .center) {
            Text(myUser.store?.name ?? "")
                .font(.title3)
                .bold()
            
            if let link = myUser.store?.linkQrCodeData() {
                Image(uiImage: UIImage(data: link))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    UserHomeHeader(myUser: UserData.example())
        .padding(.horizontal)
}
