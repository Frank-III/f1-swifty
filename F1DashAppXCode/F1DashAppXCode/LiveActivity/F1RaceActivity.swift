//
//  F1RaceActivity.swift
//  F1-Dash
//
//  Live Activity for F1 race tracking
//

#if !os(macOS)
import ActivityKit
#endif
import SwiftUI
import WidgetKit

// MARK: - Activity Attributes

#if !os(macOS)
struct F1RaceActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic content that updates
        var sessionType: String
        var currentLap: Int
        var totalLaps: Int
        var leaderTLA: String
        var leaderName: String
        var leaderGap: String
        var trackStatus: TrackStatus
        var topThreeDrivers: [CompactDriverInfo]
        var favoriteDriver: CompactDriverInfo?
        var sessionTimeRemaining: String?
        
        struct CompactDriverInfo: Codable, Hashable {
            let position: Int
            let tla: String
            let name: String
            let gap: String
            let teamColor: String
        }
        
        struct TrackStatus: Codable, Hashable {
            let status: String
            let message: String
            let color: String
        }
    }
    
    // Fixed content set when activity starts
    var raceName: String
    var circuitName: String
}
#endif

// MARK: - Live Activity Widget

#if !os(macOS)
struct F1RaceActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: F1RaceActivityAttributes.self) { context in
            // Lock screen/banner UI (appears on lock screen and as banner)
            F1RaceLiveActivityView(context: context)
                .padding()
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI (when long-pressed or when there's more space)
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "flag.checkered.circle.fill")
                            .foregroundColor(.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.raceName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("Lap \(context.state.currentLap)/\(context.state.totalLaps)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(context.state.topThreeDrivers, id: \.tla) { driver in
                            HStack(spacing: 4) {
                                Text("\(driver.position)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 15)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: driver.teamColor) ?? .gray)
                                    .frame(width: 3, height: 12)
                                
                                Text(driver.tla)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text(driver.gap)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Track status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: context.state.trackStatus.color) ?? .gray)
                            .frame(width: 8, height: 8)
                        Text(context.state.trackStatus.status)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Favorite driver info if available
                    if let favorite = context.state.favoriteDriver {
                        HStack {
                            Label {
                                HStack(spacing: 8) {
                                    Text("P\(favorite.position)")
                                        .fontWeight(.bold)
                                    Text(favorite.name)
                                    Spacer()
                                    Text(favorite.gap)
                                        .foregroundColor(.secondary)
                                }
                            } icon: {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            .font(.caption)
                        }
                    }
                }
            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                HStack(spacing: 4) {
                    Image(systemName: "flag.checkered.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("\(context.state.currentLap)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                HStack(spacing: 2) {
                    Text(context.state.leaderTLA)
                        .font(.caption)
                        .fontWeight(.bold)
                    Circle()
                        .fill(Color(hex: context.state.trackStatus.color) ?? .gray)
                        .frame(width: 6, height: 6)
                }
            } minimal: {
                // Minimal view (smallest Dynamic Island state)
                Image(systemName: "flag.checkered.circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}
#endif

// MARK: - Lock Screen View

#if !os(macOS)
struct F1RaceLiveActivityView: View {
    let context: ActivityViewContext<F1RaceActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.raceName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            Text(context.state.sessionType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let timeRemaining = context.state.sessionTimeRemaining {
                                Label(timeRemaining, systemImage: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Track status
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: context.state.trackStatus.color) ?? .gray)
                        .frame(width: 10, height: 10)
                    Text(context.state.trackStatus.status)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            
            // Lap counter
            HStack {
                Text("LAP")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(context.state.currentLap) / \(context.state.totalLaps)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Top 3 drivers
            VStack(spacing: 8) {
                ForEach(context.state.topThreeDrivers, id: \.tla) { driver in
                    HStack(spacing: 12) {
                        // Position
                        Text("\(driver.position)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(width: 25, alignment: .center)
                        
                        // Team color indicator
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: driver.teamColor) ?? .gray)
                            .frame(width: 4, height: 24)
                        
                        // Driver info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(driver.tla)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(driver.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Gap
                        Text(driver.gap)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Favorite driver (if set and not in top 3)
            if let favorite = context.state.favoriteDriver,
               !context.state.topThreeDrivers.contains(where: { $0.tla == favorite.tla }) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("P\(favorite.position)")
                        .fontWeight(.bold)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: favorite.teamColor) ?? .gray)
                        .frame(width: 3, height: 16)
                    
                    Text(favorite.tla)
                        .fontWeight(.bold)
                    
                    Text(favorite.name)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(favorite.gap)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}
#endif

// MARK: - Preview Provider

#if DEBUG && !os(macOS)
struct F1RaceActivity_Previews: PreviewProvider {
    static let attributes = F1RaceActivityAttributes(
        raceName: "Monaco Grand Prix",
        circuitName: "Circuit de Monaco"
    )
    
    static let contentState = F1RaceActivityAttributes.ContentState(
        sessionType: "Race",
        currentLap: 45,
        totalLaps: 78,
        leaderTLA: "VER",
        leaderName: "Max Verstappen",
        leaderGap: "Leader",
        trackStatus: .init(status: "Green", message: "Track Clear", color: "#00FF00"),
        topThreeDrivers: [
            .init(position: 1, tla: "VER", name: "Max Verstappen", gap: "Leader", teamColor: "#1E5BC6"),
            .init(position: 2, tla: "ALO", name: "Fernando Alonso", gap: "+5.234", teamColor: "#2293D1"),
            .init(position: 3, tla: "HAM", name: "Lewis Hamilton", gap: "+8.923", teamColor: "#6CD3BF")
        ],
        favoriteDriver: .init(position: 7, tla: "LEC", name: "Charles Leclerc", gap: "+24.123", teamColor: "#ED1E24"),
        sessionTimeRemaining: "32:45"
    )
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
        
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Lock Screen")
    }
}
#endif
