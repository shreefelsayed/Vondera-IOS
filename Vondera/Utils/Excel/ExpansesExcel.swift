//
//  SalesReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation
import SwiftXLSX

class ExpansesExcel {
    var name = "Expanses Report"
    var items:[Expense]
    let book = XWorkBook()
    var sheet:XSheet
    
    init(name: String = "Expanses Report", items: [Expense]) {
        self.name = name
        self.items = items
        sheet = book.NewSheet(name)
    }
    
    func generateReport() -> URL? {
        // MARK : Create the header
        createHeader(["#",
                      "Amount",
                      "Description",
                      "Date"])
        
        //MARK : Add Items
        for (index, expanse) in items.enumerated() {
            let data:[String] = ["#\(index + 1)",
                                 "\(expanse.amount) LE",
                                 expanse.description,
                                 "\(expanse.date.toDate().formatted())"]
            
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
        var amount = 0
        
        items.forEach { item in
            amount += item.amount
        }
        
        let data:[String] = [
            "\(items.count) Transaction",
            "\(amount) LE",
            "",
            ""]
        
        addRow(rowNumber: items.count + 2, items: data)
    }
    
    func createHeader(_ items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: 1, col: (index + 1)))
            cell.Cols(txt: .white, bg: .darkGray)
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.width = 100
            cell.Font = XFont(.TrebuchetMS, 8, true)
            cell.alignmentHorizontal = .center
        }
    }
    
    func addRow(rowNumber:Int, items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: rowNumber, col: (index + 1)))
            cell.Cols(txt: .black, bg: .white)
            cell.width = 100
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.Font = XFont(.TrebuchetMS, 5, true)
            cell.alignmentHorizontal = .left
        }
    }
}
