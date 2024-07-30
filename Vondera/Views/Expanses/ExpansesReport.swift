//
//  ExpansesReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/10/2023.
//

import SwiftUI

struct ExpansesReport: View {
    var storeId:String
    
    @State var selectedDateIndex = 1
    @State var from: Date = Date().daysAgo(7).startOfDay()
    @State var to:Date = Date().endOfDay()
    @State var expanses:[Expense] = []

    @State var isLoading = false
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
                
                Text("Expanses reports from \(from.formatted()) to \(to.formatted())")
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
                ReportCard(title: "Expanses", amount: (-expanses.total()), prefix: "EGP")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(Color.accentColor)
                    .onTapGesture {
                        if let url = ExpansesExcel(items: expanses).generateReport() {
                            DispatchQueue.main.async {
                                FileUtils().shareFile(url: url)
                            }
                        }
                    }
                    .isHidden(expanses.isEmpty)
            }
        }
        .navigationTitle("Expanses Reports")
        .onAppear {
            fetch()
        }
        .withAccessLevel(accessKey: .expensesExport, presentation: presentationMode)

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
        
        if let expanses = try? await ExpansesDao(storeId: storeId)
            .getBetweenDate(from: from.startOfDay(), to: to.endOfDay()) {
            
            DispatchQueue.main.async {
                self.expanses = expanses
                self.isLoading = false
            }
        }
    }
}
