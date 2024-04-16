//
//  PlanCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 06/07/2023.
//

import SwiftUI

struct PlanCard: View {
    var store:Store
    @State private var showPlans = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let plan = store.storePlanInfo {
                HStack {
                    Text(plan.name)
                        .bold()
                    
                    Spacer()
                    
                    Text("Change Plan")
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            showPlans.toggle()
                        }
                }
                
                
                HStack {
                    ProgressView(value: plan.getPercentage())
                        .accentColor(
                            (plan.isUsageAlert()) ?
                            Color.red : Color.accentColor
                        )
                        .frame(maxWidth: .infinity)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.vertical, 4)
                    
                    Text("\(Int((plan.getPercentage() * 100) ))%")
                        .font(.caption)
                    
                }
                
                HStack {
                    Text("Monthly Limit")
                        .bold()
                    
                    Spacer()
                    
                    Text("\(plan.planFeatures.currentOrders) Of \(plan.planFeatures.maxOrders ) Orders")
                        .foregroundStyle( (plan.isUsageAlert()) ? .red : .secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Expire Date")
                        .bold()
                    
                    Spacer()
                    
                    Text("\(plan.expireDate.toString())")
                        .foregroundStyle( (plan.isDateAlert()) ? .red : .secondary)
                }
            }
            
            
        }
        .navigationDestination(isPresented: $showPlans, destination: {
            AppPlans()
        })
    }
}

#Preview {
    PlanCard(store: Store.example())
        .padding()
}
