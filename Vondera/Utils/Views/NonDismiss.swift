//
//  NonDismiss.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import ProgressIndicatorView

struct NonDismiss: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(.white)
        }
        
        .ignoresSafeArea()
        
    }
}

struct NonDismiss_Previews: PreviewProvider {
    static var previews: some View {
        NonDismiss()
    }
}
