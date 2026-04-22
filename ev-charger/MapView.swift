import SwiftUI

struct MapScreenView: View {
    @EnvironmentObject var router: Router
    @State private var selectedId: String = "s1"
    @State private var vehicleFilter: String = "all"
    @State private var sheetExpanded = false

    private var shown: [Station] {
        Station.all.filter { vehicleFilter == "all" || $0.types.contains(vehicleFilter) }
    }
    private var selected: Station? { Station.all.first(where: { $0.id == selectedId }) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                MapBackground(stations: Station.all,
                              selectedId: selectedId,
                              filter: vehicleFilter) { id in
                    selectedId = id
                }
                .ignoresSafeArea()

                MapChrome(filter: $vehicleFilter,
                          onSearch: { router.goto(.search) },
                          onProfile: { router.goto(.profile) })

                // Bottom sheet
                let sheetHeight = geo.size.height * 0.82
                let collapsedOffset = sheetHeight - 320
                VStack(spacing: 0) {
                    Capsule()
                        .fill(FC.ink.opacity(0.15))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.35)) {
                                sheetExpanded.toggle()
                            }
                        }

                    HStack(alignment: .lastTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("สถานีใกล้คุณ")
                                .serif(size: 28)
                                .foregroundStyle(FC.ink)
                            Text("\(shown.count) จุด ในรัศมี 20 กม.")
                                .font(.system(size: 13))
                                .foregroundStyle(FC.muted)
                        }
                        Spacer()
                        Button("เรียงตาม ↓") {}
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FC.forest)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                    if sheetExpanded {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(shown) { s in
                                    StationCardView(s: s) {
                                        selectedId = s.id
                                        router.goto(.detail, stationId: s.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                        }
                    } else if let s = selected {
                        VStack(spacing: 14) {
                            StationCardView(s: s) {
                                router.goto(.detail, stationId: s.id)
                            }
                            HStack(spacing: 8) {
                                Button {
                                    router.goto(.detail, stationId: s.id)
                                } label: {
                                    Text("รายละเอียด")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(FC.forest)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(FC.forest.opacity(0.06))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                                Button {
                                    router.goto(.booking, stationId: s.id)
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.turn.up.right")
                                            .font(.system(size: 13, weight: .bold))
                                        Text("นำทาง & จอง")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundStyle(FC.lime)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(FC.forest)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                                .layoutPriority(1.4)
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: FC.forest.opacity(0.06), radius: 12, x: 0, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .transition(.opacity)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: sheetHeight)
                .background(
                    FC.paper
                        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                        .shadow(color: FC.forest.opacity(0.12), radius: 10, x: 0, y: -4)
                )
                .offset(y: sheetExpanded ? max(geo.safeAreaInsets.top + 40, 80) : collapsedOffset)
                .animation(.spring(duration: 0.35), value: sheetExpanded)
            }
        }
    }
}

// MARK: - Map chrome

private struct MapChrome: View {
    @Binding var filter: String
    var onSearch: () -> Void
    var onProfile: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // Search bar
            Button(action: onSearch) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(FC.muted)
                    Text("ค้นหาสถานี, ที่อยู่, โดรน")
                        .font(.system(size: 15))
                        .foregroundStyle(FC.muted)
                    Spacer()
                    Button(action: onProfile) {
                        Text("ส")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(FC.forest, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: FC.forest.opacity(0.1), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("all", label: "ทั้งหมด", systemIcon: "bolt.fill")
                    chip("car", label: "รถไฟฟ้า", systemIcon: "car.fill")
                    chip("drone", label: "โดรน", systemIcon: nil, drone: true)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func chip(_ id: String, label: String, systemIcon: String?, drone: Bool = false) -> some View {
        let active = filter == id
        return Button { filter = id } label: {
            HStack(spacing: 6) {
                if drone {
                    DroneGlyph(size: 15, color: active ? .white : FC.forest)
                } else if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(active ? .white : FC.forest)
            .padding(.leading, 10)
            .padding(.trailing, 12)
            .padding(.vertical, 8)
            .background(active ? FC.forest : Color.white.opacity(0.92))
            .clipShape(Capsule())
            .shadow(color: FC.forest.opacity(0.12), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rounded corner helper

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let p = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                             cornerRadii: CGSize(width: radius, height: radius))
        return Path(p.cgPath)
    }
}

// MARK: - Map background with pins

struct MapBackground: View {
    let stations: [Station]
    let selectedId: String
    let filter: String
    let onSelect: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(hex: 0xE9EEDD), Color(hex: 0xDDE7CD)],
                               startPoint: .top, endPoint: .bottom)

                MapCanvas()

                // Pins
                ForEach(stations.filter { filter == "all" || $0.types.contains(filter) }) { s in
                    Button { onSelect(s.id) } label: {
                        let sel = s.id == selectedId
                        ZStack(alignment: .top) {
                            MapPin(selected: sel)
                                .frame(width: 44, height: 54)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(sel ? FC.forest : FC.lime)
                                .padding(.top, 9)
                            if s.availFree == 0 {
                                Circle()
                                    .fill(FC.danger)
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .offset(x: 16, y: -2)
                            }
                        }
                        .scaleEffect(sel ? 1.1 : 1.0)
                        .shadow(color: FC.forest.opacity(sel ? 0.3 : 0.2),
                                radius: sel ? 10 : 4, x: 0, y: sel ? 6 : 2)
                        .animation(.easeInOut(duration: 0.2), value: sel)
                    }
                    .buttonStyle(.plain)
                    .position(x: s.x * geo.size.width, y: s.y * geo.size.height - 20)
                }

                // User location
                ZStack {
                    Circle()
                        .fill(FC.blue.opacity(0.18))
                        .frame(width: 54, height: 54)
                    Circle()
                        .fill(FC.blue)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: FC.blue.opacity(0.4), radius: 6, x: 0, y: 2)
                }
                .position(x: 0.48 * geo.size.width, y: 0.78 * geo.size.height)
            }
        }
    }
}

private struct MapPin: View {
    let selected: Bool
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var path = Path()
            path.move(to: CGPoint(x: w/2, y: h - 2))
            path.addQuadCurve(to: CGPoint(x: 2, y: h * 0.40),
                              control: CGPoint(x: 2, y: h * 0.80))
            path.addArc(center: CGPoint(x: w/2, y: h * 0.38),
                        radius: w * 0.45, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            path.addQuadCurve(to: CGPoint(x: w/2, y: h - 2),
                              control: CGPoint(x: w - 2, y: h * 0.80))
            ctx.fill(path, with: .color(selected ? FC.forest : .white))
            ctx.stroke(path, with: .color(selected ? FC.lime : FC.forest),
                       lineWidth: selected ? 2 : 1.5)
            let cx = w/2, cy = h * 0.38, cr = w * 0.30
            let circle = Path(ellipseIn: CGRect(x: cx - cr, y: cy - cr,
                                                width: cr * 2, height: cr * 2))
            ctx.fill(circle, with: .color(selected ? FC.lime : FC.forest))
        }
    }
}

// Stylized map with fields, roads, river, villages
private struct MapCanvas: View {
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let sx = w / 400.0, sy = h / 800.0

            // Fields
            drawField(ctx: ctx, rect: CGRect(x: 0*sx, y: 0*sy, width: 220*sx, height: 360*sy),
                      base: Color(hex: 0xD6E4B8), line: Color(hex: 0xC6D7A5), size: 24*sx, angle: 20)
            drawField(ctx: ctx, rect: CGRect(x: 220*sx, y: 40*sy, width: 200*sx, height: 280*sy),
                      base: Color(hex: 0xE2EBC9), line: Color(hex: 0xD2DDB7), size: 18*sx, angle: -30)
            drawField(ctx: ctx, rect: CGRect(x: 20*sx, y: 380*sy, width: 180*sx, height: 260*sy),
                      base: Color(hex: 0xCFDFB0), line: Color(hex: 0xB8CC93), size: 12*sx, angle: 0)
            drawField(ctx: ctx, rect: CGRect(x: 210*sx, y: 340*sy, width: 210*sx, height: 340*sy),
                      base: Color(hex: 0xD6E4B8), line: Color(hex: 0xC6D7A5), size: 24*sx, angle: 20)

            // River
            var river = Path()
            river.move(to: CGPoint(x: -20*sx, y: 520*sy))
            river.addQuadCurve(to: CGPoint(x: 200*sx, y: 540*sy),
                               control: CGPoint(x: 100*sx, y: 480*sy))
            river.addQuadCurve(to: CGPoint(x: 420*sx, y: 500*sy),
                               control: CGPoint(x: 300*sx, y: 600*sy))
            ctx.stroke(river, with: .color(Color(hex: 0xA8CDE0, alpha: 0.55)),
                       style: StrokeStyle(lineWidth: 16*sx, lineCap: .round))

            // Roads (cream)
            var road1 = Path()
            road1.move(to: CGPoint(x: -20*sx, y: 200*sy))
            road1.addQuadCurve(to: CGPoint(x: 240*sx, y: 280*sy),
                               control: CGPoint(x: 160*sx, y: 220*sy))
            road1.addQuadCurve(to: CGPoint(x: 430*sx, y: 360*sy),
                               control: CGPoint(x: 350*sx, y: 350*sy))
            ctx.stroke(road1, with: .color(FC.paper),
                       style: StrokeStyle(lineWidth: 18*sx, lineCap: .round))
            ctx.stroke(road1, with: .color(.white),
                       style: StrokeStyle(lineWidth: 1.5, dash: [6, 8]))

            var road2 = Path()
            road2.move(to: CGPoint(x: 130*sx, y: -20*sy))
            road2.addQuadCurve(to: CGPoint(x: 100*sx, y: 400*sy),
                               control: CGPoint(x: 150*sx, y: 200*sy))
            road2.addQuadCurve(to: CGPoint(x: 180*sx, y: 820*sy),
                               control: CGPoint(x: 70*sx, y: 600*sy))
            ctx.stroke(road2, with: .color(FC.paper),
                       style: StrokeStyle(lineWidth: 12*sx, lineCap: .round))

            // Villages (small squares)
            let villages: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (60, 620, 14, 12), (78, 625, 10, 9), (45, 635, 11, 10),
                (300, 120, 12, 10), (316, 125, 10, 9),
            ]
            for v in villages {
                let r = CGRect(x: v.0*sx, y: v.1*sy, width: v.2*sx, height: v.3*sy)
                ctx.fill(Path(r), with: .color(Color(hex: 0xE8DFC8).opacity(0.85)))
                ctx.stroke(Path(r), with: .color(Color(hex: 0xC9BFA4)), lineWidth: 0.5)
            }

            // Trees
            let trees: [(CGFloat, CGFloat)] = [(40,120),(70,140),(360,180),(380,620),(350,710),(90,300),(280,580)]
            for t in trees {
                let r = CGRect(x: (t.0-6)*sx, y: (t.1-6)*sy, width: 12*sx, height: 12*sy)
                ctx.fill(Path(ellipseIn: r), with: .color(Color(hex: 0x8FAE6E, alpha: 0.45)))
            }
        }
    }

    private func drawField(ctx: GraphicsContext, rect: CGRect,
                           base: Color, line: Color, size: CGFloat, angle: Double) {
        ctx.fill(Path(rect), with: .color(base.opacity(0.85)))
        ctx.drawLayer { layer in
            layer.clip(to: Path(rect))
            layer.translateBy(x: rect.midX, y: rect.midY)
            layer.rotate(by: .degrees(angle))
            layer.translateBy(x: -rect.midX, y: -rect.midY)
            var y = rect.minY
            while y < rect.maxY + size {
                var p = Path()
                p.move(to: CGPoint(x: rect.minX - size, y: y))
                p.addLine(to: CGPoint(x: rect.maxX + size, y: y))
                layer.stroke(p, with: .color(line), lineWidth: 0.8)
                y += size / 2
            }
        }
    }
}
