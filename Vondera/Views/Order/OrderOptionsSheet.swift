//
//  OrderOptionsSheet.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/10/2023.
//

import SwiftUI
import AlertToast

struct OrderOptionsSheet: View {
    @Binding var order:Order
    @Binding var isPreseneted:Bool

    
    // Child Sheets
    @State private var qrCode = false
    @State private var contact = false
    @State private var comment = false
    @State private var editClient = false
    @State private var editProducts = false
    
    @State private var deleteAlert = false

    @State private var sheetHeight:CGFloat = .zero
    @State private var uiMessage:String?
    
    var body: some View {
        NavigationStack {
            List {
                if let myUser = UserInformation.shared.user {
                    //MARK : Show Sheet
                    Label("Print Receipt", systemImage: "printer.fill")
                        .onTapGesture {
                            Task {
                                if let uri = await ReciptPDF(orderList: [order]).render() {
                                    DispatchQueue.main.async {
                                        FileUtils().shareFile(url: uri)
                                    }
                                }
                            }
                        }
                    
                    Label("Show order QRCode", systemImage: "qrcode.viewfinder")
                        .onTapGesture {
                            qrCode = true
                        }
                    
                    //MARK : Show Sheet
                    Label("Contact Client", systemImage: "ellipsis.message.fill")
                        .onTapGesture {
                            contact = true
                        }
                    
                    // MARK : Copy Order info
                    Label("Copy Order Details", systemImage: "doc.on.clipboard")
                        .onTapGesture {
                            CopyingData().copyToClipboard(order.toString())
                        }
                    
                    if let images = order.listAttachments, !images.isEmpty {
                        Label("Download \(images.count) attachments", systemImage: "paperclip")
                            .onTapGesture {
                                uiMessage = "Downloading started"
                                DownloadManager().saveImagesToDevice(imageURLs: images.map({ URL(string: $0)! }))
                            }
                    }
                    
                    if order.canEditProducts(accountType: myUser.accountType) {
                        Label("Edit Client Info", systemImage: "pencil")
                            .onTapGesture {
                                editClient.toggle()
                            }
                        
                        Label("Edit Products", systemImage: "backpack.fill")
                            .onTapGesture {
                                editProducts.toggle()
                            }
                    }
                    
                    //MARK : Show Sheet
                    Label("Add new Comment", systemImage: "text.bubble")
                        .onTapGesture {
                            comment = true
                        }
                    
                    // TODO
                    if order.canDeleteOrder(accountType: myUser.accountType) {
                        Label("Delete Order", systemImage: "trash.fill")
                            .onTapGesture {
                                deleteAlert = true
                            }
                    }
                    
                    
                    
                }
            }
            .listStyle(.plain)
            .navigationTitle("#\(order.id)")
            .sheet(isPresented: $contact) {
                ContactDialog(phone: order.phone, toggle: $contact)
            }
            .sheet(isPresented: $qrCode) {
                OrderQRCode(order: order)
            }
            .sheet(isPresented: $comment) {
                AddCommentSheet(order: $order, isPresented: $comment)
                    
            }
            .sheet(isPresented: $editClient) {
                NavigationStack {
                    EditOrder(order: $order, isPreseneted: $editClient)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $editProducts) {
                NavigationStack {
                    EditOrderProducts(order: $order, isPreseneted: $editProducts)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .confirmationDialog("Are you sure you want to delete the order ?", isPresented: $deleteAlert, titleVisibility: .visible) {
                
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteOrder()
                    }
                }
                
                Button("Later", role: .cancel) {
                }
            }
            .toast(isPresenting: Binding(value: $uiMessage), alert: {
                AlertToast(displayMode: .banner(.pop), type: .regular, title: uiMessage)
            })
        }
        .presentationDetents([.medium, .fraction(0.75)])
        
    }
    
    func deleteOrder() async {
        let newOrder = await OrderManager().orderDelete(order:&order)
        self.order = newOrder.result
        uiMessage = "Order Deleted"
        isPreseneted.toggle()
    }
}

struct AddCommentSheet : View {
    @Binding var order:Order
    @Binding var isPresented:Bool
    
    @State private var sheetHeight: CGFloat = .zero
    @State private var addingComment = false
    @State private var comment = ""
    @State private var uiMessage:String?
    
    var body: some View {
        // MARK : Add New Comment
        VStack(alignment: .leading) {
            Text("Add comment to order")
                .font(.title2)
                .bold()
            
            HStack {
                FloatingTextField(title: "Add Comment", text: $comment, required: nil)
                    .padding(4)
                
                Button {
                    Task {
                        await addComment()
                    }
                } label: {
                    Image(systemName: "paperplane")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                .disabled(addingComment)
            }
            .padding()
            .background(.secondary.opacity(0.1))
            .cornerRadius(10)
        }
        .toast(isPresenting: Binding(value: $uiMessage), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: uiMessage)
        })
        .padding()
        .navigationTitle("Add Comment")
        .presentationDetents([.fraction(0.25)])
    }
    
    func addComment() async {
        if let _ = UserInformation.shared.user, !comment.isBlank {
            addingComment = true
            
            let newOrder = await OrderManager().addComment(order: &order, msg: comment, code: 0)
            
            order = newOrder
            uiMessage = "Comment Added"
            comment = ""
            addingComment = false
        }
    }
}

struct OrderQRCode : View {
    let order:Order
    @State private var sheetHeight: CGFloat = .zero

    var body: some View {
        VStack(alignment: .center) {
            Text("#\(order.id)")
                .font(.title3)
                .bold()
            
            if let qr = order.id.qrCodeUIImage {
                Image(uiImage: qr)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
        }
        .presentationDetents([.fraction(0.45)])
    }
}


#Preview {
    NavigationStack {
        OrderOptionsSheet(order: .constant(Order.example()), isPreseneted: .constant(true))
    }
}
