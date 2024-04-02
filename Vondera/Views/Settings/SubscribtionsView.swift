//
//  SubscribtionsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import StoreKit

struct SubscribtionsView: View {
    
    var body: some View {
        ScrollView {
            if let plan = UserInformation.shared.user?.store?.subscribedPlan {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center) {
                        Text("Current plan")
                            .font(.title3)
                            .bold()
                        
                        Spacer()
                        
                        Text("\(plan.planName)")
                    }
                    
                    if plan.isFreePlan() {
                        HStack {
                            Spacer()
                            
                            NavigationLink("Upgrade your plan") {
                                AppPlans()
                            }
                        }
                    } else {
                        VStack(alignment: .center) {
                            HStack {
                                NavigationLink("Upgrade / Change Plan") {
                                    AppPlans()
                                }
                                
                                Spacer()
                                
                                Button("Cancel", role: .destructive) {
                                    Task {
                                        await manageSubscriptions()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Subscribtions")
        
    }
    
    @MainActor
    func manageSubscriptions() async {
        if let windowScene = UIApplication.shared.connectedScenes.first {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene as! UIWindowScene)
            } catch {
                print(error)
            }
        }
    }
}

struct SubscribtionsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribtionsView()
    }
}
