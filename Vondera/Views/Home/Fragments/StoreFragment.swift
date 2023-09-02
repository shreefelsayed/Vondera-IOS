//
//  StoreFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import NetworkImage

struct StoreFragment: View {
    @StateObject var viewModel = StoreSettingsViewModel()
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @State var showContactDialog = false
    var customerServiceNumber = "01551542514"
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.user == nil {
                ProgressView()
            } else {
                // MARK : Settings
                ZStack {
                    List {
                        // MARK : Header
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                ZStack {
                                    NetworkImage(url: URL(string: viewModel.user?.userURL ?? "" )) { image in
                                      image.centerCropped()
                                    } placeholder: {
                                      ProgressView()
                                    } fallback: {
                                        Image("defaultPhoto")
                                            .resizable()
                                            .centerCropped()
                                    }
                                    .background(Color.gray)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                }
                                .overlay(alignment: .bottomTrailing, content: {
                                    NetworkImage(url: URL(string: viewModel.user?.store!.logo ?? "" )) { image in
                                        image.centerCropped()
                                    } placeholder: {
                                        ProgressView()
                                    } fallback: {
                                        Image("app_icon")
                                            .resizable()
                                            .centerCropped()
                                    }
                                    .background(Color.yellow)
                                    .frame(width: 30, height: 30, alignment: .bottomTrailing)
                                    .clipShape(Circle())
                                })
                                
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.user?.name ?? "")
                                        .font(.title.bold())
                                        .foregroundColor(.accentColor)
                                    
                                    Text("\(viewModel.user?.getAccountTypeString() ?? "") at \(viewModel.user?.store!.name ?? "")")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                
                                Spacer()
                            }
                            
                            PlanCard(store: viewModel.user!.store!)
                        }
                        
                        Section("Store Settings") {
                            NavigationLink("Subscriptions", destination: SubscribtionsView())
                                .bold()
                            
                            NavigationLink("Store Info", destination: StoreInfoView(store: viewModel.user!.store!))
                                .bold()
                            
                            NavigationLink("Reffer Program", destination: RefferView(user:viewModel.user!))
                                .bold()
                        }
                        
                        Section("Account Settings") {
                            NavigationLink("My Orders", destination: UserOrders(id: viewModel.user!.id, storeId: viewModel.user!.storeId))
                                .bold()
                            
                            NavigationLink("Edit my info", destination: EditInfoView(user: viewModel.user!))
                                .bold()
                            
                            
                            NavigationLink("Change Password", destination: ChangePasswordView(user: viewModel.user!))
                                .bold()
                            
                            NavigationLink("Change Phone", destination: ChangePhoneView())
                                .bold()
                            
                            /*NavigationLink("Connect to social media", destination: ConnectSocialView())
                                .bold()*/
                        }
                        
                        Section("App Settings") {
                            NavigationLink("Notification Settings", destination: NotificationsSettingsView())
                                .bold()
                            
                            /*NavigationLink("App Language", destination: Text("App Language"))
                                .bold()
                                .isHidden(true)*/
                            
                            NavigationLink("About app", destination: AboutAppView())
                                .bold()
                        
                            
                            Text("Contact customer service")
                                .bold()
                                .onTapGesture {
                                    showContactDialog.toggle()
                                }
                        }
                        
                        Button("Log Out") {
                            Task {
                                await AuthManger().logOut()
                            }
                        }.padding()
                    }
                    
                    BottomSheet(isShowing: $showContactDialog, content: {
                        AnyView(ContactDialog(phone:customerServiceNumber, toggle: $showContactDialog))
                    }())
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.initalize()
            }
        }
        .navigationTitle("Settings")
        
    }
}

struct StoreFragment_Previews: PreviewProvider {
    static var previews: some View {
        StoreFragment()
    }
}
