//
//  CategoryPicker.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CourierPicker: View {
    @Binding var selectedOption: Courier?
    
    @State private var items = [Courier]()
    @State private var isLoading = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { courier in
                    CourierCard(courier: courier)
                        .onTapGesture {
                            self.selectedOption = courier
                            self.presentationMode.wrappedValue.dismiss()
                        }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Select Courier")
        .overlay {
            if !isLoading, items.isEmpty {
                EmptyMessageWithResource(imageResource: .btnShipping, msg: "You have no couriers yet !")
            }
        }
        .willLoad(loading: isLoading)
        .task {
            await fetchData()
        }
    }
    
    private func fetchData() async {
        if let storeId = UserInformation.shared.user?.storeId {
            self.isLoading = true
            if let items = try? await CouriersDao(storeId: storeId).getByVisibility() {
                DispatchQueue.main.async {
                    self.items = items
                    self.isLoading = false
                }
            }
        }
    }
}
