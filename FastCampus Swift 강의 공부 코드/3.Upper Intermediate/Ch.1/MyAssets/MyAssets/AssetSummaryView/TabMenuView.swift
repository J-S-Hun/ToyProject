//
//  TapMenuView.swift
//  MyAssets
//
//  Created by 전성훈 on 2022/09/07.
//

import SwiftUI

struct TabMenuView: View {
    var tabs: [String]
    @Binding var selectedTab : Int
    @Binding var updated: CreditCardAmounts?
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { row in
                Button (
                    action :{
                        selectedTab = row
                        UserDefaults.standard.set(true,forKey: "creditcard_update_checked: \(row)")
                    },
                    label: {
                        VStack(spacing : 0) {
                            HStack {
                                if updated?.id == row {
                                    let checked = UserDefaults.standard.bool(forKey: "creditcard_update_checked: \(row)")
                                    Circle().fill(!checked ? Color.red : Color.clear)
                                        .frame(width: 6, height: 6)
                                        .offset(x: 2, y: -8)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 6, height: 6)
                                        .offset(x: 2, y: -8)
                                }
                                Text(tabs[row])
                                    .font(.system(.headline))
                                    .foregroundColor(selectedTab == row ? .accentColor : .gray)
                                    .offset(x: -4, y: 0)
                            }
                            .frame(height: 50)
                            Rectangle()
                                .fill(
                                    selectedTab == row ? Color.secondary : Color.clear)
                                .frame(height: 3)
                        }
                    }
                )
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(height: 55)
    }
}

struct TabMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TabMenuView(tabs: ["지난달 결제","이번달 결제","다음달 결제"], selectedTab: .constant(2), updated: .constant(.currentMonth(amount: "40,000원")))
    }
}
