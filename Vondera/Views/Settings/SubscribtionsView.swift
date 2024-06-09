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
            if let plan = UserInformation.shared.user?.store?.storePlanInfo {
                SubscribtionCard(plan: plan)
            }
        }
        .padding()
        .navigationTitle("Subscribtions")
    }
}

struct SubscribtionCard : View {
    var plan:StorePlanInfo
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Your plan")
                        
                        Text(plan.name)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Image(.icLogoWhite)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color(hex: plan.getColorHex()))
                
                VStack(alignment: .leading) {
                    Text("Your next bill we be on \(plan.expireDate.toString(format: "yyyy MMMM, dd"))")
                    
                    HStack {
                        Spacer()
                        
                        if !plan.isFreePlan() {
                            NavigationLink {
                                AppPlans()
                            } label: {
                                Text("Renew Now !")
                                    .font(.headline)
                                    .padding(6)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                }
                .padding()
                .background(.white)
               
            }
            .cornerRadius(24)
            
            HStack {
                NavigationLink {
                    AppPlans()
                } label: {
                    Text("Change Plan")
                        .font(.headline)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1.5))
                }
                .buttonStyle(.plain)

                
                
                Spacer()
                
                Button(action: {
                    Task {
                        await manageSubscriptions()
                    }
                }, label: {
                    Text("Unsubscribe")
                })
                .foregroundColor(.white)
                .font(.headline)
                .padding(6)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
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

#Preview {
    SubscribtionCard(plan: StorePlanInfo())
}
