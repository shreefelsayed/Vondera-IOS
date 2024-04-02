//
//  ReviewCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/03/2024.
//

import SwiftUI

struct ReviewCard: View {
    var review:ReviewModel
    var onDeleted:(() -> ())?
    @State var showWarning = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(review.name)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                }
                
                Text(review.date.toString())
                    .foregroundStyle(.secondary)
               
                StarRatingView(rating: review.rating)
                
                Text(review.review)
                    .foregroundStyle(.secondary)
            }
            
            Image(.btnDelete)
                .onTapGesture {
                    showWarning.toggle()
                }
        }
        .confirmationDialog("Delete Review", isPresented: $showWarning, actions: {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                if let onDeleted = onDeleted {
                    onDeleted()
                }
            }
        }, message: {
            Text("Are you sure you want to delete this review ?")
        })
        .cardView()
    }
}

struct StarRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack {
            ForEach(1..<6) { index in
                Image(systemName: self.imageName(for: index))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.yellow)
            }
        }
    }
    
    func imageName(for index: Int) -> String {
        if Double(index) <= self.rating {
            return "star.fill"
        } else if Double(index) - 0.5 <= self.rating {
            return "star.leadinghalf.fill"
        } else {
            return "star"
        }
    }
}

#Preview {
    List {
        ReviewCard(review: ReviewModel.example())
        ReviewCard(review: ReviewModel.example())
        ReviewCard(review: ReviewModel.example())
    }
    
}
