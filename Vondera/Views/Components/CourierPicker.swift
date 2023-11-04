//
//  CategoryPicker.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CourierPicker: View {
    @State var items = [Courier]()
    @Binding var selectedOption: Courier?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            if items.isEmpty {
                ProgressView()
            } else {
                List {
                    ForEach(items) { courier in
                        CourierCard(courier: courier)
                            .onTapGesture {
                                selectedOption = courier
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Select Courier")
        .task {
            if let storeId = UserInformation.shared.user?.storeId {
                if let items = try? await CouriersDao(storeId: storeId).getByVisibility() {
                    DispatchQueue.main.async {
                        self.items = items
                    }
                }
            }
        }
    }
}
