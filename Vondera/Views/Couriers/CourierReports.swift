//
//  CourierReports.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/10/2023.
//


import SwiftUI

struct CourierReports: View {
    var courier:Courier
    
    @State var selectedDateIndex = 1
    @State var from: Date = Date().daysAgo(7).startOfDay()
    @State var to:Date = Date().endOfDay()
    @State var items:[Order] = []

    @State var isLoading = false
    
    @State var report = false

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
                
                Text("Order reports for orders assigned to courier from \(from.formatted()) to \(to.formatted())")
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
                Section("Orders") {
                    ReportCard(title: "Orders shipped", amount: items.getValidOrders().count, prefix: "Orders", desc : "Number of orders assigned to courier in the time range")
                    
                    ReportCard(title: "Products Shipped", amount: items.getProductsCount(), prefix: "Products", desc : "Number of products sold")
                    
                    ReportCard(title: "Total Fees", amount: items.shippingFees(), prefix: "EGP", desc : "The courier fees for all orders")
                    
                    ReportCard(title: "Total Cash", amount: items.totalCODAfterCourier(), prefix: "EGP", desc : "The cash that you should get from the courier for all of the orders")
                }
                
                Section("On Going Orders") {
                    ReportCard(title: "With Courier", amount: items.getByStatue(statue: "Out For Delivery").count, prefix: "Orders", desc: "Orders still with Courier")
                    
                    ReportCard(title: "Shipping Fees", amount: items.getByStatue(statue: "Out For Delivery").shippingFees(), prefix: "EGP", desc : "The courier fees for the on going orders")
                    
                    ReportCard(title: "Orders Cash", amount: items.getByStatue(statue: "Out For Delivery").totalCODAfterCourier(), prefix: "EGP", desc: "the amount that you should receive after the courier fees detected")
                }
                
                Section("Finished Orders") {
                    ReportCard(title: "Delivered", amount: items.getByStatue(statue: "Delivered").count, prefix: "Orders")
                    
                    ReportCard(title: "Failed", amount: items.getByStatue(statue: "Failed").count, prefix: "Orders")
                    
                    ReportCard(title: "Delivery Success Rate", amount: items.getSuccessPercentage(), prefix: "%", desc: "(Delivered Order / Total Orders finished) * 100")
                    
                    ReportCard(title: "Shipping Fees", amount: items.getFinishedOrders().shippingFees(), prefix: "EGP", desc : "The courier fees for the delivered orders")
                    
                    ReportCard(title: "Orders Cash", amount: items.getFinishedOrders().totalCODAfterCourier(), prefix: "EGP", desc: "the amount that you should receive after the courier fees detected")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(Color.accentColor)
                    .onTapGesture {
                        report.toggle()
                    }
                    .isHidden(items.isEmpty)
            }
        }
        .sheet(isPresented: $report, content: {
            ReportsDialog(listOrder: items)
        })
        .navigationTitle("\(courier.name) Report")
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
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        if let user = UserInformation.shared.user, let items = try? await OrdersDao(storeId: user.storeId).getCourierOrdersByDate(courier.id, from: from.startOfDay(), to: to.endOfDay()){
            
            DispatchQueue.main.async {
                self.items = items
                self.isLoading = false
            }
        }
    }
}
