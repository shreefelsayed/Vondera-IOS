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
                Text(store.subscribedPlan?.planName ?? "")
                    .bold()
                
                Spacer()
                
                NavigationLink("Change your plan") {
                    AppPlans()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(Color.accentColor)
            }
            
            ProgressView(value: Float(((store.subscribedPlan?.currentOrders ?? 0) / (store.subscribedPlan?.maxOrders ?? 0))))
                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: .infinity)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.vertical, 4)
                
            
            HStack {
                Text("Monthly Limit")
                    .bold()
                
                Spacer()
                
                Text("\(store.subscribedPlan?.currentOrders ?? 0) Of \(store.subscribedPlan?.maxOrders ?? 0) Orders")
            }
            
            Divider()
            
            HStack {
                Text("Expire Date")
                    .bold()
                
                Spacer()
                
                Text("\(store.subscribedPlan!.expireDate.toFirestoreTimestamp().toString())")
            }
            
        }
    }
}

struct PlanCard_Previews: PreviewProvider {
    static var previews: some View {
        PlanCard(store: Store.example())
    }
}
