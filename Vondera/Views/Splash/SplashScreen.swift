//
//  SplashScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/03/2024.
//

import SwiftUI

struct SplashScreen : View {
    var body: some View {
        VStack (alignment: .center) {
            Spacer()
            
            Image("vondera_no_slogan")
                .resizable()
                .scaledToFit()
            
            Spacer()
            ProgressView()
            Spacer().frame(height: 48)
        }
        .padding()
    }
}


#Preview {
    SplashScreen()
}
