//
//  ReportsDialog.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/12/2023.
//

import SwiftUI

struct ReportsDialog: View {
    var listOrder:[Order]
    var body: some View {
        NavigationStack {
            List {
                Label("Sales Sheet", systemImage: "basket")
                    .onTapGesture {
                        if let url = SalesExcel(listOrders: listOrder).generateReport() {
                            DispatchQueue.main.async {
                                FileUtils().shareFile(url: url)
                            }
                        }
                    }
                
                Label("Shipping excel sheet", systemImage: "train.side.front.car")
                    .onTapGesture {
                        if let url = OrderShippingExcel(listOrders: listOrder).generateReport() {
                            DispatchQueue.main.async {
                                FileUtils().shareFile(url: url)
                            }
                        }
                    }
                
                
                Label("Products Report Sheet", systemImage: "basket")
                    .onTapGesture {
                        if let url = ProductSalesExcel(listOrders: listOrder).generateReport() {
                            DispatchQueue.main.async {
                                FileUtils().shareFile(url: url)
                            }
                        }
                    }
                
                Label("Receipts PDF", systemImage: "printer")
                    .onTapGesture {
                        Task {
                            if let uri = await ReciptPDF(orderList: listOrder).render() {
                                DispatchQueue.main.async {
                                    FileUtils().shareFile(url: uri)
                                }
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .navigationTitle("Export Report")
            
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ReportsDialog(listOrder: [Order.example()])
}
