//
//  MarketPlaceOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/10/2023.
//

import SwiftUI
import FirebaseFirestore


class MarketPlaceOrdersVM : ObservableObject {
    var marketPlaceId:String
    @Published var items = [Order]()
    @Published var isLoading = true
    @Published var lastSnapshot:DocumentSnapshot?
    @Published var msg:LocalizedStringKey?
    @Published var canLoadMore = true

    init(marketPlaceId: String) {
        self.marketPlaceId = marketPlaceId
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        self.isLoading = false
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await getData()
    }
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        self.isLoading = true
        
        do {
            if let storeId = UserInformation.shared.user?.storeId {
                let result = try await OrdersDao(storeId: storeId).getMarketPlaceOrders(marketId: marketPlaceId, lastSnapShot: lastSnapshot)
                
                DispatchQueue.main.async {
                    self.lastSnapshot = result.lastDocument
                    self.items.append(contentsOf: result.items)
                    
                    if result.items.count == 0 {
                        self.canLoadMore = false
                    }
                }
            }
            
        } catch {
            self.msg = LocalizedStringKey(error.localizedDescription)
        }
        
        self.isLoading = false
    }
}

struct MarketPlaceOrders: View {
    var marketPlaceId:String
    @ObservedObject var viewModel:MarketPlaceOrdersVM
    
    init(marketPlaceId: String) {
        self.marketPlaceId = marketPlaceId
        viewModel = MarketPlaceOrdersVM(marketPlaceId: marketPlaceId)
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items) { order in
                OrderCard(order: order)
                
                if viewModel.canLoadMore && viewModel.items.last?.id == order.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        loadItem()
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await refreshData()
        }
        .toolbar {
            NavigationLink {
                MarketPlaceReport(marketPlaceId: marketPlaceId)
            } label: {
                Image(systemName: "filemenu.and.selection")
                    .font(.callout)
                    .bold()
            }
        }
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "No orders from this marketplace")
            }
        }
        .navigationTitle(MarketsManager().getById(id: marketPlaceId)?.name ?? "")
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
