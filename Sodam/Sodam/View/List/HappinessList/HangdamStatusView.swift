//
//  HangdamStatusView.swift
//  Sodam
//
//  Created by EMILY on 21/01/2025.
//

import SwiftUI

struct HangdamStatusView: View {

    let size: CGSize

    @Binding var content: StatusContent

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image
                .hangdamImage(level: content.level)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width / 3)
                .background(Color.imageBackground)
                .clipShape(.circle)

            VStack(alignment: .leading, spacing: 10) {
                Text(content.name)
                    .appFont(size: .title2)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(content.levelDescription)
                    .appFont(size: .body1)

                Text(content.dateDescription)
                    .appFont(size: .body2)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .foregroundStyle(Color(uiColor: .white))
        }
        .padding(20)
        .frame(height: size.height / 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tabBackground)
    }
}

#Preview {
    HangdamStatusView(
        size: CGSize(width: 402, height: 716),
        content: .constant(StatusContent(
            level: 1,
            name: "test",
            levelDescription: "lv.1 test",
            dateDescription: "2000.22.22 ~"
        )
        )
    )
}
