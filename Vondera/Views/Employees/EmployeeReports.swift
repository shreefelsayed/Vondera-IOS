//
//  EmployeeReports.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/10/2023.
//

import SwiftUI

struct EmployeeReports: View {
    var employee:UserData
    
    @State var selectedDateIndex = 1
    @State var from: Date = Date().daysAgo(7).startOfDay()
    @State var to:Date = Date().endOfDay()
    @State var items:[Order] = []

    @State var isLoading = false
    @State var report = false
    @Environment(\.presentationMode) private var presentationMode

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

                    ReportCard(title: "Delivery Success Rate", amount: items.getSuccessPercentage().double(), prefix: "%", desc: "(Delivered Order / Total Orders finished) * 100")
                    
                    ReportCard(title: "Selling Commission", amount: items.getSellingCommission(), prefix: "EGP", desc: "order profit * (\((employee.percentage ?? 0) * 100) / 100) \n * Note that if you changed the employee commission it takes effect for the new orders", nutural: true)
                    
                    ReportCard(title: "Orders Profit", amount: items.totalNetProfit(), prefix: "EGP", desc: "Profit calculated using this formula (Product Price + the shipping fees of the client) - (Discount on the order - Courier Fees - Seller Comission) \n * Make sure you add your courier with their fees")
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
        .navigationTitle("\(employee.name) Report")
        .onAppear {
            fetch()
        }
        .withAccessLevel(accessKey: .statisticsRead, presentation: presentationMode)
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
        
        if let items = try? await OrdersDao(storeId: employee.storeId).getEmployeeOrdersByDate(employee.id, from: from.startOfDay(), to: to.endOfDay()){
            
            DispatchQueue.main.async {
                self.items = items
                self.isLoading = false
            }
        }
    }
}
#Preview {
    EmployeeReports(employee: UserData.example())
}
