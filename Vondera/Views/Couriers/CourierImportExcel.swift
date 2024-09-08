//
//  CourierImportExcel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/07/2024.
//

import SwiftUI
import CoreXLSX

class CourierImportExcelVM : ObservableObject {
    var courierId:String = ""
    
    @Published var isLoading = false
    @Published var selectedFile: URL?
    @Published var showPicker = false
    
    @State var validOrders = [Order]()
    @State var invalidNumbers = [String]()
    @State var invalidPrices = [Order]()
    @State var invalidCourier = [Order]()
    
    init(courierId:String) {
        self.courierId = courierId
    }
    
    func importExcelFile() {
        showPicker = true
    }
    
    func readExcelFile(url: URL) {
        print("URL \(url.absoluteString), path \(url.path())")
        var items:[(String, Double)] = []
        do {
                       
            guard url.startAccessingSecurityScopedResource() else {
                print("Access Denied")
                return
            }
            
            let file = XLSXFile(filepath: url.path)
            
            guard let file = file else {
                print("Fill is null")
                return
            }
            
           
            for path in try file.parseWorksheetPaths() {
                print("File Imported path \(path.count)")
                let ws = try file.parseWorksheet(at: path)

                guard let rows = ws.data?.rows else {
                    print("Can't find rows")
                    continue
                }
                
                print("File imported rows \(rows.count)")
                
                for (_, row) in rows.enumerated() {
                    // Skip the first row
                    //if index == 0 { continue }
                    print(row.cells.map {$0.value ?? ""}.joined(separator: ", "))
                    
                    let id = row.cells[0].value ?? ""
                    let price = row.cells[1].value?.toDoubleOrZero() ?? 0
                    guard !id.isBlank && id.count > 4 else { continue }
                    items.append((id, price))
                }
            }
            
            fetchOrders(items)
        } catch {
            print("Erroe with reading file \(error)")
        }
    }
    
    func fetchOrders(_ rows:[(id: String, price: Double)]) {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        self.isLoading = true
        Task {
            print("Total orders = \(rows.count)")
            var results = [Order]()
            
            var valid = [Order]()
            
            for item in rows {
                print("Checking order no : \(item.0)")
                let order = try? await OrdersDao(storeId: storeId).getOrder(id: item.0)
                
                guard let order = order, order.exists, let order = order.item else {
                    DispatchQueue.main.async { self.invalidNumbers.append(item.0) }
                    print("Order is invalid")
                    continue
                }
                                
                if courierId != order.courierId {
                    DispatchQueue.main.async { self.invalidCourier.append(order) }
                    print("Invalid Courier")
                    continue
                }
                
                if order.CODAfterCourier > item.price {
                    DispatchQueue.main.async { self.invalidPrices.append(order) }
                    print("Invalid Prices")
                    continue
                }
                
                valid.append(order)
                print("Valid order")
            }
            
            self.isLoading = false
            DispatchQueue.main.async { [valid] in
                self.validOrders = valid
                print("Valid number = \(self.validOrders.count)")
            }
        }
    }
}

struct CourierImportExcel: View {
    @StateObject private var viewModel:CourierImportExcelVM
    @State private var selectedFile: URL?
    
    init(courierId:String) {
        self._viewModel = StateObject(wrappedValue: CourierImportExcelVM(courierId:courierId))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                // --> Valid Orders
                if !viewModel.validOrders.isEmpty {
                    Text("Valid Order")
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    ForEach($viewModel.validOrders) { item in
                        OrderCard(order: item)
                    }
                }
                
                // --> Invalid Orders
                if !viewModel.invalidPrices.isEmpty {
                    Text("Invalid Prices")
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    ForEach($viewModel.invalidPrices) { item in
                        OrderCard(order: item)
                    }
                }
                
                // --> Invalid Courier
                if !viewModel.invalidCourier.isEmpty {
                    Text("Invalid Courier")
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    ForEach($viewModel.invalidCourier) { item in
                        OrderCard(order: item)
                    }
                }
                
                // --> Invalid Rows
                if !viewModel.invalidNumbers.isEmpty {
                    Text("Order Not Found")
                        .font(.headline)
                    
                    ForEach(viewModel.invalidNumbers, id: \.self) { item in
                        Text(item)
                    }
                }
                
            }
            .padding()
        }
        .overlay (alignment: .bottom) {
            VStack {
                Button("Import Excel File") {
                    viewModel.importExcelFile()
                }
            }
            .padding()
            .background(.white)
            .ignoresSafeArea()
        }
        .overlay {
            if !viewModel.isLoading && viewModel.invalidPrices.isEmpty && viewModel.validOrders.isEmpty && viewModel.invalidCourier.isEmpty && viewModel.invalidNumbers.isEmpty {
                Text("Pick an excel file to start checking the orders, first column is for order numbers, second is for prices")
            }
        }
        .willLoad(loading: viewModel.isLoading)
        .fileImporter(isPresented: $viewModel.showPicker, allowedContentTypes: [.init(filenameExtension: "xlsx")!]) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    print("URL from picked \(url)")
                    self.viewModel.selectedFile = url
                    self.viewModel.readExcelFile(url: url)
                }
            case .failure(let error):
                print("Error reading file: \(error)")
            }
        }
    }
}
