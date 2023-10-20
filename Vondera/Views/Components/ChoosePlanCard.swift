//
//  ChoosePlanCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI

struct ChoosePlanCard: View {
    var plan:Plan
    @Binding var currentPlan:String
    var onSubscribeClciked:(() -> ())
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            HStack {
                Text(plan.planName)
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            
            
            ForEach(plan.features, id: \.self) { feature in
                HStack {
                    Text(feature.name)
                        .bold()
                    
                    Spacer()
                    
                    if feature.available {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            
            if currentPlan == plan.id {
                Text("Current Plan")
                    .foregroundColor(.accentColor)
                    .bold()
            } else {
                ButtonLarge(label: "\(plan.price) LE / Monthly") {
                    onSubscribeClciked()
                }
            }
            
        }
        .padding()
        .background(Color.background)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


