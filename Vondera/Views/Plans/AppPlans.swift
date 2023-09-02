//
//  AppPlans.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI

struct AppPlans: View {
    @State var myUser:UserData?
    @State var plans:[Plan] = []
    @State var isLoading = false
    @State var showContactDialog = false
    var customerServiceNumber = "01551542514"
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Choose your plan")
                        .font(.title3)
                        .bold()
                                    
                    // MARK : PLANS
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack() {
                            ForEach(plans) { plan in
                                ChoosePlanCard(plan: plan, currentPlan: myUser?.store?.subscribedPlan?.planId ?? "") {
                                    showContactDialog.toggle()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    //
                }
            }
            .padding()
            
            BottomSheet(isShowing: $showContactDialog, content: {
                AnyView(ContactDialog(phone:customerServiceNumber, toggle: $showContactDialog))
            }())
        }
        .onAppear {
            getData()
        }
        .overlay(alignment: .center) {
            ProgressView()
                .isHidden(!isLoading)
        }
        .navigationTitle("Plans")
    }
    
    func getData() {
        Task {
            self.myUser = await LocalInfo().getLocalUser()
            
            self.isLoading = true
            
            // --> Get Plan Data
            self.plans = try! await PlanDao().getPaid()
            
            self.isLoading = false
        }
    }
}

#Preview {
    AppPlans()
}
