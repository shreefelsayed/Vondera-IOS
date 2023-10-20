//
//  StoreCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct StoreCategory: View {
    @State var store:Store
    
    var body: some View {
        VStack {
            PickCategory(sheetVisible: <#T##Bool#>, selected: <#T##Int#>)
        }
        .navigationTitle("Store Category")
    }
}

#Preview {
    StoreCategory()
}
