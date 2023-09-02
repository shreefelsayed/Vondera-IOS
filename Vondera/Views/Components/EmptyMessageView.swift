//
//  EmptyMessageView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct EmptyMessageView: View {
    var systemName:String = "bag.fill.badge.minus"
    var msg = "No Orders are added by you"
    var onClick :(() -> ())?
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center) {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Spacer().frame(height: 40)
                
                HStack {
                    Text(msg)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .bold()
                }
                
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .opacity(0.3)
        .onTapGesture {
            if onClick != nil {
                onClick!()
            }
        }
    }
}

struct EmptyMessageView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyMessageView()
    }
}
