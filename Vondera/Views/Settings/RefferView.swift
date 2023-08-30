//
//  RefferView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import AlertToast


struct RefferView: View {
    var user:UserData
    @State var msg = ""
    @State var showToast = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .resizable()
                    .frame(height: 300)
                    .frame( maxWidth: .infinity)
                    .padding(25)
                
                Text("Help us expand and get a free subscribtion, by refferring other stores you will gain cashback from each payment they make which is used automaticlky to renew your monthly subscribtion.")
                    .font(.body)
                
                Spacer().frame(height: 20)
                
                Text("Your reffer code")
                    .font(.headline)
                
                HStack(alignment: .center) {
                    Text(user.id)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            CopyingData().copyToClipboard(user.id)
                        }
                    
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                
                
                Spacer().frame(height: 20)
                
                Text("Current Cashback")
                    .font(.headline)
                
                HStack(alignment: .center) {
                    Text("\(user.wallet ?? 0) EGP")
                        .bold()
                    
                    
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            copyId()
                        }
                    
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
            }
        }
        .padding()
        .navigationTitle("Reffer Program")
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.pop),
                       type: .regular,
                       title: msg)
        }
    }
    
    func copyId() {
        CopyingData().copyToClipboard(user.id)
        msg = "Reffer code copied to clipboard"
        showToast.toggle()
    }
}

struct RefferView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RefferView(user: UserData.example())
        }
    }
}
