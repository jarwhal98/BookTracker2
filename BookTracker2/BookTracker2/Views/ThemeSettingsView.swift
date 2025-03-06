//
//  ThemeSettingsView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct ThemeSettingsView: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button(action: {
                        viewModel.themeManager.currentTheme = theme
                    }) {
                        HStack {
                            Circle()
                                .fill(theme.primary)
                                .frame(width: 24, height: 24)
                            
                            Text(theme.rawValue.capitalized)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if theme == viewModel.themeManager.currentTheme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
} 