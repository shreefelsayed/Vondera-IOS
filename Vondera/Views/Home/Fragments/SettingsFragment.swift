//
//  StoreFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import AlertToast

struct SettingsFragment: View {
    private let appLink = "https://apps.apple.com/eg/app/vondera/id6459148256"
    @ObservedObject private var myUser = UserInformation.shared
    
    @State private var showContactDialog = false
    private var customerServiceNumber = "01551542514"
    
    @State private var editingProfile = false
    @State private var collapsed = true
    
    @State private var msg:String?
    
    @State private var showSavedItems = false
    @State private var count = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = myUser.getUser() {
                List {
                    // MARK : Header
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading)  {
                            HStack(alignment: .center) {
                                ImagePlaceHolder(url: myUser.userURL, placeHolder: UIImage(named: "defaultPhoto"), reduis: 60)
                                
                                VStack(alignment: .leading) {
                                    Text(myUser.name)
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .bold()
                                    
                                    
                                    Text("\(myUser.getAccountTypeString().toString()) at \(myUser.store?.name ?? "")")
                                        .font(.caption)
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                    
                                    Text("@\(myUser.store?.merchantId ?? "")")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            CopyingData().copyToClipboard(myUser.store?.merchantId ?? "")
                                        }
                                }
                                .padding(.horizontal, 12)
                                
                                Spacer()
                                
                                Image(.icEditProfile)
                                    .onTapGesture {
                                        editingProfile.toggle()
                                    }
                            }
                            
                            HStack {
                                Text("Current Plan")
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Text("\(myUser.store?.storePlanInfo?.name ?? "")")
                                    .foregroundStyle(.white)
                                
                                Image(systemName: collapsed ? "chevron.down" :  "chevron.up")
                                    .foregroundStyle(.white)
                            }
                            .onTapGesture {
                                collapsed.toggle()
                            }
                        }
                        .padding()
                        .background(
                            Color.accentColor
                        )
                        
                        if let store = UserInformation.shared.user?.store {
                            PlanCard(store: store)
                                .padding()
                        }
                            
                        
                    }
                    .listRowInsets(EdgeInsets())
                    
                    // MARK : STORE SETTINGS
                    if let store = myUser.store {
                        Section("Store Settings") {
                            NavigationLink(destination: SubscribtionsView()) {
                                Label(
                                    title: { Text("Subscriptions and payments") },
                                    icon: { Image(.btnSubscribtions) }
                                )
                            }
                            .bold()
                            
                            NavigationLink(destination: StoreInformation()) {
                                Label(
                                    title: { Text("Store Information") },
                                    icon: { Image(.btnStoreInfo) }
                                )
                            }
                            .bold()
                            
                            NavigationLink(destination: StoreSettingsView(store: store)) {
                                Label(
                                    title: { Text("Store Settings") },
                                    icon: { Image(.btnSettings) }
                                )
                            }
                            .bold()

                            NavigationLink(destination: WebsiteSettings()) {
                                Label(
                                    title: { Text("Website Settings") },
                                    icon: { Image(.btnWebsite) }
                                )
                            }
                            .bold()

                            NavigationLink(destination: VPayScreen()) {
                                Label(
                                    title: { Text("VPay Wallet") },
                                    icon: { Image(.btnVpay) }
                                )
                            }
                            .bold()

                             
                        }
                    }
                    
                    // MARKV: APP SETTINGS
                    Section("App Settings") {
                        NavigationLink {
                            NotificationsSettingsView()
                        } label: {
                            Label {
                                Text("Notification Settings")
                            } icon: {
                                Image(.btnNotification)
                            }

                        }.bold()
                        
                        NavigationLink {
                            AppLanguage()
                        } label: {
                            Label {
                                Text("Change App Language")
                            } icon: {
                                Image(.btnLanguage)
                            }

                        }.bold()
                        
                        NavigationLink {
                            AboutAppView()
                        } label: {
                            Label {
                                Text("About app")
                            } icon: {
                                Image(.btnAbout)
                            }

                        }.bold()
                        
                        NavigationLink {
                            PrivacyCenter()
                        } label: {
                            Label {
                                Text("Privacy Center")
                            } icon: {
                                Image(.btnPrivacyCenter)
                            }

                        }.bold()
                        

                            
                        Label {
                            Text("Contact Support")
                        } icon: {
                            Image(.btnSupport)
                        }
                        .bold()
                        .onTapGesture {
                            showContactDialog.toggle()
                        }
                        
                        Link(destination: URL(string: appLink)!, label: {
                            Label {
                                Text("Rate our app")
                            } icon: {
                                Image(.btnReview)
                            }
                        })
                        .buttonStyle(.plain)
                        
    
                        .bold()

                        
                        Label {
                            Text("Share the app")
                        } icon: {
                            Image(.btnShare)
                        }
                        .bold()
                        .onTapGesture {
                            shareApp()
                        }
                    }
                    
                    // MARK : Logining Settings
                    Section () {
                        // SWITCH accounts button
                        if count > 0 {
                            Label {
                                Text("Switch Account")
                            } icon: {
                                Image(.btnSwitch)
                            }
                            .onTapGesture {
                                withAnimation {
                                    showSavedItems.toggle()
                                }
                            }
                        }
                        
                        Label {
                            Text("Log Out")
                        } icon: {
                            Image(.btnLogout)
                        }
                        .onTapGesture {
                            Task {
                                await AuthManger().logOut()
                            }
                        }
                    }
                }
                .backgroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .refreshable {
            await refreshData()
        }
        .task {
            count = SavedAccountManager().getAllUsers().count
        }
        .sheet(isPresented: $showContactDialog) {
            ContactDialog(phone:customerServiceNumber, toggle: $showContactDialog)
        }
        .sheet(isPresented: $showSavedItems, content: {
            SwitchAccountView(show: $showSavedItems)
        })
        .navigationDestination(isPresented: $editingProfile, destination: {
            EditInfoView()
        })
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        })
        .navigationTitle("Settings")
        
    }
    
    func refreshData() async {
        if let user = try? await UsersDao().getUserWithStore(userId: myUser.user?.id ?? "") {
            UserInformation.shared.updateUser(user)
        }
    }
    
    func shareApp() {
            if let appURL = URL(string: appLink) {
                let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }
        }
}

#Preview {
    NavigationStack {
        SettingsFragment()
    }
}
