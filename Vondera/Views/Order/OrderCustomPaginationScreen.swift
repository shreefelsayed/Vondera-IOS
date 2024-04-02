//
//  OrderCustomPaginationScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/03/2024.
//

import SwiftUI
import FirebaseFirestore

class OrderCustomPaginationViewModel: ObservableObject {
    var statue:String
    var isPaginated:Bool
    
    // Filter Vars
    @Published var filterDisplayed = false
    @Published var filterModel = FilterModel()
    
    // Pagination Values
    @Published var items = [Order]()
    @Published var canLoadMore = true
    @Published var isLoading = false
    @Published var intialDataLoaded = false
    @Published var searchText = ""
    private var lastSnapshot:DocumentSnapshot?
    
    init(statue:String, isPaginated:Bool = true) {
        self.statue = statue
        self.isPaginated = isPaginated
        
        Task {
            await refreshData()
        }
    }
    
    // --> Refresh Data
    func refreshData() async {
        self.items.removeAll()
        self.lastSnapshot = nil
        self.intialDataLoaded = false
        self.isLoading = false
        self.canLoadMore = true
        await getData()
    }
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId, canLoadMore, !isLoading else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            var model = filterModel
            model.filterStatue = [statue]
            let result = try await OrdersDao(storeId: storeId).filterOrders(lastSnapShot: lastSnapshot, isPaginated: isPaginated, sortIndex: "date", desc: true, filterModel: model)
            
            print("Got result for \(statue)")
            DispatchQueue.main.async {
                self.lastSnapshot = result.lastDocument
                self.items.append(contentsOf: result.items)
                self.canLoadMore = (result.items.count >= OrdersDao.pageSize)
                self.intialDataLoaded = true
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    
}

struct OrderCustomPaginationScreen: View {
    // Statue
    let statue:String
    var isPaginated = true
    let navTitle:LocalizedStringKey
    var filterModel = FilterModel()
    
    @State private var selectOrders = false
    @ObservedObject private var viewModel:OrderCustomPaginationViewModel
    
    
    init(statue: String, navTitle: LocalizedStringKey, isPaginated:Bool = true) {
        self.statue = statue
        self.isPaginated = isPaginated
        self.navTitle = navTitle
        self.viewModel = OrderCustomPaginationViewModel(statue: statue, isPaginated: isPaginated)
    }
    
    var body: some View {
        List {
            // --> If not paginated, show the search bar
            if !isPaginated && !viewModel.items.isEmpty {
                SearchBar(text: $viewModel.searchText, hint: "Search \(viewModel.items.count) orders")
            }
            
            SkeltonManager(isLoading: !viewModel.intialDataLoaded, count: 12, skeltonView: OrderCardSkelton())
            
            ForEach($viewModel.items.indices, id: \.self) { index in
                
                if $viewModel.items[index].wrappedValue.filter(searchText: viewModel.searchText) {
                    if isPaginated {
                        OrderCard(order: $viewModel.items[index])
                    } else {
                        OrderCard(order: $viewModel.items[index]) {
                            if !isPaginated {
                                selectOrders.toggle()
                            }
                        }
                    }
                }
                
                if viewModel.canLoadMore && viewModel.items.last?.id == viewModel.items[index].id && isPaginated && viewModel.intialDataLoaded {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await getData()
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .padding()
        .overlay {
            if viewModel.intialDataLoaded && viewModel.items.isEmpty {
                EmptyMessageWithResource(imageResource: Order.getNotFoundResource(statue: statue), msg: Order.getNotFoundMessage(statue: statue))
            }
        }
        .refreshable {
            await refreshData()
        }
        .overlay {
            if viewModel.filterDisplayed {
                FilterScreen(currentlyFiltered: viewModel.filterModel, filterDisplayed: $viewModel.filterDisplayed, showStatue: false) { model in
                    DispatchQueue.main.async {
                        viewModel.filterModel = model
                    }
                    
                    Task {
                        await refreshData()
                    }
                }
            }
        }
        .sheet(isPresented: $selectOrders) {
            NavigationStack {
                OrderSelectView(list: $viewModel.items)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .bold()
                    .onTapGesture {
                        viewModel.filterDisplayed.toggle()
                    }
                    .overlay {
                        let count = viewModel.filterModel.filtersCount()
                        if count > 0 {
                            Text("\(count)")
                                .foregroundColor(.white)
                                .font(.caption)
                                .bold()
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor)
                                        .foregroundStyle(Color.accentColor)
                                )
                                .offset(x: 8, y: -8)
                            
                        }
                    }
            }
            
        }
        .navigationTitle(navTitle)
    }
    
    func getOrdersCount() -> Int {
        return viewModel.items.count
    }
    
    
    // --> Load data
    func getData() async {
        await viewModel.getData()
    }
    
    // --> Refresh Data
    func refreshData() async {
        await viewModel.refreshData()
    }
    
    func print() {
        Task {
            if !viewModel.items.isEmpty, let uri = await ReciptPDF(orderList: viewModel.items).render() {
                DispatchQueue.main.async {
                    FileUtils().shareFile(url: uri)
                }
            }
        }
    }
}
