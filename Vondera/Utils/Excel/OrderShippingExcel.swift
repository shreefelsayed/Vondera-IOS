//
//  SalesReport.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation
import SwiftXLSX

class OrderShippingExcel {
    var name = "Orders"
    var listOrders:[Order]
    let book = XWorkBook()
    var sheet:XSheet
    
    init(name: String = "Orders", listOrders: [Order]) {
        self.name = name
        self.listOrders = listOrders.filter({$0.isHidden == false && $0.statue != "Deleted"})
        sheet = book.NewSheet(name)
    }
    
    func generateReport() -> URL? {
        // MARK : Create the header
        createHeader(["Order ID",
                      "Name",
                      "Phone",
                      "Other Phone",
                      "Products",
                      "Address",
                      "Cash",
                      "Statue",
                      "Notes"])
        
        //MARK : Add Items
        for (index, order) in listOrders.enumerated() {
            
            let data:[String] = ["#\(order.id)",
                                 order.name,
                                 order.phone,
                                 order.otherPhone ?? "",
                                 order.productsInfo,
                                 order.gov + " - " + order.address,
                                 "\(order.COD.toString()) LE",
                                 order.statue,
                                 order.notes ?? ""]
            
            addRow(rowNumber: (index + 2), items: data)
        }
        
        addFinalRow()
              
        // MARK : Create file and save
        let fileid = book.save("\(name).xlsx")
        let url = URL(fileURLWithPath: fileid)
        return url
    }
    
    func addFinalRow() {
        var cod = 0.0
        
        listOrders.forEach { order in
            cod += order.COD
        }
        
        let data:[String] = [
            "\(listOrders.count) Orders",
            "",
            "",
            "",
            "",
            "\(cod.toString()) LE",
            ""]
        
        addRow(rowNumber: listOrders.count + 2, items: data)
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
