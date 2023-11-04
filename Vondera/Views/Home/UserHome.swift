//
//  UserHome.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import NetworkImage

struct UserHome: View {
    @State var myUser = UserInformation.shared.getUser()
    @State var selectedTab = 0
    
    @StateObject var viewModel = UserHomeViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFragment()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    Text("Home")
                }
                .tag(0)
            
            OrdersFragment()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "cart.fill" : "cart")
                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                    Text("Orders")
                }
                .tag(1)
            
            ProductsFragment()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "bag.fill" : "bag")
                        .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                    Text("Products")
                }
                .tag(2)
            
            SettingsFragment()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "ellipsis.rectangle.fill" : "ellipsis.rectangle")
                        .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                    
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
            ImagePlaceHolder(url: myUser.store?.logo ?? "", placeHolder: UIImage(named: "app_icon"), reduis:42)
            
            Text(myUser.store?.name ?? "")
                .bold()
        }
    }
}


struct UserHome_Previews: PreviewProvider {
    static var previews: some View {
        UserHome()
    }
}
