//
//  AppPlans.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI
import AlertToast

struct PlanItemData: Identifiable {
    var imageName:String
    var title:LocalizedStringKey
    var desc:LocalizedStringKey
    var id = 0
}


extension PlanItemData {
    static func getPlanItems() -> [PlanItemData] {
        return [
            // FREE ITEMS
            PlanItemData(imageName: "products", title: "Unlimited Products", desc: "Add unlimited products number for free", id: 0),
            
            PlanItemData(imageName: "receipt_free", title: "Print QR Receipts", desc: "Print a receipt with a QR code for your orders for free", id: 1),
            
            PlanItemData(imageName: "product_report", title: "Product Report", desc: "Tired of caculating the products of all of (need to be fulfilled) orders ? easy we have got you", id: 2),
            
            
            // QUOTE ITEMS
            PlanItemData(imageName: "order", title: "Orders Quote", desc: "Every package has orders quote, select the most suitable one for you", id: 3),
            PlanItemData(imageName: "employees", title: "Team space", desc: "You can add your team to collebrate with you, choose a plan suitable for your team size", id: 4),
            
            // PACKAGE PREMMISSIONS : 1
            PlanItemData(imageName: "e-website", title: "Ecommerce Website", desc: "Unlock Vondera's Unique ecommerce website, with a lot of settings included and a unqiue link for your store", id: 5),
            PlanItemData(imageName: "shopper", title: "Shoppers", desc: "Access your shoppers data, and export it to excel file", id: 6),
            
            // PACKAGE PREMMISSIONS : 2
            PlanItemData(imageName: "warehouse", title: "Warehouse Reports", desc: "Track your inventory and export excel reports for your stock cost", id: 7),
            
            PlanItemData(imageName: "expansion", title: "Expanses", desc: "Record your expanses for more accurate net profit and reports", id: 8),
            
            // PACKAGE PREMMISSIONS : 3
            PlanItemData(imageName: "receipts", title: "Custom Receipt Message", desc: "Customize a text to be printed on any of your receipts", id: 9),
            
            PlanItemData(imageName: "api", title: "Access apis", desc: "Connect to your webhooks, or to your shopify store using our api end points", id: 10),
        ]
    }
}

struct PlansFeatureSlider : View {
    var items:[PlanItemData]
    @Binding var currentIndex:Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(items.indices, id: \.self) { index in
                    PlanItemView(imageName: items[index].imageName, title: items[index].title, desc: items[index].desc)
                        .tag(index)
                        .padding(.horizontal, 12)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            
            PageIndicatorView(currentIndex: $currentIndex, pageCount: items.count)
                .padding(.bottom, 8)
        }
    }
}

struct PlanItemView: View {
    var imageName:String
    var title:LocalizedStringKey
    var desc:LocalizedStringKey
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                
                
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .bold()
                
                Text(desc)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .lineLimit(3, reservesSpace: true)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        
    }
}

struct PlanInfoView : View {
    var plan:Plan
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(plan.features.filter({ $0.available })) { feature in
                HStack {
                    Label(feature.name, systemImage: "checkmark")
                        .font(.body)
                        .bold()
                    
                    Spacer()
                }
            }
        }
    }
}

struct AppPlans: View {
    @ObservedObject var myUser = UserInformation.shared
    @State var currentPlanId = ""
    
    @State var selectedPlan = 0
    @State var selectedSlide = 0
    
    @StateObject var storeVM = StoreVM()
    
    @State var plans:[Plan] = []
    
    var body: some View {
        VStack(alignment: .center) {
            if !plans.isEmpty && !currentPlanId.isEmpty {
                PlansFeatureSlider(items: PlanItemData.getPlanItems(), currentIndex: $selectedSlide)
                
                HStack {
                    Text("Choose your package")
                        .bold()
                    
                    Spacer()
                }
                
                CustomTopTabBar(tabIndex: $selectedPlan, titles: plans.map({ plan in
                    return LocalizationService.shared.currentLanguage == .english_us ? plan.planName.localize() : plan.planNameAr.localize()
                }))
                
                PlanInfoView(plan: plans[selectedPlan])
                    .padding(.vertical)
                
                Spacer()
                
                Button {
                    subscribe(plans[selectedPlan].id)
                } label: {
                    Label(plans[selectedPlan].id == currentPlanId ? "Current plan" : "\(plans[selectedPlan].price) LE / Monthly", systemImage: "apple.logo")
                }
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundStyle(plans[selectedPlan].id == currentPlanId ? .black : .white)
                .disabled(plans[selectedPlan].id == currentPlanId)
                .padding()
                .background(plans[selectedPlan].id == currentPlanId ? .white : .black)
                .cornerRadius(32)
                .padding()
            } else {
                ProgressView()
            }
        }
        .toast(isPresenting: Binding(value: $storeVM.msg), alert: {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: storeVM.msg)
        })
        .padding(.horizontal)
        .task {
            AnalyticsManager.shared.openedPlansInfo()
            currentPlanId = UserInformation.shared.user?.store?.subscribedPlan?.planId ?? ""
            getData()
        }
        .willProgress(saving: storeVM.isBuying)
        .navigationTitle("Plans")
    }
    
    func subscribe(_ planId:String) {
        Task {
            do {
                AnalyticsManager.shared.paymentAttemp()
                let result = try await storeVM.purchase(planId: planId)
                if result {
                    await refreshData()
                }
            } catch {
                print("Error happened")
            }
        }
    }
    
    func getData() {
        Task {
            do {
                let items = try await PlanDao().getPaid()
                await refreshData()
                DispatchQueue.main.async {
                    self.plans = items
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func refreshData() async {
        guard let id = myUser.user?.id else {
            return
        }
        
        guard let user = await reloadUser() else {
            print("Couldn't get user with \(id)")
            return
        }
        
        DispatchQueue.main.async {
            self.currentPlanId = user.store?.subscribedPlan?.planId ?? ""
            UserInformation.shared.updateUser(user)
        }
        
    }
    
    func reloadUser() async -> UserData? {
        // id
        guard let id = myUser.user?.id else {
            return nil
        }
        
        return try? await UsersDao().getUserWithStore(userId: id)
    }
}


