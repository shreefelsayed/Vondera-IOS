//
//  VonderaApp.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import FirebaseCore

@main
struct VonderaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light)
                
        }
    }
}
