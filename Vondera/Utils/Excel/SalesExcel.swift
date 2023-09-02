//
//  SalesReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation
import SwiftXLSX

class SalesExcel {
    var name = "Sales Report"
    var listOrders:[Order]
    let book = XWorkBook()
    var sheet:XSheet
    
    init(name: String = "Sales Report", listOrders: [Order]) {
        self.name = name
        self.listOrders = listOrders
        sheet = book.NewSheet(name)
    }
    
    func generateReport() {
        // MARK : Create the header
        createHeader(["Order ID", "Name", "Government", "Order Price", "Courier Commission", "COD", "Product Cost", "Sales Commission", "Net Profit", "Statue", "Sold By"])
        
        //MARK : Add Items
        for (index, order) in listOrders.enumerated() {
            let data:[String] = ["#\(order.id)", order.name, order.gov, "\(order.totalPrice) LE", "\(order.courierShippingFees ?? 0) LE", "\(order.COD) LE", "\(order.buyingPrice) LE", "\(order.finalCommission) LE", "\(order.netProfitFinal) LE", order.statue, order.owner ?? ""]
            
            addRow(rowNumber: (index + 2), items: data)
        }
              
        // MARK : Create file and save
        let fileid = book.save("\(name).xlsx")
        print("File path \(fileid)")
        let url = URL(fileURLWithPath: fileid)
        FileUtils().shareFile(url: url)
    }
    
    func createHeader(_ items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: 1, col: (index + 1)))
            cell.Cols(txt: .white, bg: .darkGray)
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.Font = XFont(.TrebuchetMS, 10, true)
            cell.alignmentHorizontal = .center
        }
    }
    
    func addRow(rowNumber:Int, items:[String]) {
        for (index, title) in items.enumerated() {
            let cell = sheet.AddCell(XCoords(row: rowNumber, col: (index + 1)))
            cell.Cols(txt: .black, bg: .white)
            cell.value = .text(title.uppercased(with: .autoupdatingCurrent))
            cell.Font = XFont(.TrebuchetMS, 8, true)
            cell.alignmentHorizontal = .left
        }
    }
}
