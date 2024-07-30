//
//  StoreComplaints.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/05/2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class StoreComplaintsVM : ObservableObject {
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
            let result = try await ComplaintsDao(storeId: storeId).getComplaintByStatue(statue: "opened", lastSnapShot: lastItem)
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

struct StoreComplaints : View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = StoreComplaintsVM()
    
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
                EmptyMessageWithResource(imageResource: .btnComplaints, msg: "Thank god, no complaints are added to your orders")
            }
        }
        .navigationTitle("Complaints")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    StoreClosedComplaints()
                } label: {
                    Text("Closed")
                }
            }
        }
        .withAccessLevel(accessKey: .complaintsRead, presentation: presentationMode)
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

struct ComplaintCard : View {
    var complaint:Complaint
    var onClosed:(() -> ())
    
    @State private var openSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink("# \(complaint.id)", destination: {
                OrderDetailLoading(id: complaint.id)
            })
            .font(.headline)
            .buttonStyle(.plain)
            
            Text(complaint.desc)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(complaint.listPhotos, id: \.self) { photo in
                        NavigationLink {
                            CachedImageView(imageUrl: photo)
                        } label: {
                            CachedImageView(imageUrl: photo)
                                .frame(width: 80, height: 80)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .tag(photo)
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            // Close it button
            ButtonLarge(label: complaint.state == "opened" ? "Close Complaint" : "Reopen Complaint") {
                onClosed()
            }
        }
        .cardView()
        .sheet(isPresented: $openSheet, content: {
            NavigationStack {
                ComplaintSheet(complaint: complaint, onButtonClicked: onClosed)
            }
            .presentationDetents([.medium, .large])
        })
    }
}

struct ComplaintSheet : View {
    @Environment(\.presentationMode) private var presentationMode
    var complaint:Complaint
    var onButtonClicked:(()->())
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink("# \(complaint.id)", destination: {
                OrderDetailLoading(id: complaint.id)
            })
            .font(.headline)
            .buttonStyle(.plain)
            
            Text("Complaint by : \(complaint.byName)")
                .bold()
            
            if complaint.state == "closed" {
                Text("Closed by : \(complaint.closedName)")
                    .bold()
            }
            
            Text(complaint.desc)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal) {
                ForEach(complaint.listPhotos, id: \.self) { photo in
                    NavigationLink {
                        CachedImageView(imageUrl: photo)
                    } label: {
                        CachedImageView(imageUrl: photo)
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .tag(photo)
                }
            }
            .scrollIndicators(.hidden)
            
            // Close it button
            ButtonLarge(label: complaint.state == "opened" ? "Close Complaint" : "Reopen Complaint") {
                onButtonClicked()
            }
        }
        .navigationTitle("Complaint Details")
        .withAccessLevel(accessKey: .complaintsUpdate, presentation: presentationMode)

    }
}

#Preview {
    StoreComplaints()
}
