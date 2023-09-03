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
            UserHome()
        } else {
            SplashScreen()
                .onAppear {
                    Task {
                        do {
                            self.loggedIn = try await AuthManger().getData()
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
            if myUser != nil {
                if myUser!.accountType == "Owner" || myUser!.accountType == "Store Admin" ||
                    myUser!.accountType == "Employee" ||
                    myUser!.accountType == "Marketing" {
                    
                    UserHome()
                } else if myUser!.accountType == "Sales" {
                    
                } else if myUser!.accountType == "Admin" {
                    
                }
            }
        }
        .onAppear {
            Task {
                self.myUser = await LocalInfo().getLocalUser()
            }
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
