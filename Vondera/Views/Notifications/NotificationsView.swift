//
//  NotificationsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/10/2023.
//

import SwiftUI
import FirebaseFirestore

class NotificationsViewModel : ObservableObject {
    @Published var items = [NotificationModel]()
    @Published var isLoading = false
    @Published var canLoadMore = true
    
    private var lastSnapshot:DocumentSnapshot?
    
    init() {
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        self.items.removeAll()
        self.isLoading = false
        self.canLoadMore = true
        self.lastSnapshot = nil
        await getData()
    }
    
    func getData() async {
        guard !isLoading, canLoadMore, let id = UserInformation.shared.user?.id else {
            return
        }
        
        self.isLoading = true
        
        do {
            let result = try await NotificationsDao(userId: id).getNotifications(lastSnapshot: lastSnapshot)
            
            DispatchQueue.main.async {
                self.lastSnapshot = result.lastDocument
                self.canLoadMore = !result.items.isEmpty
                self.items.append(contentsOf: result.items)
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
    
    func deleteItem(index:Int) {
        guard let id = UserInformation.shared.user?.id else { return }
        
        let notificationId = items[index].id
        items.remove(at: index)
        
        Task {
            await NotificationsDao(userId: id).removeNotification(id: notificationId)
        }
    }
}

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NotificationCard(notification: item)
                    .listRowInsets(EdgeInsets())
                
                if viewModel.canLoadMore && viewModel.items.last?.id == item.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .onAppear {
                        loadItem()
                    }
                }
            }
            .onDelete { index in
                withAnimation {
                    viewModel.deleteItem(index: index.first ?? 0)
                }
            }
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(systemName: "bell.slash", msg: "No notifications")
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Notifications")
    }
    
    func loadItem() {
        Task {
            await viewModel.getData()
        }
    }
}

#Preview {
    NotificationsView()
}
