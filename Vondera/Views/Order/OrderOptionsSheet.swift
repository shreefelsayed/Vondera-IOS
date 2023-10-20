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

    @State private var myUser:UserData?
    
    // Child Sheets
    @State private var qrCode = false
    @State private var contact = false
    @State private var comment = false
    @State private var editClient = false

    
    @State private var deleteAlert = false

    @State private var sheetHeight:CGFloat = .zero
    @State private var uiMessage:String?
    
    var body: some View {
        List {
            
            Text("#\(order.id)")
                .font(.title2)
            
            
            //MARK : Show Sheet
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
                    uiMessage = "Order Data copied to clipboard"
                }
            
            //TODO
            Label("Edit Client Info", systemImage: "pencil")
                .onTapGesture {
                    editClient.toggle()
                }
            
            //TODO
            Label("Edit Products", systemImage: "backpack.fill")
            
            //MARK : Show Sheet
            Label("Add new Comment", systemImage: "text.bubble")
                .onTapGesture {
                    comment = true
                }
            
            // TODO
            if order.canDeleteOrder(accountType: myUser?.accountType ?? "Owner") {
                Label("Delete Order", systemImage: "trash.fill")
                    .onTapGesture {
                        deleteAlert = true
                    }
            }
            
            Label("Print Receipt", systemImage: "printer.fill")
                .onTapGesture {
                    Task {
                        await ReciptPDF(orderList: [order]).generateAndOpenPDF()
                        isPreseneted.toggle()
                    }
                }
        }
        .sheet(isPresented: $contact) {
            ContactDialog(phone: order.phone, toggle: $contact)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $qrCode) {
            OrderQRCode(order: order)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)

        }
        .sheet(isPresented: $comment) {
            AddCommentSheet(order: $order, isPresented: $comment, myUser: myUser)
                .presentationDetents([.height(150), .height(250)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $editClient) {
            NavigationStack {
                EditOrder(order: $order, isPreseneted: $editClient)

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
        .task {
            myUser = UserInformation.shared.getUser()
        }
        .listStyle(.plain)
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
    var myUser:UserData?
    
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
    }
    
    func addComment() async {
        guard !comment.isBlank && myUser != nil else {
            return
        }
        addingComment = true
        
        var newOrder = await OrderManager().addComment(order: &order, msg: comment, code: 0)
        
        order = newOrder
        uiMessage = "Comment Added"
        comment = ""
        addingComment = false
    }
}

struct OrderQRCode : View {
    let order:Order
    
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
    }
}


#Preview {
    NavigationStack {
        OrderOptionsSheet(order: .constant(Order.example()), isPreseneted: .constant(true))
    }
}
