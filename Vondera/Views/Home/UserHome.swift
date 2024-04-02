//
//  UserHome.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI

struct UserHome: View {
    @State var myUser = UserInformation.shared.getUser()
    @State var selectedTab = 0
    
    @StateObject var dynamicNaivgation = DynamicNavigation.shared
    @StateObject var viewModel = UserHomeViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                HomeFragment()
                    .tabItem {
                        Image(selectedTab != 0 ? .icHomeOutline : .icHomeFill)
                        Text("Home")
                    }
                    .tag(0)
                
                OrdersFragment()
                    .tabItem {
                        Image(selectedTab != 1 ? .icCartOutline : .icCartFill)
                        Text("Orders")
                    }
                    .tag(1)
                
                ProductsFragment()
                    .tabItem {
                        Image(selectedTab != 2 ? .icBagOutline : .icBagFill)
                        Text("Products")
                    }
                    .tag(2)
                
                SettingsFragment()
                    .tabItem {
                        Image(selectedTab == 3 ? .icSettingsFill : .icSettingsOutline)
                        
                        Text("Settings")
                    }
                    .tag(3)
            }
            .task {
                await getUser()
            }
            .navigationBarBackButtonHidden(true)
            .onChange(of: scenePhase) { newPhase in
                handleOnlineState(phase: newPhase)
            }
            .navigationDestination(isPresented: $dynamicNaivgation.isPreseneted) {
                if let dest = dynamicNaivgation.destination?.dest {
                    dest
                }
            }
        }
    }
    
    func handleOnlineState(phase:ScenePhase) {
        if phase == .active {
            online()
        } else if phase == .background {
            offline()
        }
    }
    
    func online() {
        Task {
            if let user = myUser {
                try? await UsersDao().update(id: user.id, hash: ["online": true])
            }
        }
    }
    
    func offline() {
        Task {
            if let user = myUser {
                try? await UsersDao().update(id: user.id, hash: ["online": false])
            }
        }
    }
    
    func getUser() async {
        guard let user = UserInformation.shared.getUser() else {
            await AuthManger().logOut()
            return
        }
        
        DispatchQueue.main.async {
            self.myUser = user
        }
    }
}

struct IconAndName : View {
    var myUser: UserData
    var body: some View {
        HStack {
            if let store = myUser.store {
                ImagePlaceHolder(url: store.logo ?? "", placeHolder: UIImage(named: "app_icon"), reduis:42)
                
                Text(store.name)
                    .font(store.name.count > 14 ? .headline : .title2)
                    .bold()
                    .lineLimit(1)
            }
            
        }
    }
}


struct UserHome_Previews: PreviewProvider {
    static var previews: some View {
        UserHome()
    }
}
