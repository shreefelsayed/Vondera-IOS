//
//  HomeReports.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/10/2023.
//

import SwiftUI
import LineChartView

struct ReportCardView : View {
    var title:LocalizedStringKey
    var desc:LocalizedStringKey
    var dataSuffix:LocalizedStringKey
    var data:[LineChartData]
    var lineColor:Color = Color.accentColor
    var smallSize = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if smallSize {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .bold()
                    
                    Text(desc)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Text(title)
                        .font(.headline)
                        .bold()
                    
                    
                    Spacer()
                    
                    Text(desc)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            
            LineChartView(
                lineChartParameters:
                    LineChartParameters(
                        data: data,
                        dataPrecisionLength: 0,
                        dataSuffix: " \(dataSuffix.toString())",
                        lineColor: lineColor
                    )
            )
        }
        .frame(height: 180)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
struct HomeReports: View {
    @Binding var reportsDays:Int
    var reports:[StoreStatics]
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK : HEADER
            HStack {
                Text("Overview")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Picker("Date Range", selection: $reportsDays) {
                    Text("Today")
                        .tag(1)
                    
                    Text("This Week")
                        .tag(7)
                    
                    Text("This Month")
                        .tag(30)
                    
                    Text("This Quarter")
                        .tag(90)
                    
                    Text("This year")
                        .tag(365)
                }
            }
            
            // MARK : NEW Sales
            ReportCardView(title: "Sales", desc: "\(reports.getTotalSales()) EGP", dataSuffix: "EGP", data: reports.getLinechartSales(), lineColor: Color.accentColor)
            
            // MARK : NEW ORDERS
            ReportCardView(title: "Orders", desc: "\(reports.getTotalOrders()) Orders", dataSuffix: "Orders", data: reports.getLinearChartOrder(), lineColor: .blue)
            
            // MARK : NEW Visits
            ReportCardView(title: "Visitors", desc: "\(reports.getTotalVisitors()) Visits", dataSuffix: "Visits", data: reports.getVisitorsData(), lineColor: .orange)
        }
    }
}
