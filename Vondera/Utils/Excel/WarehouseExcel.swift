//
//  SalesReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation
import SwiftXLSX

class WarehouseExcel {
    var name = "Warehouse Report"
    var list:[StoreProduct]
    let book = XWorkBook()
    var sheet:XSheet
    
    init(name: String = "Warehouse Report", list: [StoreProduct]) {
        self.name = name
        self.list = list
        sheet = book.NewSheet(name)
    }
    
    
    
    func generateReport() -> URL? {
        // MARK : Create the header
        createHeader(["Item Id.",
                      "Product Name",
                      "Avilable Quantity",
                      "Sold Quantity",
                      "Current Stock Cost"])
        
        //MARK : Add Items
        for (index, item) in list.enumerated() {
            let data:[String] = ["#\(item.id)",
                                 item.name,
                                 "\(item.quantity) Pieces",
                                 "\(item.realSold) Pieces",
                                 "\(item.quantity * Int(item.buyingPrice)) LE"]
            
            addRow(rowNumber: (index + 2), items: data)
        }
        
        addFinalRow()
              
        // MARK : Create file and save
        let fileid = book.save("\(name).xlsx")
        
        print("File path \(fileid)")
        
        let url = URL(fileURLWithPath: fileid)
        return url
    }
    
    func addFinalRow() {
        var quantity = 0
        var realSold = 0
        var stock = 0
        
        list.forEach { item in
            quantity += item.quantity
            realSold += item.realSold
            stock += (item.quantity * Int(item.buyingPrice))
        }
        
        let data:[String] = [
            "\(list.count) Products",
            "",
            "\(quantity) Pieces",
            "\(realSold) Pieces",
            "\(stock) LE"]
        
        addRow(rowNumber: list.count + 2, items: data)
    }
    
    func createHeader(_ items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: 1, col: (index + 1)))
            cell.Cols(txt: .white, bg: .darkGray)
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.Font = XFont(.TrebuchetMS, 10, true)
            cell.width = 100
            cell.alignmentHorizontal = .center
        }
    }
    
    func addRow(rowNumber:Int, items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: rowNumber, col: (index + 1)))
            cell.Cols(txt: .black, bg: .white)
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.Font = XFont(.TrebuchetMS, 8, true)
            cell.width = 100
            cell.alignmentHorizontal = .left
        }
    }
}
