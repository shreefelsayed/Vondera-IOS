//
//  SubscribtionsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import StoreKit
import FirebaseFirestore

struct SubscribtionsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var user = UserInformation.shared
    var body: some View {
        ZStack {
            if let plan = user.user?.store?.storePlanInfo {
                if plan.planId == "OnDemand" {
                    OnDemandWallet(user: UserInformation.shared.user!)
                } else {
                    SubscribtionCard(plan: plan)
                }
            }
        }
        .withAccessLevel(accessKey: .subscription, presentation: presentationMode)
    }
}

struct SubscribtionCard : View {
    var plan:StorePlanInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Your plan")
                        
                        Text(plan.name)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Image(.icLogoWhite)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color(hex: plan.getColorHex()))
                
                VStack(alignment: .leading) {
                    if let expireData = plan.expireDate {
                        Text("Your next bill we be on \(expireData.toString(format: "yyyy MMMM, dd"))")
                    }
                    
                    HStack {
                        Spacer()
                        
                        if !plan.isFreePlan() {
                            NavigationLink {
                                AppPlans()
                            } label: {
                                Text("Renew Now !")
                                    .font(.headline)
                                    .padding(6)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                }
                .padding()
                .background(.white)
               
            }
            .cornerRadius(24)
            
            HStack {
                NavigationLink {
                    AppPlans()
                } label: {
                    Text("Change Plan")
                        .font(.headline)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1.5))
                }
                .buttonStyle(.plain)

                
                
                Spacer()
                
                if plan.planId != "OnDemand" && plan.planId != "free" {
                    Button(action: {
                        Task {
                            await manageSubscriptions()
                        }
                    }, label: {
                        Text("Unsubscribe")
                    })
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(6)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
            }
        }
        .padding()
        .navigationTitle("Subscribtions")
        
    }
    
    @MainActor
    func manageSubscriptions() async {
        if let windowScene = UIApplication.shared.connectedScenes.first {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene as! UIWindowScene)
            } catch {
                print(error)
            }
        }
    }
}

struct OnDemandWallet: View {
    var user: UserData
    @State private var showingAddFundsSheet = false
    @State private var amountToAdd: String = ""
    @State private var isRequesting = false

    @State private var items = [OnDemandTransactionModel]()
    @State private var isLoading = false
    @State private var canLoadMore = true
    @State private var lastSnapshot:DocumentSnapshot?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // MARK: Change plan button
                HStack {
                    Text("On Demand Plan")
                        .font(.headline)
                    
                    Spacer()
                    
                    NavigationLink {
                        AppPlans()
                    } label: {
                        Text("Change Plan")
                            .font(.headline)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
                
                balanceCard()
                
                // --> Display transactions
                Spacer().frame(height: 12)
                
                ForEach(items, id: \.id) { item in
                    transactionCard(item:item)
                    if canLoadMore && items.last?.id == item.id {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .onAppear {
                            Task { await loadItems() }
                        }
                    }
                }
                
                if !isLoading && items.isEmpty {
                    VStack {
                        Spacer().frame(height: 42)
                        EmptyMessageView(systemName: "arrow.left.arrow.right", msg: "No transactions were made yet")
                        Spacer().frame(height: 42)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await refreshItems()
        }
        .sheet(isPresented: $showingAddFundsSheet) {
            addFundsSheet()
        }
        .task {
            await loadItems()
        }
        .navigationTitle("On Demand")
        .padding()
        .willProgress(saving: isRequesting, msg: "Creating payment link ..")
    }
    
    @ViewBuilder func balanceCard() -> some View {
        VStack {
            Text("Current Balance")
                .foregroundColor(.white)
                .font(.headline)
                .lineLimit(1)
                .padding()
            
            HStack {
                Spacer()
                Text("\(Int(user.store?.ordersWallet ?? 0.0)) EGP")
                    .foregroundColor(.white)
                    .font(.title)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                Spacer()
                Button("Add Funds") {
                    showingAddFundsSheet = true
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    func addFundsSheet() -> some View {
        VStack {
            Text("Add Funds")
                .font(.headline)
                .padding()
            
            Text("Enter the amount that you want to add to your wallet.")
                .font(.body)
                .bold()
            
            TextField("Enter amount", text: $amountToAdd)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Text("Amount must be 200 EGP or more")
                .foregroundColor(.red)
                .font(.footnote)
                .padding(.horizontal)
            
            Button("Pay") {
                guard validateAmount() else { return }
                Task { await pay() }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.medium])
    }
    
    private func pay() async {
        do {
            self.isRequesting = true
            
            let data : [String:Any] = ["merchantId": UserInformation.shared.user?.store?.merchantId ?? "", "amount": Int(amountToAdd)!]
            
            let result = try await FirebaseFunctionCaller().callFunction(functionName: "onDemand-createPaymentLink", data: data)
            
            print(result.data)
            DispatchQueue.main.async { self.isRequesting = false }
            
            guard let resultData = result.data as? [String: Any] else {
                ToastManager.shared.showToast(msg: "Error happened", toastType: .error)
                return
            }
            
            let success = resultData["success"] as! Bool
            let msg = resultData["msg"] as! String
            let url = resultData["url"] as? String
            guard success, let url = url else {
                ToastManager.shared.showToast(msg: msg.localize(), toastType: .error)
                return
            }
            
            // --> Copy Data
            DispatchQueue.main.async {
                if let url = URL(string: url) {
                    UIApplication.shared.open(url)
                    self.showingAddFundsSheet = false
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func validateAmount() -> Bool {
        if let amount = Double(amountToAdd), amount >= 50 {
            return true
        } else {
            ToastManager.shared.showToast(msg: "Enter a valid amount", toastType: .error)
            return false
        }
    }
    
    @ViewBuilder private func transactionCard(item:OnDemandTransactionModel) -> some View {
        HStack(alignment: .center) {
            Image(.btnTransactions)
            
            VStack(alignment:.leading) {
                Text("#\(item.id)")
                    .bold()
                
                Text(item.amount < 0 ? "Order commission" : "Deposit")
                    .font(.headline)
                
                Text(item.date.asFormatedString("h:mm a dd/MM/yy"))
                    .font(.caption)
               
            }
            
            Spacer()
            
            Text("EGP \(item.amount.toString(withDecimalPlaces: 2))")
                .bold()
                .foregroundStyle(item.amount < 0 ? .red : Color.accentColor)
        }
    }
    
    func loadItems() async {
        guard !isLoading , canLoadMore, let storeId = UserInformation.shared.user?.storeId else { return }
        self.isLoading = true
        
        do {
            let result = try await OnDemandDao(storeId: storeId).getAll(lastSnapshot: lastSnapshot)
            self.lastSnapshot = result.1
            self.items.append(contentsOf: result.0)
            self.canLoadMore = !result.0.isEmpty
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "On Demand Screen")
            print(error.localizedDescription)
        }
        
        self.isLoading = false
    }
    
    func refreshItems() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await loadItems()
    }
}

#Preview {
    SubscribtionCard(plan: StorePlanInfo())
}
