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
    var currentRow = 1
    
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
        for (_, item) in list.enumerated() {
            if !item.hasVariants() {
                let quantity:String = (item.alwaysStocked ?? false) ? "Always Stocked" : "\(item.quantity) Pieces"
                
                
                let data = ["#\(item.id)", item.name, quantity, "\(item.realSold) Pieces", "\((item.quantity.double() * item.buyingPrice).toString()) LE"]
                addRow(items: data)
            } else {
                for(_, variant) in item.getVariant().enumerated() {
                    let quantity = (item.alwaysStocked ?? false) ? "Always Stocked" : "\(variant.quantity) Pieces"
                    let price = (item.alwaysStocked ?? false) ? "None" : "\((variant.quantity.double() * variant.cost).toString()) LE"
                    
                    let data = ["#\(item.id)", "\(item.name) - \(variant.formatOptions())", quantity, "\(variant.sold ?? 0) Pieces", price]
                    
                    addRow(items: data)
                }
            }
            
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
        var cost = 0.0
        
        list.forEach { item in
            quantity += item.getQuantity()
            realSold += item.realSold
            
            // -->
            if let stocked = item.alwaysStocked, stocked {
                cost += item.getVariant().getCost()
            }
        }
        
        let data:[String] = [
            "\(list.count) Products",
            "",
            "\(quantity) Pieces",
            "\(realSold) Pieces",
            "\(cost.toString()) LE"]
        
        addRow(items: data)
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
        
        currentRow += 1
    }
    
    func addRow(items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: currentRow, col: (index + 1)))
            cell.Cols(txt: .black, bg: .white)
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.Font = XFont(.TrebuchetMS, 8, true)
            cell.width = 100
            cell.alignmentHorizontal = .left
        }
        currentRow += 1
    }
}
