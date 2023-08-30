//
//  TopTaps.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import SwiftUI

struct TopTaps: View {
    @Binding var selection:Int
    var tabs:[String]
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(tabs.enumerated()), id: \.element) { index, tabName in
                    Text(tabName) // Example usage of index and tabName
                        .foregroundColor(.white)
                        .font(.body)
                        .bold()
                        .padding(5)
                        .background {
                            Rectangle()
                                .foregroundColor(selection == index ? .accentColor : .gray)
                                .cornerRadius(12)
                        }
                        .padding(5)
                        .onTapGesture {
                            selection = index
                        }
                }
            }
            
        }
    }
}

