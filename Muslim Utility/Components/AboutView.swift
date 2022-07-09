//
//  AboutView.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 7/3/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color("main").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 10) {
                Text("Muslim Utility Version 1.0")
                    .font(Font.custom("Ubuntu-Light", size: 17))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("date"))
                Text("Created by Umran Jameel, student at the University of Central Florida")
                    .font(Font.custom("Ubuntu-Light", size: 17))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("date"))
                VStack(alignment: .leading) {
                    Text("Privacy Statement:")
                        .font(Font.custom("Ubuntu-Light", size: 17))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("date"))
                    Text("This app uses your location to show you the prayer times for your area. Your location is never stored anywhere other than on your device, never shared, and never used in any way other than to show you the prayer times for your location.")
                        .font(Font.custom("Ubuntu-Light", size: 17))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("date"))
                }
                Spacer()
            }
            .padding()
        }
    }
}
