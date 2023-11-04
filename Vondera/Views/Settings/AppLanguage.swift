//
//  SwiftUIView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI

struct AppLanguage: View {
    @State var currentLangue:Language = LocalizationService.shared.currentLanguage
    @State var showConfirm = false
    
    var body: some View {
        List {
            Picker("Choose your language", selection: $currentLangue) {
                Text("English")
                    .tag(Language.english_us)
                
                Text("العربية")
                    .tag(Language.arabic)
            }
        }
        .onChange(of: currentLangue, perform: { newValue in
            showConfirm.toggle()
        })
        .alert(isPresented: $showConfirm, content: { confirmChange })
        .navigationTitle("Change app language")
        .listStyle(.plain)
    }
    
    var confirmChange: Alert {
        Alert(title: Text("Change Configuration?"), message: Text("This application needs to restart to update the configuration.\n\nDo you want to restart the application?"),
            primaryButton: .default (Text("Yes")) {
            LocalizationService.shared.setLanguage(currentLangue)
                restartApplication()
            },
            secondaryButton: .cancel(Text("No"))
        )
    }

    func restartApplication(){
        var localUserInfo: [AnyHashable : Any] = [:]
        localUserInfo["pushType"] = "restart"
        
        let content = UNMutableNotificationContent()
        content.title = "Configuration Update Complete"
        content.body = "Tap to reopen the application"
        content.sound = UNNotificationSound.default
        content.userInfo = localUserInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

        let identifier = "com.domain.restart"
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request)
        exit(0)
    }
}
