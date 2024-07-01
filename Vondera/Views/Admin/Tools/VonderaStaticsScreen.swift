//
//  VonderaStaticsScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class VonderaStaticsScreenVM : ObservableObject {
    @Published var ordersCount = 0
    @Published var totalPayments = 0
    @Published var totalSales = 0
    @Published var newStores = 0
    @Published var newProducts = 0
    
    @Published var retentionPerecentage = 0
    @Published var online:Double = 0
    @Published var almostExpired = 0.0
    
    @Published var isLoading = false
    
    
    @Published var from: Date = Date().daysAgo(7).startOfDay()
    @Published var to:Date = Date().endOfDay()
    @Published var selectedDateIndex = 1
    
    init() {
        Task {
            await fetchConstantData()
            await fetchData()
        }
    }
    
    func fetchConstantData() async {
        do {
            self.isLoading = true
            
            let onlineUsers = try await Firestore.firestore().collection("stores")
                .whereField("latestActive", isGreaterThan: Date().daysAgo(3))
                .count
                .getAggregation(source: .server)
                .count.doubleValue
            
            let almostExpired = try await Firestore.firestore().collection("stores")
                .whereField("storePlanInfo.expireDate", isGreaterThan: Date())
                .whereField("storePlanInfo.expireDate", isLessThan: Date().daysAgo(-3))
                .whereField("renewCount", isGreaterThanOrEqualTo: 1)
                .count
                .getAggregation(source: .server)
                .count.doubleValue
            
            let subscribedStores = try await Firestore.firestore().collection("stores")
                .whereField("renewCount", isGreaterThan: 0)
                .count
                .getAggregation(source: .server)
                .count.doubleValue
            
            let freeAfterSubscribe = try await Firestore.firestore().collection("stores")
                .whereField("renewCount", isGreaterThan: 0)
                .whereField("storePlanInfo.planId", isEqualTo: "free")
                .count
                .getAggregation(source: .server)
                .count.doubleValue
            
            let perc:Double = (((subscribedStores - freeAfterSubscribe) / subscribedStores) * 100)
            
            DispatchQueue.main.async { 
                self.retentionPerecentage = Int(perc)
                self.online = onlineUsers
                self.almostExpired = almostExpired
            }
        } catch {
            print(error)
        }
    }
    
    func fetchData() async {
        self.isLoading = true
        
        do {
           let ordersCount = try await Firestore.firestore().collectionGroup("orders")
                .whereField("date", isGreaterThan: from)
                .whereField("date", isLessThan: to)
                .count.getAggregation(source: .server).count.intValue
            
            let totalPayments:Double = try await Firestore.firestore().collection("transactions")
                .whereField("date", isGreaterThan: from)
                .whereField("date", isLessThan: to)
                .aggregate([AggregateField.sum("amount")])
                .getAggregation(source: .server)
                .get(AggregateField.sum("amount")) as! Double
            
            let totalSales:Double = try await Firestore.firestore().collectionGroup("orders")
                .whereField("date", isGreaterThan: from)
                .whereField("date", isLessThan: to)
                .aggregate([AggregateField.sum("salesTotal")])
                .getAggregation(source: .server)
                .get(AggregateField.sum("salesTotal")) as! Double
                        
            let totalStores = try await Firestore.firestore().collection("stores")
                .whereField("date", isGreaterThan: from)
                .whereField("date", isLessThan: to)
                .count
                .getAggregation(source: .server).count.intValue
            
           let totalProducts = try await Firestore.firestore().collectionGroup("products")
                .whereField("createDate", isGreaterThan: from)
                .whereField("createDate", isLessThan: to)
                .count
                .getAggregation(source: .server).count.intValue
            
            DispatchQueue.main.async {
                self.ordersCount = ordersCount
                self.totalPayments = Int(totalPayments)
                self.totalSales = Int(totalSales)
                self.newStores = totalStores
                self.newProducts = totalProducts
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
}

struct VonderaStaticsScreen: View {
    @StateObject private var viewModel = VonderaStaticsScreenVM()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                
                
                Text("Users Reports")
                    .font(.headline)
                
                ReportCard(title: "Retention", amount: viewModel.retentionPerecentage.double(), prefix: "%", desc : "Our retention Perecentage caculated by currently subscrbied stores / every subscribed store")
                
                ReportCard(title: "Active Stores", amount: viewModel.online, prefix: "Stores", desc : "Number of stores that were active in the last 3 days")
                
                ReportCard(title: "Almost Expired", amount: viewModel.almostExpired, prefix: "Stores", desc : "Number of stores that will expire in the next 3 days")
                
                Divider()
                    .padding(.vertical, 12)

                Text("Other Reports")
                    .font(.headline)
                
                VStack {
                    DateChoose(selectedIndex: $viewModel.selectedDateIndex, from: $viewModel.from, to: $viewModel.to)
                    
                    DatePicker("From", selection: $viewModel.from, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                    
                    Divider()
                    
                    DatePicker("To", selection: $viewModel.to, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                }
                
                ReportCard(title: "Orders Count", amount: viewModel.ordersCount.double() , prefix: "Orders", desc : "Number of orders added.")
                
                ReportCard(title: "Total Payments", amount: viewModel.totalPayments.double(), prefix: "EGP", desc : "Amount of subscribtion fees we received")
                
                ReportCard(title: "Total Sales", amount: viewModel.totalSales.double(), prefix: "EGP", desc : "Sales made by using Vondera, including manual orders")
                
                ReportCard(title: "New Stores", amount: viewModel.newStores.double(), prefix: "Stores", desc : "New Stores created in this period")
                
                ReportCard(title: "New Products", amount: viewModel.newProducts.double(), prefix: "Products", desc : "New Products added to vondera in this period")
               
            }
            .padding()
        }
        .willLoad(loading: viewModel.isLoading)
        .navigationTitle("Reports")
        .onChange(of: viewModel.from) { _ in
            Task { await viewModel.fetchData() }
        }
        .onChange(of: viewModel.to) { _ in
            Task { await viewModel.fetchData() }
        }
    }
}

#Preview {
    VonderaStaticsScreen()
}
