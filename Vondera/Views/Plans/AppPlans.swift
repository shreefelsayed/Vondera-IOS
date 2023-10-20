//
//  AppPlans.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI

struct AppPlans: View {
    @ObservedObject var myUser = UserInformation.shared
    @State var currentPlanId = ""
    
    @StateObject var storeVM = StoreVM()
    @State var plans:[Plan] = []
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            if let myUser = myUser.getUser() {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Choose your plan")
                            .font(.title3)
                            .bold()
                                        
                        // MARK : PLANS
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack() {
                                ForEach(plans) { plan in
                                    ChoosePlanCard(plan: plan, currentPlan: $currentPlanId) {
                                        subscribe(plan.id ?? "")
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        
                        //
                    }
                }
                .padding()
            }
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
    
    func subscribe(_ planId:String) {
        Task {
            do {
                let result = try await storeVM.purchase(planId: planId)
                isLoading = true
                if result {
                    await refreshData()
                }
                isLoading = false
            } catch {
                print("Error happened")
            }
        }
    }
    
    func getData() {
        Task {
            self.isLoading = true
            self.plans = try! await PlanDao().getPaid()
            await refreshData()
            self.isLoading = false
        }
    }
    
    func refreshData() async {
        guard let id = myUser.user?.id else {
            return
        }
        
        guard let user = await reloadUser() else {
            print("Couldn't get user with \(id)")
            return
        }
        
        DispatchQueue.main.async {
            self.currentPlanId = user.store?.subscribedPlan?.planId ?? ""
            UserInformation.shared.updateUser(user)
            self.isLoading = false
        }
        
    }
    
    func reloadUser() async -> UserData? {
        // id
        guard let id = myUser.user?.id else {
            return nil
        }
        
        return try? await UsersDao().getUserWithStore(userId: id)
    }
}

#Preview {
    AppPlans()
}
