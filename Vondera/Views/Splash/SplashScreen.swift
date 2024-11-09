//
//  SplashScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/03/2024.
//

import SwiftUI

struct SplashScreen : View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.splash)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            // ProgressView at the bottom
            ProgressView()
                .padding(.bottom, 40) // Adds padding to bring the progress view slightly above the screen bottom
                .foregroundColor(.white)
        }
        
    }
}


#Preview {
    SplashScreen()
}
