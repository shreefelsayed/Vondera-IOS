//
//  AppPlans.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI
import AlertToast


struct AppPlans: View {
    @ObservedObject var myUser = UserInformation.shared
    @StateObject var storeVM = StoreKitManager()
    
    @State var selectedPlan = 0
    @State var selectedSlide = 0
    
    @State private var currentPlanId = ""
    @State private var plans:[PlanInfo] = []
    @State private var isLoading = false
    
    @State private var showPickDurationDialog = false
    
    var body: some View {
        VStack(alignment: .center) {
            if !plans.isEmpty && !currentPlanId.isEmpty {
                PlansFeatureSlider(currentIndex: $selectedSlide)
                    .padding(.top, 24)
                
                HStack {
                    Text("Select your plan")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                
                CustomTopTabBar(tabIndex: $selectedPlan, titles: plans.map({ plan in
                    return plan.name.localize()
                }))
                
                PlanInfoView(plan: plans[selectedPlan])
                    .padding(.vertical)
                
                Spacer()
                
                Button {
                    showPickDurationDialog.toggle()
                } label: {
                    Text(plans[selectedPlan].getButtonTitle())
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .background(.black)
                .cornerRadius(32)
                .padding()
            }
        }
        .toast(isPresenting: Binding(value: $storeVM.msg), alert: {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: storeVM.msg)
        })
        .padding(.horizontal)
        .overlay(alignment: .center) {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            AnalyticsManager.shared.openedPlansInfo()
            currentPlanId = UserInformation.shared.user?.store?.storePlanInfo?.planId ?? ""
            getData()
        }
        .sheet(isPresented: $showPickDurationDialog, content: {
            if !plans.isEmpty {
                let pickerPlan = plans[selectedPlan]
                DurationSheet(isPresenting: $showPickDurationDialog, plan: pickerPlan) { subPlanId in
                    subscribe(pickerPlan.id, subPlanId)
                }
            }
        })
        .willProgress(saving: storeVM.isBuying)
        .navigationTitle("Plans")
    }
    
    func subscribe(_ planId:String, _ subPlanId:String) {
        Task {
            do {
                AnalyticsManager.shared.paymentAttemp()
                try await storeVM.purchase(planId: planId, subPlanId: subPlanId)
            } catch {
                print("Error happened")
            }
        }
    }
    
    func getData() {
        Task {
            do {
                let items = try await PlanDao().getPaid()
                DispatchQueue.main.async {
                    self.currentPlanId = UserInformation.shared.user?.store?.storePlanInfo?.planId ?? "free"
                    self.plans = items.sorted(by: {$0.getBasePrice() < $1.getBasePrice()})
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}

struct OnPaymentSuccess : View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Image(.imgSubscribed)
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            
            Text("Successfully Subscribed")
                .font(.title)
                .bold()
                .foregroundStyle(Color.accentColor)
            
            Text("You have successfully subscribed to the plan")
                .font(.headline)
                .foregroundStyle(.secondary)
                .bold()
                .multilineTextAlignment(.center)
            
            ButtonLarge(label: "Done") {
                presentationMode.wrappedValue.dismiss()
            }
            
            Spacer()
        }
        .padding()
    }
    
    func refreshData() async {
        guard let id = UserInformation.shared.user?.id else {
            return
        }
        
        guard let user = await reloadUser() else {
            print("Couldn't get user with \(id)")
            return
        }
        
        DispatchQueue.main.async {
            UserInformation.shared.updateUser(user)
        }
        
    }
    
    func reloadUser() async -> UserData? {
        guard let id = UserInformation.shared.user?.id else {
            return nil
        }
        
        return try? await UsersDao().getUserWithStore(userId: id)
    }
}


// MARK : Features Slider
struct PlansFeatureSlider : View {
    @Binding var currentIndex:Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            TabView(selection: $currentIndex) {
                let items = FeatureKeys.allCases.dropFirst(3)
                
                ForEach(items.indices, id: \.self) { index in
                    let feature = FeatureKeys.allCases[index]
                    PlanItemView(imageName: feature.getDrawable(), title: feature.getTitle(), desc: feature.getDesc())
                        .tag(index)
                        .padding(.horizontal, 12)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 180)
            
            PageIndicatorView(currentIndex: $currentIndex, pageCount: FeatureKeys.allCases.count)
                .padding(.bottom, 8)
        }
    }
}

// MARK : Feature View
struct PlanItemView: View {
    var imageName:ImageResource
    var title:LocalizedStringKey
    var desc:LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                
                
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
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding()
        
    }
}

// MARK : Plan Small Features
struct PlanInfoView : View {
    var plan:PlanInfo
    
    var body: some View {
        ScrollView {
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
}


// MARK : The Duration Picker Sheet
struct DurationSheet :View {
    @State private var sheetHeight: CGFloat = .zero
    @Binding var isPresenting:Bool
    var plan:PlanInfo
    var onPicked:((String) -> ())
    
    @State private var showCodeDialog = false
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(plan.getButtonTitle())
                .font(.title)
                .bold()
                .padding()
            
            Spacer()
            
            ForEach(plan.planInfoPrices) { varient in
                VStack(alignment: .center, spacing: 6) {
                    Button(action: {
                        onPicked(varient.id)
                        isPresenting = false
                    }, label: {
                        Label( "EGP \(varient.price) / \(varient.getDurationDisplay().toString())", systemImage: "apple.logo")
                    })
                    .frame(maxWidth: .infinity)
                    .bold()
                    .foregroundStyle(.white)
                    .padding()
                    .background(.black)
                    .cornerRadius(32)
                    
                    if varient.id != "month" {
                        Text("(\(varient.getDurationDisplay().toString()) at EGP \(varient.monthPrice())/mo. Save \(varient.getSaving(basePrice: plan.getBasePrice()))%)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            Text("Do you have a promo code ?")
                .font(.headline)
                .bold()
                .onTapGesture {
                    showCodeDialog = true
                }
        }
        .padding()
        .offerCodeRedemption(isPresented: $showCodeDialog) { result in
            switch result {
            case .success(let trx):
                print("***********Offer code redemption successful. \(trx)")
                isPresenting = false
            case .failure(let error):
                print("Offer code redemption failed: \(error.localizedDescription)")
            }
        }
        .measureHeight()
        .wrapSheet(sheetHeight: $sheetHeight)
    }
}


#Preview {
    AppPlans()
}

