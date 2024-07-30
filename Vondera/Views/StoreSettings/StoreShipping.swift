//
//  StoreShipping.swift
//  Vondera
//
//  Created by Shreif El Sayed on 06/07/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

class StoreShippingViewModel : ObservableObject {
    var storeId:String
    
    @Published var store:Store?
    @Published var list = [CourierPrice]()
    @Published var isSaving = false
    @Published var isLoading = false
        
    init(storeId:String) {
        self.storeId = storeId
            
        Task {
            await getData()
        }
    }
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId  else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            guard let store = store else { return }
            DispatchQueue.main.async {
                self.list = store.listAreas?.uniqueElements() ?? []
                self.isLoading = false
            }
        } catch {
            print(error.localizedDescription)
            CrashsManager().addLogs(error.localizedDescription, "Store Shipping")
        }
    }
    
    func update(completion: @escaping (() -> ())) async {
        guard let storeId = UserInformation.shared.user?.storeId  else { return }

        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:[CourierPrice]] = ["listAreas": list.uniqueElements()]
            let encoded: [String: Any]
            encoded = try! Firestore.Encoder().encode(map)
            
            try await StoresDao().update(id: storeId, hashMap: encoded)
            
            
            DispatchQueue.main.async {
                UserInformation.shared.user?.store?.listAreas = self.list.uniqueElements()
                UserInformation.shared.updateUser()
                
                ToastManager.shared.showToast(msg: "Store Shipping info changed", toastType: .success)
                self.isSaving = false
                completion()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            CrashsManager().addLogs(error.localizedDescription, "Store Shipping")
            self.isSaving = false
        }
    }
}

struct StoreShipping: View {
    var govManager = GovsUtil()
    @StateObject var viewModel:StoreShippingViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId:String) {
        self._viewModel = StateObject(wrappedValue: StoreShippingViewModel(storeId: storeId))
    }
    
    var body: some View {
        List {
            // DESC
            Text("Check the governments you ship to, and enter their shipping fees")
                .font(.body)
            
            // HEADER
            HStack {
                Text("Active")
                
                Spacer()
                
                Text("Government")
                
                Spacer()
                
                Text("Shipping Price")
            }
            
            // GOVS
            ForEach(govManager.getDefaultCourierList(), id: \.self) { item in
                HStack(alignment: .center) {
                    Toggle(isOn: Binding(items: $viewModel.list, currentItem: item)) {
                        EmptyView()
                    }
                    .frame(width: 60)
                        

                    Text(item.govName)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        //.frame(maxHeight:  .infinity)
                        .padding(.vertical, 6)
                    
                    let selectedItem = viewModel.list.first(where: { $0 == item })
                    FloatingTextField(title: "Price", text: .constant(""), required: nil, isNumric: true, number: Binding(
                        get: { viewModel.list.contains(where: { place in
                            place.govName == item.govName
                        }) ? (selectedItem?.price ?? 0) : 0 },
                        set: { newValue in
                            if let index = viewModel.list.firstIndex(of: selectedItem!) {
                                viewModel.list[index].price = newValue
                            }
                        }
                    ), isDiabled : !viewModel.list.contains(where: { place in
                        place.govName == item.govName
                    }))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .listStyle(.plain)
        .willLoad(loading: viewModel.isLoading)
        .willProgress(saving: viewModel.isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Areas")
    }
    
    func update() {
        Task {
            await viewModel.update {
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        StoreShipping(storeId: Store.example().ownerId)
    }
}
