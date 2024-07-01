//
//  SendNotificationScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI

struct SendNotificationScreen: View {
    @State private var title = ""
    @State private var notiBody = ""
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FloatingTextField(title: "Notification Title", text: $title)
                
                FloatingTextField(title: "Notification Body", text: $notiBody, multiLine: true)
                
                
                ButtonLarge(label: "Send Notification") {
                    sendNotification()
                }
                .disabled(notiBody.isBlank || title.isBlank)
            }
            .padding()
        }
        .navigationTitle("Send Notifictaions")
        .willProgress(saving: isSaving, msg: "Sending notification ..")
    }
    
    private func sendNotification() {
        guard !title.isBlank, !notiBody.isBlank else { return }
        isSaving = true
        
        Task {
            do {
                _ = try await FirebaseFunctionCaller().callFunction(functionName: "notifications-notifyStores", data: [
                    "title": title,
                    "body": notiBody
                ])
                
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(msg: "Notification sent !", toastType: .success)
                }
            } catch {
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .success)
            }
            
            isSaving = false
        }
    }
}

#Preview {
    SendNotificationScreen()
}
