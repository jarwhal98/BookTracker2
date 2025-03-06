import SwiftUI

@main
struct BookTracker2App: App {
    @StateObject private var viewModel = BookTrackerViewModel()
    @State private var showLaunch = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                TabView {
                    HomeView(viewModel: viewModel)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    BookshelfView(viewModel: viewModel)
                        .tabItem {
                            Label("Bookshelf", systemImage: "books.vertical.fill")
                        }
                    
                    StatsView(viewModel: viewModel)
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                }
                
                if showLaunch {
                    LaunchView(showLaunch: $showLaunch, theme: viewModel.themeManager.currentTheme)
                }
            }
        }
    }
} 