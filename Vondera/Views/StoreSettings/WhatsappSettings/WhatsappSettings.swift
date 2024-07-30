//
//  WhatsappSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2024.
//

import SwiftUI

struct WhatsappSettings: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            Section("Customize & Enable") {
                NavigationLink("New Order") {
                    WBNewOrderSettings()
                }
                
                NavigationLink("Order Shipped") {
                    WBShippedSettings()
                }
                
                NavigationLink("Order Delivered") {
                    WBDeliveredSettings()
                }
            }
        }
        .navigationTitle("Whatsapp settings")
        .withPaywall(accessKey: .whatsapp, presentation: presentationMode)
    }
}

#Preview {
    WhatsappSettings()
}
