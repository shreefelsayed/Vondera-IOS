//
//  CourierCurrentOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import CodeScanner
import AlertToast

struct AssignToCourierView : View {
    @Environment(\.presentationMode) private var presentationMode

    var courier:Courier
    var storeId:String
    
    @State var searchedId = ""
    @State var loading = false
    @State var msg:LocalizedStringKey?
    var onAdded:((Order) -> ())
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                /*TextField("Enter order id", text: $searchedId)
                    .textFieldStyle(.roundedBorder)*/
                
                SearchBar(text: $searchedId, hint: "Enter order id")
                
                Spacer()
                
                Button {
                    print("Clicked")
                    Task {
                        await findOrder(searchedId)
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(loading)
            }
            .padding()
            
            CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, showViewfinder: true, shouldVibrateOnSuccess: true) { response in
                if case let .success(result) = response, !result.string.isBlank, result.string.isNumeric {
                    Task {
                        await findOrder(result.string)
                    }
                }
            }
        }.overlay(content: {
            if loading {
                ProgressView()
            }
        })
        .navigationTitle("Assign to Courier")
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        }
        .withAccessLevel(accessKey: .accessCouriersAssign, presentation: presentationMode)
    }
    
    func findOrder(_ id:String) async {
        guard !id.isBlank && id.isNumeric else {
            self.msg = "Check the order id"
            return
        }
        
        self.loading = true
        do {
            let result = try await OrdersDao(storeId: storeId).getOrder(id: id)
            guard result.exists else {
                self.msg = "Order id doesn't exist"
                self.loading = false
                return
            }
            
            guard var order = result.item else { return }
            let canAssing = OrderManager().canAddToCourier(order: order, courierId: courier.id)
            
            guard canAssing.confirmed else {
                self.msg = canAssing.msg
                self.loading = false
                return
            }
            
            order = await OrderManager().outForDelivery(order: &order, courier: courier)
            
            DispatchQueue.main.async { [order] in
                self.searchedId = ""
                self.onAdded(order)
                self.msg = "Order assigned to courier"
                self.loading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.msg = error.localizedDescription.localize()
                self.loading = false
            }
        }
    }
}

struct CourierCurrentOrders: View {
    var courier:Courier
    var storeId:String
    
    @State var myUser = UserInformation.shared.getUser()
    @State var selectOrders = false
    @State var assignOrders = false
    @StateObject var viewModel:CourierCurrentOrdersViewModel
        
    init(storeId: String, courier:Courier) {
        self.storeId = storeId
        self.courier = courier
        _viewModel = StateObject(wrappedValue: CourierCurrentOrdersViewModel(storeId: storeId, courierId: courier.id))
    }
    
    var body: some View {
        List {
            if viewModel.items.count > 0 {
                SearchBar(text: $viewModel.searchText, hint: "Search \(viewModel.items.count) Orders")
            }
            
            ForEach($viewModel.items.indices, id: \.self) { index in
                if $viewModel.items[index].wrappedValue.filter(searchText: viewModel.searchText) {
                    OrderCard(order: $viewModel.items[index], allowSelect: {
                        selectOrders.toggle()
                    })
                }
            }
        }
        .listStyle(.plain)
        .overlay(alignment: .center) {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "The courier has no ongoing orders")
            }
        }
        .refreshable {
            await viewModel.getCourierOrders()
        }
        .navigationTitle("Current Orders")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if courier.visible {
                        Button {
                            self.assignOrders.toggle()
                        } label: {
                            Label("Assign Orders", systemImage: "qrcode.viewfinder")
                        }
                    }
                    
                    NavigationLink {
                        CourierReports(courier: courier)
                    } label: {
                        Label("Reports", systemImage: "filemenu.and.selection")
                    }
                    
                    NavigationLink {
                        CourierImportExcel(courierId: courier.id)
                    } label: {
                        Label("Check Courier Sheet", systemImage: "filemenu.and.cursorarrow")
                    }
                    
                    NavigationLink {
                        CourierSettingsView(courier: courier, storeId: storeId)
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    
                   
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
        .sheet(isPresented: $assignOrders) {
            NavigationStack {
                AssignToCourierView(courier: courier, storeId: myUser?.storeId ?? "") { addedOrder in
                    withAnimation {
                        viewModel.items.insert(addedOrder, at: 0)
                    }
                }
            }
        }
        .sheet(isPresented: $selectOrders) {
            NavigationStack {
                OrderSelectView(list: $viewModel.items)
            }
        }
        
    }
}

struct CourierProfile: View {
    @State var selectedTab = 0
    @State private var currentOrders: CourierCurrentOrders
    @State private var deliveredOrders: CourierFinishedOrders
    @State private var failedOrders: CourierFailedOrders

    var courier:Courier
    var storeId:String
    
    init(storeId: String, courier: Courier) {
        self.storeId = storeId
        self.courier = courier
        
        // -- Init pages
        _currentOrders = State(wrappedValue: CourierCurrentOrders(storeId: storeId, courier: courier))
        _deliveredOrders = State(wrappedValue: CourierFinishedOrders(courier: courier))
        _failedOrders = State(wrappedValue: CourierFailedOrders(courier: courier))
    }
    
    var body: some View {
        VStack {
            CustomTopTabBar(tabIndex: $selectedTab, titles: ["Current Orders", "Delivered Orders", "Failed Orders"])
                .padding(.leading, 12)
                .padding(.top, 12)
            
            VStack {
                if selectedTab == 0 {
                    currentOrders
                } else if selectedTab == 1 {
                    deliveredOrders
                } else {
                    failedOrders
                }
            }
            .padding()
        }
        .background(Color.background)
    }
}

struct CourierCurrentOrders_Previews: PreviewProvider {
    static var previews: some View {
        CourierCurrentOrders(storeId: "", courier: Courier.example())
    }
}
