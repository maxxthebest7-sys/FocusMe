import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Today",    systemImage: "house.fill")          }

            RulesListView()
                .tabItem { Label("Rules",    systemImage: "shield.fill")          }

            ScheduleView()
                .tabItem { Label("Schedule", systemImage: "calendar")             }

            TemplatesView()
                .tabItem { Label("Messages", systemImage: "text.bubble.fill")     }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill")       }
        }
        .tint(DS.accent)
    }
}
