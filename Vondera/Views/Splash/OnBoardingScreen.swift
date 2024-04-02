//
//  OnBoardingScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/03/2024.
//

import SwiftUI

struct OnBoardingScreen : View {
    @Binding var shouldShow:Bool
    @State var pagesCount = 3
    @State var currentPage = 1
    
    var body: some View {
        ZStack {
            if currentPage == 1 {
                createPage(title: "Order Management Made Easy", desc: "Easily Keep track of orders, Generate and monitor revenue for seamless sales management", image: "onboard_1", showSkip: true, showNext: true)
            } else if currentPage == 2 {
                createPage(title: "Comprehensive Financial insights", desc: "Stay on top of your business finances with detailted reports on revenue, expenses, and profit marigins", image: "onboard_2", showSkip: true, showNext: true)
            } else if currentPage == 3 {
                createPage(title: "Efficient inventory management", desc: "Rack stocks effortlessly and ensure optimal inventory levels for store’s success.", image: "onboard_3", showSkip: false, showNext: true)
            }
        }
        .padding()
    }
    
    @ViewBuilder func createPage(title:String, desc:String, image:String, showSkip:Bool, showNext:Bool) -> some View {
        VStack {
            Image("vondera_no_slogan")
                .resizable()
                .aspectRatio(contentMode: .fit) // or .fill, depending on your preference
                .frame(height: 80)
                .padding(24)
            
            // MARK : Skip Button
            if showSkip {
                HStack {
                    Spacer()
                    
                    Group {
                        Text("Skip ")
                        Image(systemName: "arrow.right")
                    }
                    .onTapGesture {
                        withAnimation(.linear) {
                            currentPage = pagesCount
                        }
                    }
                    
                }
                .foregroundStyle(Color.accentColor)
            }
            
            Spacer()
            
            Image(image)
                .resizable()
                
                .aspectRatio(contentMode: .fit) // or .fill, depending on your preference
                .frame(height: 240)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(desc)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            
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
                       Text(currentPage == pagesCount ? "Build your store" : "Continue")
                           .foregroundColor(.white)
                           .padding()
                       Spacer() // Add another spacer to push the text to the trailing edge
                   }
                   .background(Color.accentColor)
                   .cornerRadius(25)
                
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
        }
    }
}

#Preview {
    OnBoardingScreen(shouldShow:.constant(true))
}
