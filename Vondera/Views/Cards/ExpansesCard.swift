//
//  CategoryLinearAdapter.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct ExpansesSkeleton : View {
    var body: some View {
        HStack {
            SkeletonCellView(isDarkColor: true)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                SkeletonCellView(isDarkColor: true)
                    .frame(width: 80, height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
                
                SkeletonCellView(isDarkColor: false)
                    .frame(height: 15)
            }
        }
        .cardView()
    }
}
struct ExpansesCard: View {
    @Binding var expanse:Expense
    var onDelete:(() -> ())
    var onClicked:(() -> ())
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                // MARK : ICON
                Image(.btnExpanses)
                
                // MARK : DATA
                VStack(alignment: .leading) {
                    Text("\(expanse.amount) EGP")
                        .font(.body)
                        .bold()
                    
                    Text(expanse.description)
                        .font(.body)
                    
                    Text(expanse.date.toString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    onClicked()
                }
            }
            
            Spacer()
            
            // MARK : Delete
            Image(systemName: "trash.fill")
                .foregroundColor(.white)
                .padding(4)
                .background(
                    Circle()
                        .fill(Color.red)
                        .foregroundColor(.red)
                )
                .onTapGesture {
                    onDelete()
                }
        }
        .cardView()
    }
}

#Preview {
    List {
        ExpansesCard(expanse: .constant(Expense.example())) {
            
        } onClicked: {
            
        }
        
        ExpansesCard(expanse: .constant(Expense.example())) {
            
        } onClicked: {
            
        }
        
        ExpansesSkeleton()
        
        ExpansesSkeleton()
    }
    

}
