import SwiftUI
import NetworkImage
import LineChartView

struct StoreToolbar : View {
    var myUser:UserData?
    
    var body: some View {
        HStack {
            if let myUser = myUser {
                if myUser.canAccessAdmin {
                    NavigationLink(destination: Dashboard(store: myUser.store!)) {
                        IconAndName(myUser: myUser)
                    }
                } else {
                    IconAndName(myUser: myUser)
                }
                
                Spacer()
                
                NavigationLink(destination: AddToCart()) {
                    Image(systemName: "cart")
                }
            }
        }
        .buttonStyle(.plain)
        .font(.title2)
        .bold()
    }
}
struct HomeFragment: View {
    @ObservedObject var myUser = UserInformation.shared
    @StateObject var viewModel = HomeFragmentViewModel()
    
    var body: some View {
        VStack {
            if let myUser = myUser.user {
                StoreToolbar(myUser: myUser)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        
                        // MARK : USER HEADER
                        UserHomeHeader(myUser: myUser)
                        
                        Spacer().frame(height: 20)
                        
                        VStack(alignment: .leading) {
                            // MARK : STEPS VIEW
                            if !(myUser.store!.finishedSteps()){
                                StoreStepsView(myUser: myUser)
                            }
                            
                            // MARK : Orders count
                            if myUser.store?.ordersCountObj != nil {
                                StoreOrdersCount(user: myUser)
                                Spacer().frame(height: 20)
                            }
                            
                            // MARK : Statics
                            if !viewModel.storeStatics.isEmpty && myUser.canAccessAdmin {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Statistics")
                                            .font(.title2)
                                            .bold()
                                        
                                        Spacer()
                                        
                                        Picker("Date Range", selection: $viewModel.staticsDays) {
                                            Text("Today")
                                                .tag(1)
                                            
                                            Text("This Week")
                                                .tag(7)
                                            
                                            Text("This Month")
                                                .tag(30)
                                            
                                            Text("This Quarter")
                                                .tag(90)
                                            
                                            Text("This year")
                                                .tag(365)
                                        }
                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack {
                                                    Text("Net Profit")
                                                        .font(.title3)
                                                        .bold()
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(viewModel.storeStatics.getTotalIncome()) LE")
                                                        .bold()
                                                }
                                                
                                                LineChartView(
                                                    lineChartParameters:
                                                        LineChartParameters(
                                                            data: viewModel.storeStatics.getLinearChartIncome(),
                                                            dataPrecisionLength: 0,
                                                            dataSuffix: "LE",
                                                            lineColor: Color.accentColor
                                                        )
                                                )
                                            }
                                            .background(Color.background)
                                            .padding()
                                            .frame(width: 320, height: 240)
                                            .cornerRadius(20)
                                            
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack {
                                                    Text("Orders")
                                                        .font(.title3)
                                                        .bold()
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(viewModel.storeStatics.getTotalOrders()) Orders")
                                                        .bold()
                                                }
                                                
                                                LineChartView(
                                                    lineChartParameters:
                                                        LineChartParameters(
                                                            data: viewModel.storeStatics.getLinearChartOrder(),
                                                            dataPrecisionLength: 0,
                                                            dataSuffix: "Orders",
                                                            lineColor: Color.blue,
                                                            displayMode: .default
                                                        )
                                                )
                                            }
                                            .background(Color.background)
                                            .padding()
                                            .frame(width: 320, height: 240)
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                            
                            // MARK : Online Users
                            if viewModel.onlineUser.count > 0 {
                                Text("Online Employees 🧑‍💼")
                                    .font(.title2.bold())
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(alignment: .center, spacing: 12) {
                                        ForEach(viewModel.onlineUser) { user in
                                            UserCircle(user: user)
                                        }
                                    }
                                }
                                Spacer().frame(height: 20)
                            }
                            
                            
                            // MARK : Tip Of the day
                            if viewModel.tip != nil {
                                TipCard(tip: viewModel.tip!)
                                Spacer().frame(height: 20)
                            }
                            
                            // MARK : Buttons
                            if myUser.canAccessAdmin {
#warning("Show the Buttons")
                            } else {
#warning("Show the Buttons")
                            }
                            
                            // MARK: TOP SELLING PRODUCTS
                            if viewModel.topSelling.count > 0 {
                                TopSellingProducts(prodsList: $viewModel.topSelling)
                                Spacer().frame(height: 20)
                            }
                            
                            if viewModel.topAreas.count > 0 {
                                TopSellingAreas(list: viewModel.topAreas)
                                Spacer().frame(height: 20)
                            }
                            
                        }
                    }
                }
                .isHidden(viewModel.isLoading)
            }
        }
        .padding()
        .overlay(alignment: .center) {
            ProgressView().isHidden(!viewModel.isLoading)
        }
        .refreshable {
            await viewModel.refreshData()
            
            DispatchQueue.main.async {
                self.myUser.user = viewModel.myUser
            }
        }
        .onAppear {
            //updateUser()
        }
    }
    
    func updateUser() {
        /*if let user = UserInformation.shared.getUser() {
         self.myUser = user
         viewModel.myUser = user
         print("User home updated")
         }*/
    }
}

#Preview {
    HomeFragment()
}
