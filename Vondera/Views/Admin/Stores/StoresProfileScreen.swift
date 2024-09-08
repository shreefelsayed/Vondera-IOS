//
//  StoresProfileScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class StoreProfileViewModel : ObservableObject {
    let storeId:String
    @Published var isLoading = false
    @Published var store:Store?
    
    @Published var isFetching = false
    @Published var orders = [Order]()
    
    var hasMore = true
    var lastDoc:DocumentSnapshot? = nil
    
    init(id:String) {
        self.storeId = id
        Task { 
            await fetchData(id)
            await fetchOrders()
        }
    }
    
    func fetchData(_ storeId:String) async {
        self.isLoading = true
        
        do {
            let result = try await StoresDao().getStore(uId: storeId)
            DispatchQueue.main.async {
                self.isLoading = false
                self.store = result
            }
        } catch {
            print(error)
        }
    }
    
    func fetchOrders() async {
        guard hasMore, !isFetching else { return }
        isFetching = true
        
        do {
            let result = try await OrdersDao(storeId: storeId).getAll(lastSnapShot: lastDoc)
            DispatchQueue.main.async {
                self.orders.append(contentsOf: result.0)
                self.lastDoc = result.1
                self.hasMore = !result.0.isEmpty
                self.isFetching = false
            }
        } catch {
            print(error)
        }
    }
}

struct StoresProfileScreen: View {
    @StateObject private var viewModel:StoreProfileViewModel
    @State private var subscribeSheet = false
    
    init(id: String) {
        self._viewModel = StateObject(wrappedValue: StoreProfileViewModel(id: id))
    }
    
    var body: some View {
        ScrollView {
            if let store = viewModel.store {
                LazyVStack(alignment: .leading) {
                    // MARK : Store stuff
                    HStack {
                        CachedImageView(imageUrl: store.logo ?? "", placeHolder: UIImage(resource: .appIcon))
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
                        // MARK : Plan Info
                        VStack (alignment: .leading) {
                            Text("#\(store.merchantId)")
                                .font(.headline)
                            
                            Text("Current Plan : \(store.storePlanInfo?.name ?? "None")")
                            
                            ProgressView(value: store.storePlanInfo?.getPercentage())
                                .accentColor((store.storePlanInfo?.isUsageAlert() ?? false) ? Color.red : Color.accentColor)
                                .frame(maxWidth: .infinity)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Monthly Limit")
                                    .bold()
                                
                                Spacer()
                                
                                Text("\(store.storePlanInfo?.planFeatures.currentOrders ?? 0) Of \(store.storePlanInfo?.planFeatures.maxOrders ?? 0 ) Orders")
                                    .foregroundStyle( (store.storePlanInfo?.isUsageAlert() ?? false) ? .red : .secondary)
                                    .font(.caption)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Expire Date")
                                    .bold()
                                
                                Spacer()
                                
                                Text("\(store.storePlanInfo?.expireDate.toString() ?? "")")
                                    .foregroundStyle( (store.storePlanInfo?.isDateAlert() ?? false) ? .red : .secondary)
                            }
                            
                            Divider()
                            
                            Link(store.getStoreDomain(), destination: URL(string: store.getStoreDomain())!)
                        }
                    }
                    
                    // MARK : The ORders
                    ForEach($viewModel.orders, id: \.id) { storeOrder in
                        VStack {
                            OrderCard(order: storeOrder)
                            if viewModel.hasMore && viewModel.orders.last?.id == storeOrder.id {
                                ProgressView()
                                .onAppear {
                                    Task { await viewModel.fetchOrders() }
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.store?.name ?? "")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Subscribe") {
                    subscribeSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $subscribeSheet) {
            if let store = viewModel.store {
                SubscribeSheet(isPresented: $subscribeSheet, store: store, onSubscribed: {
                    Task { await viewModel.fetchData(store.ownerId) }
                })
                .presentationDetents([.fraction(0.7)])
            }
        }
    }
}


struct SubscribeSheet : View {
    @Binding var isPresented:Bool
    var store:Store
    var onSubscribed:(() -> ())
    
    @State private var isLoading = false
    @State private var isSubscribing = false
    
    @State private var plans = [PlanInfo]()
    @State private var selectedPlan:PlanInfo?
    @State private var subPlanId = "month"
    
    @State private var priceInput = "0"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Verify Subscribe plan")
                .font(.title2)
                .bold()
            
            HStack {
                Text("Duration")
                
                Spacer()
                
                Picker("Duration", selection: $subPlanId) {
                    Text("Monthly")
                        .tag("month")
                    
                    Text("Quarter")
                        .tag("quartar")
                    
                    Text("Yearly")
                        .tag("year")
                    
                }
            }
            .onChange(of: subPlanId) { _ in
                priceInput = "\(selectedPlan?.getPlanPrice(subPlanId) ?? 0)"
            }
            
            
            ForEach(plans, id: \.id) { plan in
                HStack {
                    Text(plan.name)
                    
                    Spacer()
                    
                    Text("EGP \(plan.getPlanPrice(subPlanId))")
                }
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .background(selectedPlan?.id == plan.id ? Color.accentColor : .black)
                .cornerRadius(32)
                .onTapGesture {
                    withAnimation {
                        self.selectedPlan = plan
                        self.priceInput = "\(selectedPlan?.getPlanPrice(subPlanId) ?? 0)"
                    }
                }
            }
            
            Divider()
            
            let priceDisabled = !(UserInformation.shared.user?.isShreif ?? false) && (store.renewCount ?? 0) > 0
            
            FloatingTextField(title: "Amount Paid By User", text: $priceInput, required: nil, keyboard: .numberPad)
                .disabled(priceDisabled)
            
            if priceDisabled {
                Text("You can't make a discount, because this user subscribed before !")
                    .bold()
                    .foregroundStyle(.red)
            }
            
            ButtonLarge(label: "Subscribe") {
                Task { await subscribe() }
            }
            .disabled(priceInput.toIntOrZero() <= 0 || isSubscribing)
        }
        .padding()
        .task {
            await fetchPlans()
        }
        .willProgress(saving: isSubscribing, msg: "Subscribing user ..")
        .willLoad(loading: isLoading)
    }
    
    private func subscribe() async {
        guard let selectedPlan = selectedPlan, priceInput.toIntOrZero() > 0 else { return }
        self.isSubscribing = true
        
        do {
            let dataMap:[String:Any] = ["merchantId": store.merchantId,
                                        "planId": selectedPlan.id,
                                        "subPlan": subPlanId,
                                        "paidAmount": priceInput.toIntOrZero(),
                                        "record": true,
                                        "method": "Admin",
                                        "userId": UserInformation.shared.user?.id ?? ""]
            
            let result = try await FirebaseFunctionCaller().callFunction(functionName: "subscribtions-subscribeToPlan", data: dataMap)
            
            DispatchQueue.main.async {
                self.isSubscribing = false
                guard let _ = result.data as? [String: Any] else {
                    ToastManager.shared.showToast(msg: "Error happened", toastType: .error)
                    return
                }
                
                ToastManager.shared.showToast(msg: "User Subscribed", toastType: .success)
                self.onSubscribed()
                self.isPresented = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    private func fetchPlans() async {
        self.isLoading = true
        do {
            let plans = try await PlanDao().getPaid()
            
            DispatchQueue.main.async {
                self.plans = plans.sorted(by: {$0.getBasePrice() < $1.getBasePrice()})
                self.selectedPlan = plans.first
                self.priceInput = "\(selectedPlan?.getPlanPrice(subPlanId) ?? 0)"
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
}
