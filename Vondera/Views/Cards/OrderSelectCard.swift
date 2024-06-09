//
//  OrderCard.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import PDFViewer

struct OrderSelectCard: View {
    @Binding var order:Order
    @Binding var checked:Bool
    
    var body: some View {
        HStack {
            CheckBoxView(checked: $checked)
            
            Divider()
            
            OrderCard(order: $order, showPreview: false)
        }
        .cardView()
    }
}

#Preview {
    List {
        OrderSelectCard(order: .constant(Order.example()), checked: .constant(true))
    }
}
