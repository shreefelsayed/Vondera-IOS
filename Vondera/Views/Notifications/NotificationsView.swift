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
    @Published var error = ""
    
    private var lastSnapshot:DocumentSnapshot?
    
    init() {
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        DispatchQueue.main.async {
            self.items.removeAll()
        }
        
        self.isLoading = false
        self.canLoadMore = true
        self.lastSnapshot = nil
        await getData()
    }
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            if let id = UserInformation.shared.user?.id {
                let result = try await NotificationsDao(userId: id).getNotifications(lastSnapshot: lastSnapshot)
                
                DispatchQueue.main.async {
                    self.lastSnapshot = result.lastDocument
                    self.items.append(contentsOf: result.items)
                    if result.items.count == 0 {
                        self.canLoadMore = false
                    }
                }
            }
        } catch {
            print(String(describing: error))
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

struct NotificationsView: View {
    @ObservedObject var viewModel = NotificationsViewModel()
    
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
                let notificationId = viewModel.items[index.first ?? 0].id
                withAnimation {
                    viewModel.items.remove(atOffsets: index)
                }
                
                Task {
                    if let id = UserInformation.shared.user?.id {
                        await NotificationsDao(userId: id).removeNotification(id: notificationId)
                    }
                }
            }
            
            
        }
        .refreshable {
            await refreshData()
        }
        .listStyle(.plain)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(systemName: "bell.slash", msg: "No notifications")
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Notifications")
    }
    
    func refreshData() async {
        await viewModel.refreshData()
    }
    
    func loadItem() {
        Task {
            await viewModel.getData()
        }
    }
}

struct NotificationCard : View {
    var notification:NotificationModel
    
    var body: some View {
        HStack {
            VStack(alignment:.leading) {
                HStack {
                    Text(notification.title)
                        .font(.title3)
                        .bold()
                    
                    
                    Spacer()
                    
                    if !notification.read {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                
                
                Text(notification.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Spacer()
                    
                    Text(notification.date.toString())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
            }
            
            Spacer()
        }
        .padding(12)
        .background(notification.read ? Color.background : .secondary.opacity(0.2))
        .task {
            if let id = UserInformation.shared.user?.id {
                try? await NotificationsDao(userId: id).markAsRead(id: notification.id)
            }
        }
    }
}
#Preview {
    NotificationsView()
}
