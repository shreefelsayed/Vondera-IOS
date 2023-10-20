//
//  SubscribtionsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct SubscribtionsView: View {
    @State var myUser: UserData?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    Text("Current plan")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    Text("\(myUser?.store?.subscribedPlan?.planName ?? "")")
                }
                
                if myUser?.store?.subscribedPlan?.isFreePlan() ?? true {
                    HStack {
                        Spacer()
                        
                        NavigationLink("Upgrade your plan") {
                            AppPlans()
                        }
                    }
                } else {
                    VStack(alignment: .center) {
                        HStack {
                            NavigationLink("Renew Now") {
                                AppPlans()
                            }
                            
                            Spacer()
                            
                            NavigationLink("Upgrade your plan") {
                                AppPlans()
                            }
                        }
                        
                        /*Text("Unsubscribe")
                            .foregroundStyle(.red)
                            .bold()*/
                    }
                }
                
                
            }
        }
        .padding()
        .onAppear {
            self.myUser = UserInformation.shared.getUser()
        }
        .navigationTitle("Subscribtion")
        
    }
}

struct SubscribtionsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribtionsView()
    }
}
