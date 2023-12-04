//
//  ImportShopifyIntro.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/11/2023.
//

import SwiftUI

struct ImportShopifyIntro: View {
    @Binding var shouldShow:Bool
    @State var currentPage = 1
    var pagesCount = 8

    var body: some View {
        ZStack {
            if currentPage == 1 {
                createPage(title: "First we need to create a custom app", desc: "Head to your shopify store -> Settings -> App and Sales channels and click on create a new app", image: "step_1", showNext: true)
            } else if currentPage == 2 {
                createPage(title: "Enter app name", desc: "In the app name just enter Vondera, and leave the second field as is", image: "step_2", showNext: true)
            } else if currentPage == 3 {
                createPage(title: "Allow us to access your data", desc: "Click on the configure Admin API Scope, we only need to access your orders data and products data, so we can copy them to Vondera", image: "step_3", showNext: true)
            } else if currentPage == 4 {
                createPage(title: "Search for orders", desc: "Make sure you enable write and read for orders (not draft orders)", image: "step_4_1", showNext: true)
            } else if currentPage == 5 {
                createPage(title: "Search for products", desc: "Make sure you enable write and read for products and hit save", image: "step_4_2", showNext: true)
            } else if currentPage == 6 {
                createPage(title: "Install the app", desc: "Click on the api credentials, and click on install app", image: "step_5_1", showNext: true)
            } else if currentPage == 7 {
                createPage(title: "Get the Admin API Access Token", desc: "Copy the admin api access token to a safe place, note that you can't copy it again later.", image: "step_5_2", showNext: true)
            }  else if currentPage == 8 {
                createPage(title: "Get your store id", desc: "Copy your store id from the settings page to a safe place, we will need it too", image: "step_6", showNext: true)
            }
        }
        .padding()
    }
    
    @ViewBuilder func createPage(title:String, desc:String, image:String, showNext:Bool) -> some View {
        VStack {
            
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit) // or .fill, depending on your preference
                .frame(height: 240)
                .padding(.bottom, 20)
            
            HStack {
                ForEach(1..<(pagesCount + 1), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: index == currentPage ? 24 : 12, height: 8)
                        .foregroundColor(index == currentPage ? .accentColor : .gray)
                        .onTapGesture {
                            withAnimation(.linear) {
                                if(index != currentPage) {
                                   currentPage = index
                                }
                            }
                        }
                }
            }
            .padding(.bottom, 10)
            
            Text(title)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(desc)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            
            
            
            Spacer()
            
            Button {
                withAnimation {
                    if currentPage == pagesCount {
                        shouldShow = false
                    } else {
                        currentPage = currentPage + 1
                    }
                }
                
            } label: {
                HStack {
                       Spacer() // Add a spacer to push the text to the leading edge
                       Text(currentPage == pagesCount ? "Start importing" : "Continue")
                           .foregroundColor(.white)
                           .padding()
                       Spacer() // Add another spacer to push the text to the trailing edge
                   }
                   .background(Color.accentColor)
                   .cornerRadius(25)
                
            }
            .padding(.horizontal, 12)
        }
    }
}
