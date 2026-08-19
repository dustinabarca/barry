import SwiftUI

extension Color {
    static let barryForest = Color(red: 23/255, green: 63/255, blue: 53/255)
    static let barryBurgundy = Color(red: 139/255, green: 47/255, blue: 56/255)
    static let barryCharcoal = Color(red: 32/255, green: 38/255, blue: 41/255)
    static let barrySlate = Color(red: 98/255, green: 107/255, blue: 112/255)
    static let barrySage = Color(red: 199/255, green: 207/255, blue: 204/255)
    static let barryBG = Color(red: 251/255, green: 249/255, blue: 244/255)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .tracking(1.0)
            .textCase(.uppercase)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.barryBurgundy)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .semibold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundColor(.barryCharcoal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .overlay(Rectangle().stroke(Color.barrySage, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct PillButtonStyle: ButtonStyle {
    var active: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .semibold))
            .textCase(.uppercase)
            .foregroundColor(active ? .white : .barryCharcoal)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(active ? Color.barryForest : Color.white)
            .overlay(Rectangle().stroke(active ? Color.barryForest : Color.barrySage, lineWidth: 1))
    }
}

struct Masthead: View {
    let tag: String
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("BARRY CO.")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.4)
                    .foregroundColor(.barryForest)
                Spacer()
                Text(tag.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.0)
                    .foregroundColor(.barrySlate)
            }
            Rectangle().fill(Color.barrySage).frame(height: 1)
        }
    }
}

struct CardBackground: View {
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .overlay(Rectangle().stroke(Color.barrySage, lineWidth: 1))
    }
}
