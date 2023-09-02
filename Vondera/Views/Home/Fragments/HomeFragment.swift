import SwiftUI
import NetworkImage

struct HomeFragment: View {
    @StateObject var viewModel = HomeFragmentViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            PullToRefreshOld(coordinateSpaceName: "scrollView") {
                viewModel.initalize()
            }
            
            VStack(alignment: .leading) {
                // MARK : USER HEADER
                header
                       
                Spacer().frame(height: 20)
                
                VStack(alignment: .leading) {
                    
                    // MARK : STEPS VIEW
                    if viewModel.user != nil && !viewModel.user!.store!.finishedSteps() && viewModel.user!.accountType == "Owner" {
                        StepsView(store: viewModel.user!.store!)
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
                    if viewModel.user?.accountType == "Owner" || viewModel.user?.accountType == "Admin" {
                        
                        //TODO : Show the Buttons
                        
                    } else {
                        // TODO : Show one Button
                    }
                    
                    
                    // MARK : Orders count
                    if viewModel.user?.store?.ordersCountObj != nil {
                        StoreOrdersCount(user: viewModel.user!)
                        Spacer().frame(height: 20)
                    }
                    
                    // MARK: TOP SELLING PRODUCTS
                    if viewModel.topSelling.count > 0 {
                        TopSellingProducts(prodsList: viewModel.topSelling)
                        Spacer().frame(height: 20)
                    }
                    
                    if viewModel.topAreas.count > 0 {
                        TopSellingAreas(list: viewModel.topAreas)
                        Spacer().frame(height: 20)
                    }
                    
                }
            }
            .isHidden(viewModel.isLoading)
        }
        .coordinateSpace(name: "scrollView")
        .onAppear {
            Task {
                await viewModel.getUser()
            }
            
        }
        .overlay(alignment: .center) {
            ProgressView()
                .isHidden(!viewModel.isLoading)
        }
    }
    
    var header: some View {
        HStack(alignment: .top) {
            if viewModel.user != nil {
                NetworkImage(url: URL(string: viewModel.user!.userURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                } fallback: {
                    Image("defaultPhoto")
                        .resizable()
                        .centerCropped()
                }
                .background(Color.white)
                .frame(width: 100, height: 120)
                .cornerRadius(20)
            }
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Hello again! 👋")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Text(viewModel.user?.name ?? "")
                    .font(.title2.bold())
                
                HStack {
                    Image(systemName: "bolt")
                    
                    Text( viewModel.user?.getAccountTypeString() ?? "")
                        .font(.title2)
                }
                
                if (viewModel.user?.store?.websiteEnabled ?? false) {
                    HStack {
                        Image(systemName: "globe.americas.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("https://stores.vondera.app/#/mid:\(viewModel.user?.store?.merchantId ?? "")")
                            .font(.body)
                            .foregroundColor(.accentColor)
                            .lineLimit(1)
                    }
                    .onTapGesture {
                        CopyingData().copyToClipboard("https://stores.vondera.app/#/mid:\(viewModel.user?.store?.merchantId ?? "")")
                        
                        viewModel.openLink(url: "https://stores.vondera.app/#/mid:\(viewModel.user?.store?.merchantId ?? "")")
                    }
                }
                
                if viewModel.user?.store != nil {
                    HStack {
                        if !(viewModel.user!.store!.fbLink?.isEmpty ?? true) {
                            Image("facebook")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    viewModel.openLink(url: viewModel.user?.store?.fbLink ?? "")
                                }
                        }
                        
                        if !(viewModel.user!.store!.website?.isEmpty ?? true) {
                            Image("website")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    viewModel.openLink(url: viewModel.user?.store?.website ?? "")
                                }
                        }
                        
                        if !(viewModel.user!.store!.instaLink?.isEmpty ?? true) {
                            Image("instagram")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    viewModel.openLink(url: viewModel.user?.store?.instaLink ?? "")
                                }
                        }
                        
                        if !(viewModel.user!.store!.tiktokLink?.isEmpty ?? true) {
                            Image("tiktok")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    viewModel.openLink(url: viewModel.user?.store?.tiktokLink ?? "")
                                }
                        }
                        
                    }
                }
                
            }
            
            
            Spacer()
        }
    }
}

struct HomeFragment_Previews: PreviewProvider {
    static var previews: some View {
        HomeFragment()
    }
}
