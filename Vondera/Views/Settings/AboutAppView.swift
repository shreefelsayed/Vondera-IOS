//
//  AboutAppView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct AboutAppView: View {
    var appVersion: String {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return version
            }
            return "N/A"
        }
    
    var body: some View {
        List() {
            Section("") {
                HStack {
                    Text("App Version")
                    
                    Spacer()
                    
                    Text("\(appVersion)")
                }
            }
            
            Section("") {
                HStack {
                    Text("Created By")
                    
                    Spacer()
                    
                    Text("Armjld Co.")
                }
            }
        }
        .navigationTitle("About app")
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutAppView()
        }
        
    }
}
