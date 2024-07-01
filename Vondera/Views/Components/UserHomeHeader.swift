//
//  UserHomeHeader.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/10/2023.
//

import SwiftUI
import PhotosUI
import AlertToast

struct UserHomeHeader: View {
    @ObservedObject var user = UserInformation.shared
    @State private var msg:LocalizedStringKey?
    @State private var showSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = user.user, let link = myUser.store?.getStoreDomain() {
                HStack(alignment: .center) {
                    ImagePlaceHolder(url: myUser.userURL, placeHolder: UIImage(named: "defaultPhoto"), reduis: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hi !")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text(myUser.name)
                            .font(.title2)
                            .foregroundColor(.white)
                            .bold()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "qrcode")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                        .onTapGesture {
                            showSheet.toggle()
                        }
                }
                
                HStack {
                    //MARK : LINK
                    HStack {
                        Image(.icCopy)
                            .onTapGesture {
                                CopyingData().copyToClipboard(link)
                            }
                            .padding(.horizontal, 4)
                        
                        Divider()
                        
                        Spacer()
                        
                        Link(link, destination: URL(string: link)!)
                        
                        Spacer()
                        
                        Divider()
                        
                        Image(.icShare)
                            .onTapGesture {
                                shareLink()
                            }
                            .padding(.horizontal, 4)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                    )
                    
                    if let store = myUser.store, myUser.canAccessAdmin {
                        NavigationLink(destination: Dashboard(store: store)) {
                            Image(.icDashboard)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor)
        )
        .sheet(isPresented: $showSheet, content: {
            if let user = user.user {
                QRCodeSheet(myUser: user)
                    .presentationDetents([.medium])
            }
        })
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        })
    }
    
    func shareLink() {
        if let link = user.user?.store?.getStoreDomain(), let appURL = URL(string: link) {
            let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}

struct QRCodeSheet : View {
    var myUser:UserData
    
    var body: some View {
        VStack(alignment: .center) {
            Text(myUser.store?.name ?? "")
                .font(.title3)
                .bold()
            
            // MARK : Sharing Button
            
            
            // MARK : QR CODE
            if let qrData = myUser.store?.linkQrCodeData() {
                Image(uiImage: UIImage(data: qrData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
            
            Divider()
            
            // MARK : TEXT
            Text("Scan the qrcode, or share it to visit your website")
                .multilineTextAlignment(.center)
            
            
        }
        .padding()
    }
}

#Preview {
    UserHomeHeader()
        .padding(.horizontal)
}
