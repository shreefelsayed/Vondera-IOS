//
//  ContentView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import AlertToast

struct MainView: View {
    @ObservedObject var toast = ToastManager.shared
    
    @StateObject var viewModel = MainViewModel()
    @StateObject var lang = LocalizationService.shared
    @AppStorage("intro") var showOnBoarding = true
    
    @State var didSignIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.all)
                
                if showOnBoarding {
                    OnBoardingScreen(shouldShow: $showOnBoarding)
                } else {
                    ZStack {
                        if viewModel.signed {
                            LoadingUserDataScreen()
                        } else {
                            LoginView()
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $toast.isPresented) {
            AlertToast(displayMode: .banner(.slide), type: toast.toastType, title: toast.msg?.toString())
        }
        .environment(\.locale, Locale(identifier: lang.currentLanguage.rawValue))
        .environment(\.layoutDirection, lang.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
        .background(Color.background)
    }
    
    func signIn() {
        Task {
            await viewModel.getUserData()
        }
    }
}

#Preview {
    MainView()
}
