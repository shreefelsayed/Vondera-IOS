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
        self.listOrders = listOrders.filter({ $0.isHidden == false && $0.statue != "Deleted" })
        sheet = book.NewSheet(name)
    }
    
    func generateReport() -> URL? {
        // MARK : Create the header
        createHeader(["Order ID",
                      "Name",
                      "City",
                      "Order Price",
                      "Courier Commission",
                      "COD",
                      "Cost",
                      "Sales Commission",
                      "Net Profit",
                      "Statue",
                      "Sold By"])
        
        //MARK : Add Items
        for (index, order) in listOrders.enumerated() {
            let data:[String] = ["#\(order.id)",
                                 order.name, order.gov,
                                 "\(order.totalPrice.toString()) LE",
                                 "\((order.courierShippingFees ?? 0).toString()) LE",
                                 "\(order.COD.toString()) LE",
                                 "\(order.buyingPrice.toString()) LE",
                                 "\(order.finalCommission.toString()) LE",
                                 "\(order.netProfitFinal.toString()) LE",
                                 order.statue,
                                 order.owner ?? ""]
            
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
        var totalPrice = 0.0
        var courierShippingFees = 0.0
        var cod = 0.0
        var buyingPrice = 0.0
        var finalCommission = 0.0
        var netProfitFinal = 0.0
        
        listOrders.forEach { order in
            totalPrice += order.totalPrice
            courierShippingFees += order.courierShippingFees ?? 0
            cod += order.COD
            buyingPrice += order.buyingPrice
            finalCommission += order.finalCommission
            netProfitFinal += order.netProfitFinal
        }
        
        let data:[String] = [
            "\(listOrders.count) Orders",
            "",
            "",
            "\(totalPrice.toString()) LE",
            "\(courierShippingFees.toString()) LE",
            "\(cod.toString()) LE",
            "\(buyingPrice.toString()) LE",
            "\(finalCommission.toString()) LE",
            "\(netProfitFinal.toString()) LE",
            "",
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
