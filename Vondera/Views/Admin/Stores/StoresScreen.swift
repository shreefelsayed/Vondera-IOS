//
//  StoresScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class StoreScreenVM : ObservableObject {
    @Published var isLoading = false
    @Published var isFetching = false
    
    
    
    var lastDoc:DocumentSnapshot? = nil
    var hasMore = true
    var items = [Store]()
    
    @Published var sorting = "date" {
        didSet {
            lastDoc = nil
            items.removeAll()
            hasMore = true
            isFetching = false
            Task { await fetch() }
        }
    }
    
    init() {
        Task {
            await fetch()
        }
    }
    
    func fetch() async {
        guard hasMore, !isLoading, !isFetching else { return }
        
        isLoading = lastDoc == nil
        isFetching = lastDoc != nil
        
        do {
            let result = try await StoresDao().getStores(lastSnapshot: lastDoc, sorting: sorting)
            DispatchQueue.main.async {
                self.hasMore = !result.0.isEmpty
                self.items.append(contentsOf: result.0)
                self.lastDoc = result.1
                self.isLoading = false
                self.isFetching = false
            }
        } catch {
            print(error)
        }
    }
}

struct StoresScreen: View {
    @StateObject private var viewModel = StoreScreenVM()
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.ownerId) { store in
                VStack {
                    NavigationLink {
                        StoresProfileScreen(id: store.ownerId)
                    } label: {
                        StoreCard(store: store)
                    }
                    .buttonStyle(.plain)

                    if store.ownerId == viewModel.items.last?.ownerId && viewModel.hasMore {
                        ProgressView()
                            .onAppear {
                                Task { await viewModel.fetch() }
                            }
                    }
                }
                
            }
        }
        .willLoad(loading: viewModel.isLoading)
        .navigationTitle("Stores")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    StoresSearchScreen()
                } label: {
                    Image(systemName: "magnifyingglass.circle")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sorting", selection: $viewModel.sorting) {
                        Text("Date")
                            .tag("date")
                        
                        Text("Store Name")
                            .tag("name")
                        
                        Text("Last Order")
                            .tag("lastOrder")
                        
                        Text("Site Views")
                            .tag("siteCounter.site")
                        
                        Text("Monthly Active")
                            .tag("storePlanInfo.currentOrders")
                        
                        Text("Orders Count")
                            .tag("ordersCount")
                        
                        Text("Products Count")
                            .tag("productsCount")
                        
                        Text("Merchant Id")
                            .tag("merchantId")
                    }
                } label: {
                    Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
                }

                
                    
            }
        }
    }
}

#Preview {
    StoresScreen()
}

struct StoreCard : View {
    var store:Store
    
    var body: some View {
        
        HStack {
            CachedImageView(imageUrl: store.logo ?? "", placeHolder: UIImage(resource: .appIcon))
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("#\(store.merchantId)")
                        .font(.caption)
                        .bold()
                    
                    Text("\(store.date.formatted())")
                        .font(.caption)
                }
                
                Text(store.name)
                    .font(.body)
                    .bold()
                
                Text(store.storePlanInfo?.name ?? "Free")
            }
            
            Spacer()
        }
    }
}
