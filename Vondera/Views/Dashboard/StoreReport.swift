//
//  StoreReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI

struct DateModel {
    var title:String
    var range:Int
}

struct DateChoose:View {
    @Binding var selectedIndex:Int
    @Binding var from:Date
    @Binding var to:Date
    
    
    let dates = [
        DateModel(title: "Today", range: 1),
        DateModel(title: "Last week", range: 7),
        DateModel(title: "Last Month", range: 30),
        DateModel(title: "Last Quarter", range: 30),
        DateModel(title: "Last Year", range: 365),
    ]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(dates.indices, id: \.self) { index in
                    Text(dates[index].title)
                        .font(.callout)
                        .bold()
                        .foregroundStyle(selectedIndex == index ? .white : .black)
                        .padding(6)
                        .background(selectedIndex == index ? Color.accentColor : Color.background)
                        .cornerRadius(8)
                        .onTapGesture {
                            withAnimation {
                                from = Date().daysAgo(dates[index].range - 1).startOfDay()
                                to = Date().endOfDay()
                                selectedIndex = index
                            }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct StoreReport: View {
    @State var selectedDateIndex = 1
    @State var from: Date = Date().daysAgo(7).startOfDay()
    @State var to:Date = Date().endOfDay()
    @State var items:[Order] = []
    @State var expanses:[Expense] = []

    @State var isLoading = false
    @State var showReport = false

    var body: some View {
        List() {
            
            // MARK : DATA VARIABLES
            Section("Choose Date") {
                
                VStack(alignment: .leading) {
                    DateChoose(selectedIndex: $selectedDateIndex, from: $from, to: $to)
                    
                    DatePicker("From", selection: $from, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                    
                    Divider()
                    
                    DatePicker("To", selection: $to, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                }
                
                Text("Order reports for orders created from \(from.formatted()) to \(to.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onChange(of: from) { _ in
                fetch()
            }
            .onChange(of: to) { _ in
                fetch()
            }
            
            if !isLoading {
                Section("Sales & Profit") {
                    ReportCard(title: "Total Orders", amount: items.getValidOrders().count.double(), prefix: "Orders", desc : "Number of orders created in the time range")
                    
                    ReportCard(title: "Products Sold", amount: items.getProductsCount().double(), prefix: "Products", desc : "Number of products sold")
                    
                    ReportCard(title: "Sales", amount: items.totalSales(), prefix: "EGP", desc: "The Quantity of each product x The price of the product")
                    
                    ReportCard(title: "Total Cost", amount: (-items.totalCost()), prefix: "EGP", desc: "The Quantity of each product x The cost of the product")
                    
                    ReportCard(title: "Orders Profit", amount: items.totalNetProfit(), prefix: "EGP", desc: "Profit calculated using this formula (Product Price + the shipping fees of the client) - (Discount on the order - Courier Fees - Seller Comission) \n * Make sure you add your courier with their fees")
                    
                    ReportCard(title: "Expanses", amount: (-expanses.total()), prefix: "EGP")
                    
                    ReportCard(title: "Net Profit", amount: (items.totalNetProfit() - expanses.total()), prefix: "EGP", desc: "Net profit is the orders profit - expanses")
                    
                    ReportCard(title: "Delivery Success Rate", amount: items.getSuccessPercentage().double(), prefix: "%", desc: "(Delivered Order / Total Orders finished) * 100")
                }
                
                
                Section("On Going Orders") {
                    ReportCard(title: "Pending Orders", amount: (items.getByStatue(statue: "Pending").count + items.getByStatue(statue: "Confirmed").count + items.getByStatue(statue: "Assembled").count).double(), prefix: "Orders", desc : "Those are the orders that still with you")
                    
                    ReportCard(title: "With Courier Orders", amount: items.getByStatue(statue: "Out For Delivery").count.double(), prefix: "Orders", desc : "Those are the orders with your couriers")
                    
                    ReportCard(title: "Cash With Couriers", amount: items.getByStatue(statue: "Out For Delivery").totalCODAfterCourier(), prefix: "EGP", desc: "The amount of cash that expected to receive from the coureirs (Order price - Courier Fees)")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(Color.accentColor)
                    .onTapGesture {
                        showReport.toggle()
                    }
                    .isHidden(items.isEmpty)
            }
        }
        .sheet(isPresented: $showReport, content: {
            ReportsDialog(listOrder: items)
        })
        .navigationTitle("Reports")
        .onAppear {
            fetch()
        }
    }
    
    func fetch() {
        Task {
            await getData()
        }
    }
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        self.isLoading = true
        
        do {
            let items = try await OrdersDao(storeId: storeId).getOrdersByAddDate(from: from.startOfDay(), to: to.endOfDay())
            let expanses = try await ExpansesDao(storeId: storeId).getBetweenDate(from: from.startOfDay(), to: to.endOfDay())
            
            DispatchQueue.main.async {
                self.items = items
                self.expanses = expanses
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}
