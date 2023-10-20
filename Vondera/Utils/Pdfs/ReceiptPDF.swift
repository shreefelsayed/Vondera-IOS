//
//  ReceiptPDF.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/08/2023.
//

import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PDFKit
import NetworkImage

@MainActor
class ReciptPDF {
    var orderList:[Order]
    var myUser:UserData?
    let a5PageSize = CGSize(width: 420.9, height: 595.2)

    init(orderList: [Order]) async {
        self.orderList = orderList
        self.myUser = UserInformation.shared.getUser()
    }
    
    
    func generateAndOpenPDF() {
        let url = render()
        
        FileUtils().shareFile(url: url)
    }
    
    func render() -> URL {
        let url = URL.documentsDirectory.appending(path: "receipt.pdf")
        var box = CGRect(origin: .zero, size: a5PageSize)
        
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return url
        }
        
        for order in orderList {
            let updatedRenderer = ImageRenderer(content: PDFReceipt(order: order, myUser: myUser))
            updatedRenderer.render { size, context in
                pdf.beginPDFPage(nil)
                context(pdf)
                pdf.endPDFPage()
            }
        }
        
        // --> Create the final page
        if orderList.count > 1 {
            let batchSize = 10
            let totalItems = orderList.getFinalProductList().count
            
            for startIndex in stride(from: 0, to: totalItems, by: batchSize) {
                let endIndex = min(startIndex + batchSize, totalItems)
                let batchOrders = Array(orderList.getFinalProductList()[startIndex..<endIndex])
                
                let updatedRenderer = ImageRenderer(content: PDFFinalPage(products: batchOrders))
                updatedRenderer.render { size, context in
                    pdf.beginPDFPage(nil)
                    context(pdf)
                    pdf.endPDFPage()
                }
            }
        }

        
        
        // 7: Close the PDF file
        pdf.closePDF()
        print("Location \(url.absoluteString)")
        return url
    }
    
    
}



struct PDFViewerUsingUrl: UIViewRepresentable {
    let pdfURL: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let pdfDocument = PDFDocument(url: pdfURL) {
            pdfView.document = pdfDocument
        } else {
            print("Error: Unable to open PDF.")
        }
    }
}

struct Rceipts:View {
    var orders:[Order]
    var myUser: UserData?
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(orders) { order in
                PDFReceipt(order: order, myUser: myUser)
            }
        }
        .frame(maxWidth: .infinity) // Set the VStack width to the maximum available width
    }
}

struct PDFFinalPage : View {
    var products:[OrderProductObject]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Product Name")
                Spacer()
                Text("Option (Varient)")
                Spacer()
                Text("Quantity")
            }
            .font(.headline)
            .padding(.horizontal)
            .background(Color.gray.opacity(0.3))
            
            ForEach(products, id: \.self) { product in
                HStack(alignment: .center) {
                    Text(product.name)
                    Spacer()
                    Text(product.getVarientsString())
                    Spacer()
                    Text("\(product.quantity) Pieces")
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 2)

                Divider()
            }
            
            HStack(alignment: .center) {
                Text("Total Pieces")
                Spacer()
                Text("")
                Spacer()
                Text("\(products.getTotalQuantity()) Pieces")
            }
            .font(.headline)
            .padding(.horizontal)
            
        }
        .frame(width: 400, height: 560)
        .padding()
    }
}

struct PDFReceipt: View {
    var order:Order
    var myUser:UserData?
    let a5PageSize = CGSize(width: 595.2, height: 420.9)

    
    var body: some View {
        VStack(alignment: .center) {
            // HEADER
            HStack (alignment: .center){
                // ORDER ID
                Text("#\(order.id)")
                    .font(.caption)
                    .bold()
                
                Spacer()
                
                HStack(alignment: .center) {
                    // MARK : Store Logo
                    NetworkImage(url: URL(string: myUser?.store!.logo ?? "" )) { image in
                        image.centerCropped()
                    } placeholder: {
                        ProgressView()
                    } fallback: {
                        Image("defaultPhoto")
                            .resizable()
                            .centerCropped()
                    }
                    .background(Color.white)
                    .frame(width: 40, height: 40, alignment: .bottomTrailing)
                    .clipShape(Circle())
                    
                    VStack(alignment: .center) {
                        Text(myUser?.store?.name ?? "")
                            .font(.caption)
                            .bold()
                        
                        Text(myUser?.store?.slogan ?? "")
                            .font(.caption)
                    }
                    .padding(.horizontal, 20)
                }
                
                
                
                Spacer()
                
                // QR CODE
                Image(uiImage: order.id.qrCodeUIImage)
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            
            // Client INFO
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name : \(order.name) - Phone Number : \(order.phone)")
                    
                    Text("Address : \(order.gov) - \(order.address)")
                     
                    Text("Purchase Date : \(order.date.toDate().formatted())")
                }
                
                Spacer()
            }
            .font(.caption2)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            
            
            // ITEMS
            TableView(order: order)
                .padding(.vertical, 6)
            
            // Message
            VStack(alignment: .center) {
                Text(myUser?.store?.customMessage)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 12)
            
            Spacer()
        }
        .frame(width: 400, height: 560)
        .padding()
        
    }
    
    struct TableView: View {
        let order: Order

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Table header
                HStack(alignment: .center) {
                    Text("Product")
                    Spacer()
                    Text("Varient")
                    Spacer()
                    Text("Quantity")
                    Spacer()
                    Text("Total")
                }
                .font(.caption)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.3))
                
                // Table rows
                ForEach(order.listProducts!, id: \.self) { product in
                    HStack(alignment: .center) {
                        Text(product.name)
                        
                        Spacer()
                        
                        Text(product.getVarientsString())
                           
                        Spacer()
                        
                        Text("\(product.quantity) x \(Int(product.price))")
                            
                        Spacer()
                        
                        Text("\(Int(Double(product.quantity) * product.price)) EGP")
                        
                    }
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 2)

                    Divider()
                }
                
                VStack (alignment: .leading, spacing: 0) {
                    // Shipping Fees
                    HStack(alignment: .center) {
                        Text("Shipping Fees")
                            .bold()
                            .frame(maxWidth: .infinity)
                        
                        Text("-")
                            .frame(maxWidth: .infinity)
                        
                        
                        Text("-")
                            .frame(maxWidth: .infinity)
                        
                        Text("+ \(order.clientShippingFees) EGP")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .font(.caption2)
                    .padding(.horizontal, 2)
                    
                    Divider()
                    
                    // DISCOUNT
                    if(order.discount ?? 0 > 0) {
                        HStack(alignment: .center) {
                            Text("Discount")
                                .font(.caption2)
                                .bold()
                                .frame(maxWidth: .infinity)
                            
                            Text("-")
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                            
                            
                            Text("-")
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                            
                            Text("- \(order.discount ?? 0) EGP")
                                .font(.caption2)
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 2)
                        Divider()
                    }
                    
                    // DEPOSIT
                    if(order.deposit != nil && order.deposit! > 0) {
                        HStack(alignment: .center) {
                            Text("Deposit")
                                .font(.caption2)
                                .bold()
                                .frame(maxWidth: .infinity)
                            
                            Text("-")
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                            
                            
                            Text("-")
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                            
                            Text("- \(Int(order.deposit!)) EGP")
                                .font(.caption2)
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 2)
                        Divider()
                    }
                    
                    // COD
                    HStack(alignment: .center) {
                        Text("COD")
                            .font(.caption2)
                            .bold()
                            .frame(maxWidth: .infinity)
                        
                        Text("-")
                            .font(.caption2)
                            .frame(maxWidth: .infinity)
                        
                        
                        Text("-")
                            .font(.caption2)
                            .frame(maxWidth: .infinity)
                        
                        Text("\(order.amountToGet) EGP")
                            .font(.caption2)
                            .underline(true, color: .blue)
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 2)
                }
                
            }
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
        }
        
    }
}
