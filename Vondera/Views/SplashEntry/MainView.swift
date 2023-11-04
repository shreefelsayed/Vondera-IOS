//
//  ContentView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI


struct LoadingScreen: View {
    @ObservedObject var user = UserInformation.shared
    
    var body: some View {
        if let _ = user.user {
            AccountHomeScreen()
        } else {
            SplashScreen()
                .task {
                    do {
                        let loggedUser = try await AuthManger().getData()
                        if loggedUser == nil {
                            await AuthManger().logOut()
                        }
                    } catch {
                        await AuthManger().logOut()
                    }
                }
        }
        if user.user != nil {
            
        } else {
            
        }
        
    }
}

struct AccountHomeScreen : View {
    @State var myUser:UserData?
    
    var body : some View {
        ZStack {
            if let myUser = myUser {
                if myUser.isStoreUser {
                    UserHome()
                    
                } else if myUser.accountType == "Sales" {
                    #warning("Set the sales Dashboard")
                } else if myUser.accountType == "Admin" {
                    #warning("Set the Admin Dashboard")
                }
            }
        }
        .onAppear {
            self.myUser = UserInformation.shared.getUser()
        }
    }
}

struct SplashScreen : View {
    var body: some View {
        ZStack {
            VStack (alignment: .center) {
                Spacer()
                
                Image("logo_horz")
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                ProgressView()
                Spacer().frame(height: 48)
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var lang = LocalizationService.shared
    @State var didSignIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.signed {
                    LoadingScreen()
                } else {
                    LoginView()
                }
            }
        }
        .environment(\.locale, Locale(identifier: lang.currentLanguage.rawValue))
        .environment(\.layoutDirection, lang.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
    }
    
    func signIn() {
        Task {
            await viewModel.getUserData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
