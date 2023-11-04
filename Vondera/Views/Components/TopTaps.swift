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
    var tabs:[LocalizedStringKey]
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tabs.indices, id: \.self) { index in
                    Text(tabs[index])
                        .foregroundColor(.white)
                        .font(.body)
                        .bold()
                        .padding(6)
                        .background {
                            Rectangle()
                                .foregroundColor(selection == index ? .accentColor : .gray)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            selection = index
                        }
                }
            }
            
        }
    }
}

