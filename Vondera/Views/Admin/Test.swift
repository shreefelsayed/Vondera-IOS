//
//  Test.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI

struct Test: View {
    @State private var count = 0
    var body: some View {
        VStack {
            if count > 0 {
                Text("Hello, Marko! \(count)")
            }
            
            HStack {
                Button("Plus") {
                    count = count + 1
                }
                
                
                Button("Minus") {
                    count = count - 1
                }
            }
        }
        
    }
}

#Preview {
    Test()
}
