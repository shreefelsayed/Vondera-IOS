//
//  OrderSelectView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import SwiftUI

struct OrderSelectView: View {
    @Binding var list:[Order]
    @State var checkedItems = [Order]()
    
    @State var searchText = ""
    @State var isShowingSheet = false
    @State var initalState = ""
    
    init(list: Binding<[Order]>) {
        _list = list
        self.checkedItems.append(contentsOf: list.wrappedValue)
    }
    
    var filterItems:[Order] {
        guard !searchText.isEmpty else { return list }
        
        return list.filter { order in
            order.filter(searchText: searchText)
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading) {
                    SearchBar(text: $searchText, hint: "Search \($list.count) Orders")
                    
                    HStack {
                        Text("\(checkedItems.count) Selected Orders")
                        Spacer()
                        
                        if !checkedItems.isEmpty {
                            Text("Unselect All")
                                .bold()
                                .onTapGesture {
                                    unselectAll()
                                }
                        }
                        
                        if checkedItems.count != list.count {
                            Text("Select All")
                                .bold()
                                .onTapGesture {
                                    selectAll()
                                }
                        }
                    }
                    .padding(.vertical)
                    
                    ForEach(filterItems) { item in
                        OrderSelect(order: item, checked: Binding(
                            get: {
                                checkedItems.contains { $0 == item }
                            },
                            set: { isChecked in
                                if isChecked {
                                    if !checkedItems.contains(item) {
                                        checkedItems.append(item)
                                    }
                                } else {
                                    checkedItems.removeAll { $0 == item }
                                }
                            }
                        )) {
                            
                        } onDeselect: {
                            
                        }
                        
                    }
                    
                    
                    
                }
            }
            .padding()
            
            BottomSheet(isShowing: $isShowingSheet, content: {
                AnyView(ActionsDialog(list: $checkedItems, isShowen: $isShowingSheet))
            }())
        }
        .onAppear {
            initalState = list.first!.statue
        }
        .toolbar {
            if !checkedItems.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actions") {
                        isShowingSheet.toggle()
                    }
                }
            }
        }
        .navigationTitle("Select orders")
        
    }
    
    func removeOrdersWithDifferentStatus() {
        unselectAll()
        list = list.filter { $0.statue == initalState }
    }
    
    func selectAll() {
        self.checkedItems = list
    }
    
    func unselectAll() {
        self.checkedItems = []
    }
    
    func isSelected(_ order: Order) -> Bool {
        self.checkedItems.contains { $0 == order}
    }
    
    func toggleSelection(_ order: Order) {
        if isSelected(order) {
            self.checkedItems.removeAll { $0 == order }
        } else {
            self.checkedItems.append(order)
        }
    }
}

struct ActionsDialog: View {
    @Binding var list:[Order]
    @State var statue = 0
    @Binding var isShowen:Bool
    @State var courierSheet = false
    @State var selectedOption:Courier?
    
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Select your action")
                    .font(.title)
                    .bold()
                
                Text("Please choose which action you want to make on the orders, note that this action is not reversible")
                    .font(.caption)
                
                Spacer().frame(height: 12)
                
                VStack(alignment: .leading) {
                    Button("Print Receipts") {
                        Task {
                            await ReciptPDF(orderList: list).generateAndOpenPDF()
                        }
                    }
                    
                    Divider()
                    
                    Button("Sales Report") {
                        Task {
                            SalesExcel(listOrders: list).generateReport()
                        }
                    }
                    
                    Divider()
                    
                    Button("Download attachments") {
                        DownloadManager().saveImagesToDevice(imageURLs: OrderManager().listAttachments(orders: list))
                        isShowen.toggle()
                    }
                    
                    Divider()
                }
                
                
                
                
                if statue <= 1 {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Button("Confirm orders") {
                                Task {
                                    await OrderManager().confirmOrder(list: &list)
                                    isShowen.toggle()
                                }
                            }
                            
                            Divider()
                        }
                    }
                }
                
                if statue <= 2 {
                    VStack(alignment: .leading) {
                        Button("Assemble orders") {
                            Task {
                                await OrderManager().assambleOrder(list: &list)
                                isShowen.toggle()
                            }
                        }
                        
                        Divider()
                    }
                }
                
                if statue <= 3 {
                    VStack(alignment: .leading) {
                        Button("Assign orders to courier") {
                            courierSheet.toggle()
                        }
                        
                        Divider()
                    }
                }
                
                if statue <= 4 {
                    VStack(alignment: .leading) {
                        Button("Deliver orders") {
                            Task {
                                await OrderManager().orderDelivered(list: &list)
                                isShowen.toggle()
                            }
                        }
                        Divider()
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        
        .sheet(isPresented: $courierSheet) {
            CourierPicker(storeId: list.first!.storeId!, selectedOption: $selectedOption)
        }
        .onChange(of: selectedOption) { newValue in
            // Handle selectedOption changes here
            if let option = newValue {
                Task {
                    await OrderManager().outForDelivery(list:&list, courier:option)
                    isShowen.toggle()
                }
            }
        }
        .onAppear {
            var firstStatue = list.first!.statue
            if firstStatue == "Pending" {
                statue = 1
            } else if firstStatue == "Confirmed" {
                statue = 2
            } else if firstStatue == "Assembled" {
                statue = 3
            } else if firstStatue == "Out For Delivery" {
                statue = 4
            } else if firstStatue == "Delivered" || firstStatue == "Failed" {
                statue = 5
            } else {
                statue = 0
            }
        }
        .onChange(of: selectedOption) { newValue in
            // Handle selectedOption changes here
            if let option = newValue {
                print("Selected option: \(option)")
            }
        }
        .padding()
    }
}
