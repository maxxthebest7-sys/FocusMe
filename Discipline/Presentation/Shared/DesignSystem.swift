import SwiftUI

// MARK: - Palette

enum DS {
    // Authoritative red-orange accent — stern, not playful.
    static let accent           = Color(red: 0.88, green: 0.25, blue: 0.18)
    static let accentDim        = Color(red: 0.88, green: 0.25, blue: 0.18).opacity(0.15)

    static let surface          = Color(white: 0.10)
    static let surfaceRaised    = Color(white: 0.14)
    static let surfaceBorder    = Color(white: 0.18)

    static let textPrimary      = Color.white
    static let textSecondary    = Color(white: 0.55)
    static let textTertiary     = Color(white: 0.35)

    static let warning          = Color.orange
    static let success          = Color(red: 0.18, green: 0.78, blue: 0.42)
    static let danger           = Color.red

    // MARK: - Typography
    enum Font {
        static let displayBold  = SwiftUI.Font.system(.largeTitle,  design: .default, weight: .black)
        static let titleBold    = SwiftUI.Font.system(.title2,      design: .default, weight: .bold)
        static let headline     = SwiftUI.Font.system(.headline,    design: .default, weight: .semibold)
        static let body         = SwiftUI.Font.system(.body,        design: .default, weight: .regular)
        static let caption      = SwiftUI.Font.system(.caption,     design: .default, weight: .medium)
        static let label        = SwiftUI.Font.system(.caption2,    design: .default, weight: .bold)
        static let mono         = SwiftUI.Font.system(.callout,     design: .monospaced, weight: .medium)
    }

    // MARK: - Spacing
    enum Space {
        static let xs: CGFloat =  4
        static let sm: CGFloat =  8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Radius
    enum Radius {
        static let sm: CGFloat =  8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
}

// MARK: - Reusable modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DS.Space.md)
            .background(DS.surface)
            .cornerRadius(DS.Radius.md)
    }
}

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(DS.Font.label)
            .foregroundColor(DS.textSecondary)
            .kerning(1.4)
    }
}

extension View {
    func card()          -> some View { modifier(CardModifier()) }
    func sectionHeader() -> some View { modifier(SectionHeaderModifier()) }
}

// MARK: - Day-of-week picker row

struct DayPickerRow: View {
    @Binding var activeDays: Set<DayOfWeek>

    var body: some View {
        HStack(spacing: 4) {
            ForEach(DayOfWeek.allCases) { day in
                Button {
                    if activeDays.contains(day) { activeDays.remove(day) }
                    else                        { activeDays.insert(day) }
                } label: {
                    Text(day.singleLetter)
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(activeDays.contains(day) ? DS.accent : DS.surfaceRaised)
                        .foregroundColor(activeDays.contains(day) ? .white : DS.textSecondary)
                }
            }
        }
        .cornerRadius(DS.Radius.sm)
        .clipped()
    }
}
