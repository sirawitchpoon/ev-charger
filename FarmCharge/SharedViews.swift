import SwiftUI
import Combine

// MARK: - Screen Router

enum AppScreen: String {
    case onboarding, map, search, detail, booking, payment, active, profile, trips
}

@MainActor
final class Router: ObservableObject {
    @Published var screen: AppScreen = .onboarding
    @Published var stationId: String = "s1"

    func goto(_ s: AppScreen, stationId: String? = nil) {
        if let id = stationId { self.stationId = id }
        withAnimation(.easeInOut(duration: 0.22)) {
            self.screen = s
        }
    }
}

// MARK: - Card

struct CardView<Content: View>: View {
    var padding: CGFloat = 16
    var background: Color = .white
    var radius: CGFloat = 20
    let content: () -> Content

    init(padding: CGFloat = 16, background: Color = .white, radius: CGFloat = 20,
         @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.background = background
        self.radius = radius
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(FC.line, lineWidth: 0.5)
            )
    }
}

// MARK: - Pill

struct Pill: View {
    let text: String
    var icon: AnyView? = nil
    var background: Color = FC.forest.opacity(0.06)
    var foreground: Color = FC.forest

    init(_ text: String,
         icon: AnyView? = nil,
         background: Color = FC.forest.opacity(0.06),
         foreground: Color = FC.forest) {
        self.text = text
        self.icon = icon
        self.background = background
        self.foreground = foreground
    }

    var body: some View {
        HStack(spacing: 6) {
            if let icon { icon }
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(background, in: Capsule())
    }
}

// MARK: - Divider

struct HairlineDivider: View {
    var vertical: CGFloat = 12
    var body: some View {
        Rectangle()
            .fill(FC.line)
            .frame(height: 0.5)
            .padding(.vertical, vertical)
    }
}

// MARK: - Availability dot

struct AvailDot: View {
    let free: Int
    var size: CGFloat = 8
    var body: some View {
        let c = free > 1 ? FC.success : free == 1 ? FC.warn : FC.danger
        return Circle()
            .fill(c)
            .frame(width: size, height: size)
            .overlay(
                Circle().stroke(c.opacity(0.18), lineWidth: 3)
                    .scaleEffect((size + 6) / size)
            )
    }
}

// MARK: - Station row card

struct StationCardView: View {
    let s: Station
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(FC.forest)
                        .frame(width: 52, height: 52)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(FC.lime)
                    if s.solar {
                        Circle()
                            .fill(FC.sun)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(FC.forest)
                            )
                            .overlay(Circle().stroke(FC.paper, lineWidth: 2))
                            .offset(x: 18, y: 18)
                    }
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(s.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(FC.ink)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        Text("\(formatted(s.distance)) กม.")
                        Text("•").foregroundStyle(FC.muted.opacity(0.4))
                        Text("\(s.eta) นาที")
                        Text("•").foregroundStyle(FC.muted.opacity(0.4))
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(FC.sun)
                            Text(String(format: "%.1f", s.rating))
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(FC.muted)

                    HStack(spacing: 6) {
                        Pill("ว่าง \(s.availFree)/\(s.availTotal)",
                             icon: AnyView(AvailDot(free: s.availFree, size: 7)),
                             background: s.availFree > 0 ? FC.success.opacity(0.1) : FC.danger.opacity(0.1),
                             foreground: s.availFree > 0 ? FC.success : FC.danger)
                        Pill("\(s.kw) kW",
                             icon: AnyView(Image(systemName: "bolt.fill").font(.system(size: 10))))
                        Pill("\(baht(s.price))/kWh",
                             background: FC.sun.opacity(0.18),
                             foreground: Color(hex: 0x854D0E))
                    }
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FC.muted2)
                    .padding(.top, 20)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(FC.line, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func formatted(_ d: Double) -> String {
        String(format: d == floor(d) ? "%.0f" : "%.1f", d)
    }
}

// MARK: - Section label

struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .tracking(0.5)
            .foregroundStyle(FC.muted)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}

// MARK: - Top navbar (back + title + trailing slot)

struct TopNav<Trailing: View>: View {
    let title: String
    let onBack: () -> Void
    let trailing: () -> Trailing

    init(title: String, onBack: @escaping () -> Void,
         @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.onBack = onBack
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(FC.ink)
                    .frame(width: 40, height: 40)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().strokeBorder(FC.line, lineWidth: 0.5))
            }
            Spacer()
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(FC.ink)
            Spacer()
            trailing()
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Primary CTA button

struct PrimaryCTA: View {
    let title: String
    var systemIcon: String? = nil
    var trailingIcon: String? = nil
    var background: Color = FC.forest
    var foreground: Color = .white
    var accent: Color = FC.lime
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(accent)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accent)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: FC.forest.opacity(0.25), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Drone SF Symbol substitute (uses custom path)

struct DroneGlyph: View {
    var size: CGFloat = 20
    var color: Color = FC.forest
    var body: some View {
        Canvas { ctx, sz in
            let r = sz.width / 24
            let stroke = 1.75 * r
            let c = color
            let rots: [(CGFloat, CGFloat)] = [(5, 5), (19, 5), (5, 19), (19, 19)]
            for (cx, cy) in rots {
                let circle = Path(ellipseIn: CGRect(x: (cx - 2.5) * r, y: (cy - 2.5) * r,
                                                    width: 5 * r, height: 5 * r))
                ctx.stroke(circle, with: .color(c), lineWidth: stroke)
            }
            let body = Path(roundedRect: CGRect(x: 9 * r, y: 9 * r, width: 6 * r, height: 6 * r),
                            cornerRadius: r)
            ctx.stroke(body, with: .color(c), lineWidth: stroke)
            // arms
            var arm = Path()
            arm.move(to: CGPoint(x: 7*r, y: 7*r)); arm.addLine(to: CGPoint(x: 9*r, y: 9*r))
            arm.move(to: CGPoint(x: 17*r, y: 7*r)); arm.addLine(to: CGPoint(x: 15*r, y: 9*r))
            arm.move(to: CGPoint(x: 7*r, y: 17*r)); arm.addLine(to: CGPoint(x: 9*r, y: 15*r))
            arm.move(to: CGPoint(x: 17*r, y: 17*r)); arm.addLine(to: CGPoint(x: 15*r, y: 15*r))
            ctx.stroke(arm, with: .color(c), lineWidth: stroke)
        }
        .frame(width: size, height: size)
    }
}

struct ConnectorGlyph: View {
    let connector: Connector
    var size: CGFloat = 20
    var body: some View {
        if connector.isDrone {
            DroneGlyph(size: size, color: FC.purple)
        } else {
            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.95, weight: .bold))
                .foregroundStyle(FC.forest)
        }
    }
}
