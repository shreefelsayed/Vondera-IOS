//
//  PrivacyCenter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 12/03/2024.
//

import SwiftUI

struct PrivacyCenter: View {
    private let privacyLink = "https://www.vondera.app/privacy-policy"
    private let termsLink = "https://www.vondera.app/terms-conditions"
    
    var body: some View {
        List {
            Label {
                Text("Privacy Policy")
            } icon: {
                Image(.btnPolicy)
            }
            .bold()
            .onTapGesture {
                if let Url = URL(string: privacyLink) {
                    UIApplication.shared.open(Url)
                }
            }
            
            Label {
                Text("Terms and conditions")
            } icon: {
                Image(.btnTerms)
            }
            .bold()
            .onTapGesture {
                if let Url = URL(string: termsLink) {
                    UIApplication.shared.open(Url)
                }
            }

        }
        .navigationTitle("Privacy Center")
    }
}

#Preview {
    PrivacyCenter()
}
