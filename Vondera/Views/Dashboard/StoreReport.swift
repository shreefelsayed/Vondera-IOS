//
//  StoreReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI

struct StoreReport: View {
    var storeId:String
        
    @State var from: Date = Date()
    @State var to:Date = Date()
    @State var onlyDeliverd = true
    @State var items:[Order] = []
    @State var expanses:[Expense] = []

    @State var isLoading = false

    var body: some View {
        List() {
            
            // MARK : DATA VARIABLES
            Section("Choose Date") {
                VStack(alignment: .leading) {
                    DatePicker("From", selection: $from, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                    
                    Divider()
                    
                    DatePicker("To", selection: $to, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                    
                    Divider()
                    
                    Toggle("Only Delivered Orders", isOn: $onlyDeliverd)
                }
            }
            .onChange(of: from) { _ in
                fetch()
            }
            .onChange(of: to) { _ in
                fetch()
            }
            .onChange(of: onlyDeliverd) { _ in
                fetch()
            }
            
                            
            if isLoading {
                ProgressView()
            }
            
            Section("Sales & Profit") {
                ReportCard(title: "Total Orders", amount: items.getValidOrders().count, prefix: "Orders")
                ReportCard(title: "Sales", amount: items.totalSales(), prefix: "EGP")
                ReportCard(title: "Total Cost", amount: (-items.totalCost()), prefix: "EGP")
                ReportCard(title: "Orders Profit", amount: items.totalNetProfit(), prefix: "EGP")
                ReportCard(title: "Expanses", amount: (-expanses.total()), prefix: "EGP")
                ReportCard(title: "Net Profit", amount: (items.totalNetProfit() - expanses.total()), prefix: "EGP")

            }
            
            Section("New Orders") {
                ReportCard(title: "New Orders", amount: items.getByStatue(statue: "Pending").count, prefix: "Orders")
                ReportCard(title: "Confirmed Orders", amount: items.getByStatue(statue: "Confirmed").count, prefix: "Orders")
            }
            
            Section("On Going Orders") {
                ReportCard(title: "With Courier Orders", amount: items.getByStatue(statue: "Out For Delivery").count, prefix: "Orders")
                ReportCard(title: "Cash With Couriers", amount: items.getByStatue(statue: "Out For Delivery").totalCODAfterCourier(), prefix: "EGP")
                ReportCard(title: "Shipping Fees", amount: (-items.shippingFees()), prefix: "EGP")
            }
            
            Section("Finished Orders") {
                ReportCard(title: "Delivered Orders", amount: items.getByStatue(statue: "Delivered").count, prefix: "Orders")
                ReportCard(title: "Failed Orders", amount: items.getByStatue(statue: "Failed").count, prefix: "Orders")
                ReportCard(title: "Success Rate", amount: items.getSuccessPercentage(), prefix: "%")
            }
            
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(Color.accentColor)
                    .onTapGesture {
                        SalesExcel(listOrders: items)
                            .generateReport()
                    }.isHidden(items.isEmpty)
            }
        }
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
        isLoading = true
        
        
        if onlyDeliverd {
            let items = try! await OrdersDao(storeId: storeId)
                .getOrdersByDeliverDate(from: from, to: to)
            self.items = items
        } else {
            let items = try! await OrdersDao(storeId: storeId)
                .getOrdersByAddDate(from: from, to: to)
            self.items = items
        }
        
        self.expanses = try! await ExpansesDao(storeId: storeId)
            .getBetweenDate(from: from, to: to)
        
        
        isLoading = false
    }
}

#Preview {
    StoreReport(storeId: Store.Qotoofs())
}
