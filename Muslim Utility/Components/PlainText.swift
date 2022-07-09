//
//  PlainText.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 5/10/22.
//

import SwiftUI

struct PlainText: View {
    var text: String
    var bold: Bool
    var size: CGFloat
    var color: String?
    
    var body: some View {
        if let color = color {
            Text("\(text)")
                .font(Font.custom(self.bold ? "Ubuntu-Bold" : "Ubuntu-Light", size: size))
                .foregroundColor(Color(color))
        } else {
            Text("\(text)")
                .font(Font.custom(self.bold ? "Ubuntu-Bold" : "Ubuntu-Light", size: size))
        }
    }
}
