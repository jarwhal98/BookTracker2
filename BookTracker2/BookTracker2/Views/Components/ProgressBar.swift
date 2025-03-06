//
//  ProgressBar.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                
                Rectangle()
                    .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width))
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 8)
        .cornerRadius(4)
    }
} 