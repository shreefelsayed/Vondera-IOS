//
//  AboutAppView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct AboutAppView: View {
    var body: some View {
        ZStack (alignment: .bottom) {
            VStack(alignment: .center) {
                Spacer()
                
                Image("vondera_logo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)

                    
                Spacer()
            }
            .frame(height: 300)
            .padding()
            
            VStack(alignment: .center) {
                Image("armjld_logo")
                    .resizable()
                    .frame(height: 60)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .foregroundColor(.accentColor)
                    .cornerRadius(25, corners: [.topLeft, .topRight])
            )
            .offset(y: -20)
            
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
