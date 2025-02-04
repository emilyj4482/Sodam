//
//  HappinessDetailView.swift
//  Sodam
//
//  Created by 박진홍 on 1/24/25.
//

import SwiftUI

struct HappinessDetailView: View {
    
    let viewModel: HappinessDetailViewModel
    @State private var isAlertPresented: Bool = false
    let isCanDelete: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack {
                    if let imagePath = viewModel.happiness.imagePaths.first {
                        Image(uiImage: self.viewModel.getImage(from: imagePath))
                            .resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: 15))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.cellBackground))
                            .padding(.bottom)
                    }
                    HStack(alignment: .top) {
                        Text(viewModel.happiness.content)
                            .font(.maruburiot(type: .regular, size: 16))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.viewBackground)
            .padding()
        }
        .background(Color.viewBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("기억들")
                            .font(.maruburiot(type: .bold, size: 16))
                            .foregroundStyle(Color.textAccent)
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(viewModel.happiness.date.toFormattedString)
                    .font(.maruburiot(type: .bold, size: 20))
                    .foregroundStyle(Color.textAccent)
            }
            if isCanDelete {
                ToolbarItem(placement: .topBarTrailing) {
                    Button( action: {
                        isAlertPresented = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        
        .alert("정말 삭제하시겠습니까?", isPresented: $isAlertPresented) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                viewModel.deleteHappiness()
                dismiss()
            }
        } message: {
            Text("삭제한 행복은 되돌릴 수 없습니다.")
        }
    }
    
}

#Preview {
}

