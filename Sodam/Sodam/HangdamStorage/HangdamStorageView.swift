//
//  HangdamStorageView.swift
//  Sodam
//
//  Created by EMILY on 21/01/2025.
//

import SwiftUI

struct HangdamStorageView: View {
    
    @ObservedObject var viewModel: HangdamStorageViewModel
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    NavigationLink {
                        HappinessListView(hangdam: $viewModel.currentHangdam.wrappedValue)
                    } label: {
                        HangdamStatusView(size: geometry.size, hangdam: $viewModel.currentHangdam)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    
                    HStack(alignment: .bottom) {
                        Text("행담이 보관함")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.mapoGoldenPier(27))
                            .foregroundStyle(Color.textAccent)
                            .padding(.top)
                        
                        Text("다 자란 행담이 : \($viewModel.storedHangdamList.wrappedValue.count)")
                            .font(.mapoGoldenPier(15))
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 12)
                            .background(Capsule().fill(Color.buttonBackground))
                    }
                    if $viewModel.storedHangdamList.wrappedValue.count == 0 {
                        VStack(alignment: .center) {
                            Spacer()
                            Text("행담이에게 행복을 주고 성장시켜보세요!")
                                .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
                                .font(.mapoGoldenPier(24))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .foregroundStyle(Color.gray)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            HangdamGridView(hangdamList: $viewModel.storedHangdamList)
                                .padding(.bottom)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .background(Color.viewBackground)
            .onAppear {
                withAnimation {
                    if let tabBarController = getRootTabBarController() {
                        tabBarController.tabBar.isHidden = false
                    }
                    viewModel.loadHangdamData()
                }
            }
        }
        .tint(.textAccent)
    }
    
    // MARK: - Helper method
    
    private func getRootTabBarController() -> UITabBarController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate,
              let rootViewController = sceneDelegate.window?.rootViewController else {
            return nil
        }
        return rootViewController as? UITabBarController
    }
}

#Preview {
    HangdamStorageView(viewModel: HangdamStorageViewModel(hangdamRepository: HangdamRepository()))
}
