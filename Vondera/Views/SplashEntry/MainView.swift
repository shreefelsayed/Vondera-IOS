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
            UserHome()
        } else {
            ProgressView()
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
