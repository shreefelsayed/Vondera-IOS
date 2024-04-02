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
            HStack {
                Text(store.subscribedPlan?.planName ?? "")
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
                ProgressView(value: store.subscribedPlan?.getPercentage() ?? 0)
                    .accentColor(
                        (store.subscribedPlan?.isUsageAlert() ?? false) ?
                        Color.red : Color.accentColor
                    )
                    .frame(maxWidth: .infinity)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.vertical, 4)
                
                Text("\(Int(((store.subscribedPlan?.getPercentage() ?? 0) * 100)))%")
                    .font(.caption)
                
            }
            
            HStack {
                Text("Monthly Limit")
                    .bold()
                
                Spacer()
                
                Text("\(store.subscribedPlan?.currentOrders ?? 0) Of \(store.subscribedPlan?.maxOrders ?? 0) Orders")
                    .foregroundStyle( (store.subscribedPlan?.isUsageAlert() ?? false) ? .red : .secondary)
            }
            
            Divider()
            
            HStack {
                Text("Expire Date")
                    .bold()
                
                Spacer()
                
                Text("\(store.subscribedPlan!.expireDate.toFirestoreTimestamp().toString())")
                    .foregroundStyle( (store.subscribedPlan?.isDateAlert() ?? false) ? .red : .secondary)
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
