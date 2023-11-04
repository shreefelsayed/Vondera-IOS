//
//  StoreCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct StoreCategoryUpdate: View {
    @ObservedObject private var user = UserInformation.shared
    @State private var selectedIndex = 0
    @State private var isSaving = false
    private let categories = CategoryManager().getAll()
    @Environment(\.presentationMode) private var presentationMode

    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible() , spacing: 2), GridItem(.flexible(), spacing: 2)]) {
                    ForEach(categories, id: \.self) { cateogry in
                        StoreCategorySquareCard(isSelected: $selectedIndex, category: cateogry)
                            .frame(maxWidth: .infinity)
                            //.aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
        .padding()
        .task {
            //self.selectedIndex = user.user?.store?.categoryNo ?? 0
        }
        .willProgress(saving: isSaving)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    Task {
                        await update()
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden(isSaving)
        .navigationTitle("Store Category")
    }
    
    func update() async {
        if let myUser = user.user {
            self.isSaving = true
            Task {
                try? await StoresDao().update(id: myUser.storeId, hashMap: ["categoryNo" : selectedIndex])
                
                DispatchQueue.main.async {
                    myUser.store?.categoryNo = selectedIndex
                    UserInformation.shared.updateUser(myUser)
                    self.isSaving = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
}

struct StoreCategorySquareCard : View {
    @Binding var isSelected:Int
    var category:StoreCategory
    
    var body: some View {
        VStack(alignment: .center) {
            if isSelected == category.id {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .aspectRatio(contentMode: .fit)
                        
            } else {
                Image(category.drawableId)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .aspectRatio(contentMode: .fit)
            }
            
            Spacer()
            
            Text(category.nameEn)
                .font(.caption)
                .lineLimit(3, reservesSpace: true)
                
        }
        .foregroundStyle(.white)
        .padding()
        .background(isSelected == category.id ? Color.accentColor : .black.opacity(0.9))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation {
                isSelected = category.id
            }
        }
    }
}

#Preview {
    StoreCategoryUpdate()
}

