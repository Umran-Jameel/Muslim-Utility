//
//  IndividualTime.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/8/22.
//

import SwiftUI

struct IndividualTime: View {
    var name: String
    var time: String
    var arabic: String
    var currentPrayer: Int
    
    var body: some View {
        let cur = checkCurrentPrayer(currentPrayer: currentPrayer, expectedPrayer: name)
        
        return VStack {
            HStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(cur ? "current_prayer" : "prayer_time"))
                    .frame(width: 100, height: 30)
                    .overlay(alignment: .leading) { PlainText(text: name, bold: cur, size: 20, color: "default_text").padding(10) }
                 
                Spacer()
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(cur ? "current_prayer" : "prayer_time"))
                    .frame(width: 100, height: 30)
                    .overlay(PlainText(text: time, bold: cur, size: 20, color: "default_text"))
                Spacer()
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(cur ? "current_prayer" : "prayer_time"))
                    .frame(width: 100, height: 30)
                    .overlay(alignment: .trailing) { PlainText(text: arabic, bold: cur, size: 20, color: "default_text").padding(10) }
            }
        }
    }
}
