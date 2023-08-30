//
//  CategoryPicker.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CourierPicker: View {
    let storeId:String
    @State var items = [Courier]()
    @Binding var selectedOption: Courier?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            if items == nil || items.isEmpty {
                ProgressView()
            } else {
                ScrollView (showsIndicators: false) {
                    VStack {
                        ForEach(items) { courier in
                            CourierCard(courier: courier)
                                .onTapGesture {
                                    selectedOption = courier
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }
                    }
                    
                }
            }
        }
        .padding()
        .navigationTitle("Select Courier")
        .onAppear {
            Task {
                items = try! await CouriersDao(storeId: storeId).getByVisibility()
            }
        }
    }
}
