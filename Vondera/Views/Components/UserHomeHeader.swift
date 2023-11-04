//
//  UserHomeHeader.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/10/2023.
//

import SwiftUI
import NetworkImage
import PhotosUI
import AlertToast

struct UserHomeHeader: View {
    @ObservedObject var user = UserInformation.shared
    @State private var picker:PhotosPickerItem?
    @State private var msg:LocalizedStringKey?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = user.user {
                HStack(alignment: .center) {
                    PhotosPicker(selection: $picker) {
                        ImagePlaceHolder(url: myUser.userURL, placeHolder: UIImage(named: "defaultPhoto"), reduis: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello again! 👋")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(myUser.name)
                            .font(.title2)
                            .bold()
                        
                        Label(myUser.getAccountTypeString(), systemImage: "bolt")
                            .font(.body)
                    }
                }
                
                HStack {
                    if myUser.canAccessAdmin, let store = myUser.store {
                        NavigationLink {
                            Dashboard(store: store)
                        } label: {
                            Label("Dashboard", systemImage: "list.dash.header.rectangle")
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .foregroundColor(.accentColor)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if (myUser.store?.websiteEnabled ?? true) {
                        WebsiteLink(user: myUser)
                    }
                }
            }
        }
        .onChange(of: picker, perform: { _ in
            Task {
                if let data = try? await picker?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data), let id = UserInformation.shared.user?.id {
                        FirebaseStorageUploader().updateUserImage(image: uiImage, uId: id) { success in
                            self.msg = "You image updated"
                            self.picker = nil
                        }
                    }
                }
            }
        })
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        })
    }
}

struct WebsiteLink : View {
    var user:UserData
    @State private var showSheet = false
    
    var body: some View {
        HStack {
            if let url = user.store?.storeLinkURL() {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.title2)
                }
                
                Spacer()
                
                Link(destination: url) {
                    Text("\(user.store?.name ?? "")'s website")
                        .lineLimit(1)
                        .font(.caption)
                }
                
                Spacer()
            }
            
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
        .sheet(isPresented: $showSheet, content: {
            QRCodeSheet(myUser: user)
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
    UserHomeHeader()
        .padding(.horizontal)
}
