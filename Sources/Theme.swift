import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

enum Neon {
    static let bg = Color(hex: 0x0A0C14)
    static let card = Color(hex: 0x141829)
    static let green = Color(hex: 0x39FF88)
    static let cyan = Color(hex: 0x22E5FF)
    static let pink = Color(hex: 0xFF3DB8)
    static let yellow = Color(hex: 0xFFE14D)
}

struct NeonCard: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Neon.card, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.7), lineWidth: 1.2))
            .shadow(color: color.opacity(0.25), radius: 8)
    }
}

extension View {
    func neonCard(_ color: Color = Neon.cyan) -> some View {
        modifier(NeonCard(color: color))
    }
}

struct NeonButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color, in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: color.opacity(0.6), radius: configuration.isPressed ? 2 : 10)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
