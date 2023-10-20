//
//  ContentView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI


struct LoadingScreen: View {
    @State var loggedIn = false
    
    var body: some View {
        if loggedIn {
            AccountHomeScreen()
        } else {
            SplashScreen()
                .onAppear {
                Task {
                    do {
                        self.loggedIn = try await AuthManger().getData() != nil
                    } catch {
                        await AuthManger().logOut()
                    }
                }
            }
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
