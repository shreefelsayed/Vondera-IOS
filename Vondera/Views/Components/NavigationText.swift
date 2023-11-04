//
//  NavigationText.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI

struct NavigationText: View {
    var view:AnyView
    var label:LocalizedStringKey
    var divider = true
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: view) {
                HStack {
                    Text(label)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if divider {
                Divider()
            }
        }
        
    }
}


struct NavigationText_Previews: PreviewProvider {
    static var previews: some View {
        NavigationText(view: AnyView(Text("Text")), label: "Navigate", divider: true)
    }
}
