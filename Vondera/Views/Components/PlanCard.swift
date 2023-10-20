//
//  PlanCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 06/07/2023.
//

import SwiftUI

struct PlanCard: View {
    var store:Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                
                
                NavigationLink {
                    AppPlans()
                } label: {
                    HStack {
                        Text(store.subscribedPlan?.planName ?? "")
                            .bold()
                        
                        Spacer()
                        
                        Text("Change Plan")
                            .bold()
                    }
                }
                .buttonStyle(.plain)
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
    }
}

struct PlanCard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlanCard(store: Store.example())
                .padding()
        }
        
    }
}
