//
//  FilteredOrdersView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/03/2024.
//

import SwiftUI
import Flow

struct FilteredOrdersView: View {
    @State private var filterModel = FilterModel()
    @State private var sortIndex = "date"
    @State private var desc = true
    
    @State private var items = [Order]()
    @State private var isLoading = false
    @State private var filterDisplayed = false
    
    var body: some View {
        List {
            SkeltonManager(isLoading: isLoading, count: 4, skeltonView: OrderCardSkelton())
            
            ForEach($items) { order in
                OrderCard(order: order)
            }
        }
        .refreshable {
            await getData()
        }
        .task {
            await getData()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter") {
                    withAnimation {
                        filterDisplayed.toggle()
                    }
                }
            }
        }
    }
    
    private func getData() async {
        guard let storeId = UserInformation.shared.getUser()?.store?.ownerId else {
            return
        }
        
        self.isLoading = true
        print("Getting result for new request \(filterModel.toString())")
        do {
            let result = try await OrdersDao(storeId: storeId).filterOrders(lastSnapShot: nil, sortIndex: "date", desc: true, filterModel: filterModel)
            
            print("Got \(result.items.count) Result")
            DispatchQueue.main.async {
                self.items = result.items
                self.isLoading = false
            }
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Filter Orders")
            print(error.localizedDescription)
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

struct FilterScreen: View {
    var currentlyFiltered:FilterModel
    @Binding var filterDisplayed:Bool
    
    var showStatue:Bool = true
    var showMarketPlace:Bool = true
    var showTeam:Bool = true
    var showGovs:Bool = true
    var showCouriers:Bool = true
    var showPayments:Bool = true
    var showShipping:Bool = true
    
    var onFiltered:((FilterModel) -> ())
    
    

    @State private var isLoading = false
    @State private var screenFiltered = FilterModel()
    @State private var listUsers = [UserData]()
    @State private var listCouriers = [Courier]()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            if isLoading {
                ProgressView()
                    .frame(alignment: .center)
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        // Header
                        HStack {
                            Text("Filters")
                                .font(.title3)
                                .bold()
                            
                            Spacer()
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    withAnimation {
                                        filterDisplayed = false
                                    }
                                }
                        }
                        
                        Divider()
                            .padding(.bottom, 18)
                        
                        
                        // FILTERS
                        LazyVStack(alignment: .leading) {
                            if showStatue {
                                Text("Order Statue")
                                    .bold()
                                HFlow {
                                    ForEach(OrderStatues.allCases, id: \.rawValue) { statue in
                                        HighlightedTag(title: statue.rawValue, isSelected: screenFiltered.filterStatue.contains(statue.rawValue)) { selected in
                                            screenFiltered.filterStatue.removeOrAdd(statue.rawValue)
                                        }
                                    }
                                }
                                
                                Spacer().frame(height: 12)
                            }
                            
                            
                            if let storeMarkets = UserInformation.shared.user?.store?.listMarkets, !MarketsManager().getEnabledMarketsWithWebsite(storeMarkets: storeMarkets).isEmpty, showMarketPlace  {
                                Text("Market Places")
                                    .bold()
                                
                                HFlow {
                                    ForEach(MarketsManager().getEnabledMarketsWithWebsite(storeMarkets: storeMarkets), id: \.id) { item in
                                        HighlightedTag(title: item.name, isSelected: screenFiltered.filterMarkets.contains(item.id)) { selected in
                                            screenFiltered.filterMarkets.removeOrAdd(item.id)
                                        }
                                    }
                                }
                                
                                Spacer().frame(height: 12)
                            }
                            
                            
                            
                            if !listUsers.isEmpty, showTeam {
                                Text("Team members")
                                    .bold()
                                HFlow {
                                    ForEach(listUsers, id: \.id) { item in
                                        HighlightedTag(title: item.name, isSelected: screenFiltered.filterUsers.contains(item.id)) { selected in
                                            screenFiltered.filterUsers.removeOrAdd(item.id)
                                        }
                                    }
                                }
                                
                                Spacer().frame(height: 12)
                            }
                            
                            
                            if let govs = UserInformation.shared.user?.store?.listAreas, !govs.isEmpty, showGovs {
                                Text("Governments")
                                    .bold()
                                HFlow {
                                    ForEach(govs, id: \.govName) { item in
                                        HighlightedTag(title: item.govName, isSelected: screenFiltered.filterGovs.contains(item.govName)) { selected in
                                            screenFiltered.filterGovs.removeOrAdd(item.govName)
                                        }
                                    }
                                }
                                
                                Spacer().frame(height: 12)
                            }
                           
                            if !listCouriers.isEmpty, showCouriers {
                                Text("Couriers")
                                    .bold()
                                HFlow {
                                    ForEach(listCouriers, id: \.id) { item in
                                        HighlightedTag(title: item.name, isSelected: screenFiltered.filterCouriers.contains(item.id)) { selected in
                                            screenFiltered.filterCouriers.removeOrAdd(item.id)
                                        }
                                    }
                                }
                                Spacer().frame(height: 12)
                            }
                            
                            /*if showPayments {
                                Text("Payment Statue")
                                    .bold()
                                HFlow {
                                    HighlightedTag(title: "Paid", isSelected: screenFiltered.filterPaid.contains(true)) { selected in
                                        screenFiltered.filterPaid.removeOrAdd(true)
                                    }
                                    
                                    HighlightedTag(title: "Not Paid", isSelected: screenFiltered.filterPaid.contains(false)) { selected in
                                        screenFiltered.filterPaid.removeOrAdd(false)
                                    }
                                }
                                Spacer().frame(height: 12)
                            }*/
                            
                            if let onlyDelivery = UserInformation.shared.user?.store?.offlineStore, !onlyDelivery, showShipping {
                                Text("Require Shipping")
                                    .bold()
                                
                                HFlow {
                                    HighlightedTag(title: "Require Shipping", isSelected: screenFiltered.filterShipping.contains(true)) { selected in
                                        screenFiltered.filterShipping.removeOrAdd(true)
                                    }
                                    
                                    HighlightedTag(title: "Pick up", isSelected: screenFiltered.filterShipping.contains(false)) { selected in
                                        screenFiltered.filterShipping.removeOrAdd(false)
                                    }
                                }
                            }
                            
                        }
                        
                        Divider()
                        
                        // Buttons
                        HStack {
                            Spacer()
                            
                            Button("Clear") {
                                screenFiltered = FilterModel()
                                onFiltered(screenFiltered)
                                filterDisplayed.toggle()
                            }
                            .padding(.trailing, 24)
                            .foregroundColor(.black)
                            
                            Button("Filter") {
                                onFiltered(screenFiltered)
                                filterDisplayed.toggle()
                            }
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.accentColor)
                            .cornerRadius(6)
                            
                            
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .padding()
                }
            }
            
            
        }
        .task {
            await initItems()
        }
    }
    
    private func getData() async {
        guard let storeId = UserInformation.shared.getUser()?.storeId else {
            return
        }
        
        await MainActor.run { self.isLoading = true }
        
        do {
            let usersResult = try await UsersDao().storeEmployees(expect: "", storeId: storeId, active: true)
            let couriersResult = try await CouriersDao(storeId: storeId).getByVisibility()
            await MainActor.run {
                self.listUsers = usersResult
                self.listCouriers = couriersResult
                self.isLoading = false
            }
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Filter Orders")
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    
    private func initItems() async {
        await self.getData()
        await MainActor.run { self.screenFiltered = currentlyFiltered }
    }
}

struct HighlightedTag : View {
    var title:String
    var isSelected:Bool
    var onClicked:((_ selected:Bool) -> ())
    var body: some View {
        Text(title)
            .foregroundStyle(isSelected ? .white : .black)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                isSelected ? Color.accentColor : Color.gray.opacity(0.4)
            )
            .cornerRadius(4)
            .onTapGesture {
                withAnimation {
                    onClicked(isSelected)
                }
            }
    }
}

struct FilterModel : Equatable {
    var filterUsers:[String] = []
    var filterMarkets:[String] = []
    var filterGovs:[String] = []
    var filterCouriers:[String] = []
    var filterStatue:[String] = []
    var filterPaid:[Bool] = []
    var filterShipping:[Bool] = []
    var minPrice:Int = 0
    var maxPrice:Int = 0
    
    func filtersCount() -> Int {
        var count = 0
        if !filterUsers.isEmpty {
            count += 1
        }
        
        if !filterMarkets.isEmpty {
            count += 1
        }
        
        if !filterGovs.isEmpty {
            count += 1
        }
        
        if !filterCouriers.isEmpty {
            count += 1
        }
        
        if !filterStatue.isEmpty {
            count += 1
        }
        
        if !filterPaid.isEmpty {
            count += 1
        }
        
        if !filterShipping.isEmpty {
            count += 1
        }
        
        if minPrice > 0 || maxPrice > 0 {
            count += 1
        }
        
        return count
    }
    
    func toString() -> String {
            let usersString = "filterUsers: \(filterUsers)"
            let marketsString = "filterMarkets: \(filterMarkets)"
            let govsString = "filterGovs: \(filterGovs)"
            let couriersString = "filterCouriers: \(filterCouriers)"
            let statueString = "filterStatue: \(filterStatue)"
            let paidString = "filterPaid: \(filterPaid)"
            let shippingString = "filterShipping: \(filterShipping)"
            let minPriceString = "minPrice: \(minPrice)"
            let maxPriceString = "maxPrice: \(maxPrice)"
            
            return """
            \(usersString)
            \(marketsString)
            \(govsString)
            \(couriersString)
            \(statueString)
            \(paidString)
            \(shippingString)
            \(minPriceString)
            \(maxPriceString)
            """
        }
}

#Preview {
    /*FilterScreen(currentlyFiltered: FilterModel(), filterDisplayed: .constant(true)) { model in
        
    }*/
    
    NavigationStack {
        FilteredOrdersView()
    }

}

extension Array where Element: Equatable {
    mutating func removeOrAdd(_ item: Element) {
        if let index = firstIndex(of: item) {
            self.remove(at: index)
        } else {
            self.append(item)
        }
    }
    
    mutating func remove(_ item: Element) {
        if let index = firstIndex(of: item) {
            remove(at: index)
        }
    }
}
