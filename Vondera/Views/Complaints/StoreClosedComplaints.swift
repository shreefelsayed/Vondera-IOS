//
//  StoreClosedComplaints.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/05/2024.
//

import SwiftUI
import FirebaseFirestore

class StoreClosedComplaintsVM : ObservableObject {
    @Published var isLoading = false
    @Published var items = [Complaint]()
    
    var lastItem:DocumentSnapshot?
    @Published var hasMore = true
    @Published var isFetching = false
    
    init() {
        Task {
            await loadForFirstTime()
        }
    }
    
    func loadForFirstTime() async {
        self.items.removeAll()
        self.hasMore = true
        self.lastItem = nil
        self.isLoading = false
        self.isFetching = false
        
        
        await fetchData(firstTime: true)
    }
    
    func fetchData(firstTime:Bool) async {
        guard let storeId = UserInformation.shared.user?.storeId, hasMore, !isLoading, !isFetching else { return }
        
        if firstTime {
            self.isLoading = true
        } else {
            self.isFetching = true
        }
        
        do {
            let result = try await ComplaintsDao(storeId: storeId).getComplaintByStatue(statue: "closed", lastSnapShot: lastItem)
            DispatchQueue.main.async {
                self.items.append(contentsOf: result.0)
                self.hasMore = !result.0.isEmpty
                self.lastItem = result.1
                self.isLoading = false
                self.isFetching = false
                print("Got \(result.0.count) Complaints")
            }
        } catch {
            print(error)
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
}

struct StoreClosedComplaints : View {
    @StateObject private var viewModel = StoreClosedComplaintsVM()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.items) { item in
                    ComplaintCard(complaint: item) {
                        closeComplaint(complaint: item)
                    }
                    .tag(item.id)
                    .onAppear {
                        if item == viewModel.items.last, viewModel.hasMore {
                            Task {
                                await viewModel.fetchData(firstTime: false)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadForFirstTime()
        }
        .scrollIndicators(.hidden)
        .willLoad(loading: viewModel.isLoading)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageWithResource(imageResource: .btnComplaints, msg: "Their is no closed complaints in your store")
            }
        }
        .navigationTitle("Closed")
    }
    
    func closeComplaint(complaint:Complaint) {
        guard let user = UserInformation.shared.user else { return }
        
        Task {
            do {
                var data = [
                    "state": complaint.state == "opened" ? "closed" : "opened",
                ]
                
                if complaint.state == "opened" {
                    data["closedName"] = user.name
                    data["closedBy"] = user.id
                }
                
                try await ComplaintsDao(storeId: complaint.storeId).update(id: complaint.id, hashMap: data)
                DispatchQueue.main.async {
                    if let index = viewModel.items.firstIndex(where: {$0.id == complaint.id}) {
                        ToastManager.shared.showToast(msg: complaint.state == "opened" ? "Complaint Closed" : "Complaint Reopened", toastType: .success)
                        self.viewModel.items.remove(at: index)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    StoreClosedComplaints()
}
