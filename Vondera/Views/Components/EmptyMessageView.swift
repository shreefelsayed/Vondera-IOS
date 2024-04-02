//
//  EmptyMessageView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct SearchEmptyView : View {
    var searchText:String
    
    var body: some View {
        EmptyMessageView(systemName: "magnifyingglass", msg: searchText.isBlank ? "Start typing to search" : "No result for your search \(searchText)")
    }
}

struct EmptyMessageViewWithButton<Content: View>: View {
    var systemName:String = "bag.badge.minus"
    var msg:LocalizedStringKey = "No Orders are added by you"
    var button: (() -> Content)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
            EmptyMessageView(systemName: systemName, msg: msg, native: false)
            
            if let button = button {
                button()
                    .buttonStyle(.bordered)
            }
            
            
            Spacer()            
        }
    }
}

struct EmptyMessageResourceWithButton<Content: View>: View {
    var imageResource:ImageResource?
    var msg:LocalizedStringKey = "No Orders are added by you"
    var button: (() -> Content)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
            EmptyMessageWithResource(imageResource: imageResource, msg: msg)
            
            if let button = button {
                button()
                    .buttonStyle(.bordered)
            }
            
            
            Spacer()
        }
    }
}

struct EmptyMessageWithResource: View {
    var imageResource:ImageResource?
    var msg:LocalizedStringKey = "No Orders are added by you"
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                if let imageResource = imageResource {
                    Image(imageResource)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                    
                    Spacer().frame(height: 40)
                }
                
                HStack {
                    Text(msg)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptyMessageView: View {
    var systemName:String = "bag.badge.minus"
    var msg:LocalizedStringKey = "No Orders are added by you"
    var onClick :(() -> ())?
    var native = true
    
    var body: some View {
        if #available(iOS 17.0, *), native {
            ContentUnavailableView(msg, systemImage: systemName)
                .onTapGesture {
                    if onClick != nil {
                        onClick!()
                    }
                }
        } else {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    if !systemName.isBlank {
                        Image(systemName: systemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                        
                        Spacer().frame(height: 40)
                    }
                    
                    
                    HStack {
                        Text(msg)
                            .lineLimit(4)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                }
                //Spacer()
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
}

struct EmptyMessageView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyMessageView()
    }
}
