//
//  OrderSelectView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import SwiftUI
import AlertToast

struct OrderSelectView: View {
    @Binding var list:[Order]
    @State var checkedItems = [Order]()
    
    @State var searchText = ""
    @State var isShowingSheet = false
    
    @State var size:CGFloat = .zero

    var body: some View {
        VStack {
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
            .padding()
            
            List {
                ForEach($list.indices, id: \.self) { index in
                    if list[index].filter(searchText: searchText) && !list[index].isHidden {
                        OrderSelectCard(order: $list[index], checked: Binding(items: $checkedItems, currentItem: list[index]))
                            .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if list.isEmpty {
                    EmptyMessageView(msg: "No orders to select from")
                } else if list.isEmpty && !searchText.isBlank {
                    EmptyMessageView(systemName: "magnifyingglass", msg: "No result for your search \(searchText)")
                }
            }
            
            
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $isShowingSheet) {
            ActionsDialog(list: checkedItems, isShowen: $isShowingSheet, onActionMade: { updated in
                self.isShowingSheet = false
                updateItems(updated)
                unselectAll()
            })
            .presentationDetents([.medium])
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
    
    func updateItems(_ items:[Order]) {
        for changedItem in items {
            if let index = list.firstIndex(where: {$0 == changedItem }) {
                list[index] = changedItem
                print("Updated item to statue \(list[index].statue)")
            }
        }
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
    @State var list:[Order]
    @State var statue = 0
    @Binding var isShowen:Bool
    
    @State var reportSheet = false
    @State var courierSheet = false
    @State var selectedOption:Courier?
    @State var toast:String? = nil
    var onActionMade : (([Order]) -> ())
    
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
                            if let uri = await ReciptPDF(orderList: list).render() {
                                DispatchQueue.main.async {
                                    FileUtils().shareFile(url: uri)
                                    showToast("Receipts Genrated")
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button("Export Reports") {
                        reportSheet.toggle()
                    }
                    
                    Divider()
                    
                    Button("Sales Report") {
                        if let url = SalesExcel(listOrders: list).generateReport() {
                            DispatchQueue.main.async {
                                FileUtils().shareFile(url: url)
                                showToast("Report Genrated")
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button("Download attachments") {
                        showToast("Items downloading")
                        DownloadManager().saveImagesToDevice(imageURLs: OrderManager().listAttachments(orders: list))
                        isShowen = false
                    }
                    
                    Divider()
                }
                
                if statue <= 1 || statue == 4 {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Button("Confirm orders") {
                                showToast("Confirming Orders")
                                Task {
                                    let update = await OrderManager().confirmOrder(list: &list)
                                    DispatchQueue.main.async {
                                        self.list = update
                                        print("Statue \(list.first?.statue ?? "")")
                                        self.onActionMade(update)
                                    }
                                }
                            }
                            Divider()
                        }
                    }
                }
                
                if statue <= 2 {
                    VStack(alignment: .leading) {
                        Button("Assemble orders") {
                            showToast("Assembling Orders")
                            Task {
                                let update = await OrderManager().assambleOrder(list: &list)
                                DispatchQueue.main.async {
                                    self.list = update
                                    self.onActionMade(update)
                                }
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
                            showToast("Finishing Orders")
                            Task {
                                let update =  await OrderManager().orderDelivered(list: &list)
                                DispatchQueue.main.async {
                                    self.list = update
                                    self.onActionMade(update)
                                }
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
            CourierPicker(selectedOption: $selectedOption)
        }
        .sheet(isPresented: $reportSheet) {
            ReportsDialog(listOrder: list)
        }
        .toast(isPresenting: Binding(value: $toast)) {
            AlertToast(displayMode: .alert, type: .complete(.accentColor), title: toast)
        }
        .onChange(of: selectedOption) { newValue in
            if let option = newValue {
                showToast("Assigned to Courier")
                
                Task {
                    let update = await OrderManager().outForDelivery(list:&list, courier:option)
                    DispatchQueue.main.async {
                        self.list = update
                        self.onActionMade(update)
                    }
                }
            }
        }
        .onAppear {
            let firstStatue = list.first!.statue
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
        .padding()
    }
    
    func showToast(_ msg:String) {
        DispatchQueue.main.async {
            self.toast = msg
        }
    }
}


