import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

enum FC {
    static let ink       = Color(hex: 0x0A1F17)
    static let forest    = Color(hex: 0x0F3D2E)
    static let forest2   = Color(hex: 0x173E30)
    static let lime      = Color(hex: 0x4ADE80)
    static let lime2     = Color(hex: 0x86EFAC)
    static let sun       = Color(hex: 0xFACC15)
    static let sun2      = Color(hex: 0xFDE68A)
    static let cream     = Color(hex: 0xF5F1E8)
    static let cream2    = Color(hex: 0xEDE7D6)
    static let paper     = Color(hex: 0xFAF7EE)
    static let canvas    = Color(hex: 0xE7E3D6)

    static let line      = Color(hex: 0x0F3D2E, alpha: 0.12)
    static let muted     = Color(hex: 0x0A1F17, alpha: 0.55)
    static let muted2    = Color(hex: 0x0A1F17, alpha: 0.40)

    static let success   = Color(hex: 0x16A34A)
    static let warn      = Color(hex: 0xFACC15)
    static let danger    = Color(hex: 0xDC2626)
    static let purple    = Color(hex: 0x7C3AED)
    static let blue      = Color(hex: 0x2563EB)

    static let serifName = "Times New Roman"
}

struct SerifText: View {
    let text: String
    let size: CGFloat
    var color: Color = FC.ink
    var body: some View {
        Text(text)
            .font(.custom("Instrument Serif", size: size).weight(.regular))
            .foregroundStyle(color)
            .kerning(-size * 0.01)
    }
}

extension Text {
    func serif(size: CGFloat) -> some View {
        self.font(.custom("Instrument Serif", size: size))
            .kerning(-size * 0.01)
    }
}

func baht(_ n: Double) -> String {
    let frac = n.truncatingRemainder(dividingBy: 1) != 0
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.minimumFractionDigits = frac ? 2 : 0
    f.maximumFractionDigits = 2
    let s = f.string(from: NSNumber(value: n)) ?? "\(n)"
    return "฿\(s)"
}
