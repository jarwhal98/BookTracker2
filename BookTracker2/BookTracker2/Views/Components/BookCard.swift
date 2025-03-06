//
//  BookCard.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct BookCard: View {
    let book: Book
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover Image
            if let url = book.coverUrl {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(theme.secondary.opacity(0.1))
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(theme.secondary)
                            )
                            .frame(maxWidth: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    case .failure(_):
                        Rectangle()
                            .fill(theme.secondary.opacity(0.1))
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(theme.secondary)
                            )
                            .frame(maxWidth: .infinity)
                    @unknown default:
                        Rectangle()
                            .fill(theme.secondary.opacity(0.1))
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(theme.secondary)
                            )
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.top, 4)
                .padding(.horizontal, 4)
            }
            
            // Book Info
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(theme.text)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.caption)
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
        .background(Color(hex: "C5A3A3").opacity(0.2))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
} 