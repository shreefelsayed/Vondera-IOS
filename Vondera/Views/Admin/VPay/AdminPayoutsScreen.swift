//
//  AdminPayoutsScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class AdminPayoutsVM : ObservableObject {
    @Published var isLoading = true
    @Published var items = [VPayout]()
    
    init() {
        isLoading = true
        Task { await fetch() }
    }
    
    func fetch() async {
        isLoading = true
        
        do {
            let result = try await Firestore.firestore()
                .collectionGroup("vPayouts")
                .whereField("statue", isEqualTo: "Pending")
                .order(by: "date", descending: true)
                .getDocuments(as: VPayout.self)
            
            DispatchQueue.main.async {
                self.items = result
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
}
struct AdminPayoutsScreen: View {
    @StateObject private var viewModel = AdminPayoutsVM()
    @State private var selectedObject:VPayout?
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.items, id: \.id) { request in
                    PayoutCardView(item: request)
                        .onTapGesture {
                            selectedObject = request
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Payouts")
        .willLoad(loading: viewModel.isLoading)
        .overlay {
            if viewModel.items.isEmpty, !viewModel.isLoading {
                Text("No New payout requests")
            }
        }
        .refreshable {
            await viewModel.fetch()
        }
        .sheet(item: $selectedObject) { item in
            PayoutDetail(payout: item, onAction: {
                if let index = viewModel.items.firstIndex(where: {$0.id == item.id}) {
                    withAnimation {
                        viewModel.items.remove(at: index)
                    }
                }
            })
            .presentationDetents([.medium])
        }
    }
}


struct PayoutDetail : View {
    var payout:VPayout
    var onAction:(()->())
    @State private var statue = "Pending"
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            Text("Payout request")
                .font(.title2)
                .bold()
            
            HStack {
                Text("Identifer")
                
                Spacer()
                
                Text(payout.identifier)
                    .bold()
                    .onTapGesture {
                        CopyingData().copyToClipboard(payout.identifier)
                    }
                
                Image(systemName: "doc.on.clipboard")
            }
            
            Divider()
            
            HStack {
                Text("Amount")
                
                Spacer()
                
                Text("\(payout.amount.toString()) EGP")
                    .bold()
                    .onTapGesture {
                        CopyingData().copyToClipboard(payout.amount.toString())
                    }
                
                Image(systemName: "doc.on.clipboard")
            }
            
            Divider()
            
            HStack {
                Text("Method")
                
                Spacer()
                
                Text(payout.method)
                
                Image(systemName: "doc.on.clipboard")
            }
            
            Divider()
            
            HStack {
                Text("Date")
                
                Spacer()
                
                Text(payout.date.toDate().formatted())
            }
            
            Divider()
            
            HStack {
                Text("Action")
                
                Spacer()
                
                Picker("Action", selection: $statue) {
                    Text("Payment Success")
                        .tag("Success")
                    
                    Text("Pending")
                        .tag("Pending")
                    
                    Text("Failed")
                        .tag("Failed")
                    
                    Text("Cancelled")
                        .tag("Cancelled")
                }
            }
            
            ButtonLarge(label: "Update Payment") {
                Task { await updatePayment() }
            }
        }
        .padding()
        .willProgress(saving: isSaving, msg: "Upading payout ..")
    }
    
    private func updatePayment() async {
        isSaving = true
        let hash:[String:Any] = ["statue": statue, "by": UserInformation.shared.user?.name as Any]
        do {
            
            try await Firestore.firestore().collection("stores").document(payout.storeId).collection("vPayouts")
                .document(payout.id).updateData(hash)
            
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Payout Updated")
                if statue != "Pending" {
                    self.onAction()
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            print(error)
        }
    }
}
#Preview {
    AdminPayoutsScreen()
}
