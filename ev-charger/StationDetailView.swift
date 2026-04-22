import SwiftUI

struct StationDetailView: View {
    @EnvironmentObject var router: Router
    let stationId: String

    private var s: Station { Station.find(stationId) }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    content
                }
                .padding(.bottom, 120)
            }
            .background(FC.paper.ignoresSafeArea())

            // Fixed CTA
            ctaBar
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [FC.forest, FC.forest2],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 300)
                .overlay(
                    GridPattern().stroke(FC.lime, lineWidth: 0.5).opacity(0.25)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Pill("พลังงานแสงอาทิตย์",
                         icon: AnyView(Image(systemName: "leaf.fill").font(.system(size: 10))),
                         background: FC.sun.opacity(0.2), foreground: FC.sun)
                    Pill(s.code, background: Color.white.opacity(0.18), foreground: .white)
                }
                Text(s.name)
                    .serif(size: 30)
                    .foregroundStyle(.white)
                    .lineSpacing(-4)
                Text(s.nameEn)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            VStack {
                HStack {
                    Button { router.goto(.map) } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.18), in: Circle())
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "star")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.18), in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                Spacer()
            }
        }
        .frame(height: 300)
        .clipped()
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Stats row
            CardView(padding: 0) {
                HStack(spacing: 0) {
                    stat(label: "ระยะทาง", v: "\(formatted(s.distance))", u: "กม.", border: false)
                    stat(label: "ถึงใน", v: "\(s.eta)", u: "นาที", border: true)
                    stat(label: "กำลังไฟ", v: "\(s.kw)", u: "kW", border: true)
                }
            }

            // Price + hours
            HStack(spacing: 10) {
                CardView(padding: 12) {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(FC.sun2)
                                .frame(width: 36, height: 36)
                            Image(systemName: "creditcard.fill")
                                .foregroundStyle(Color(hex: 0x854D0E))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ค่าชาร์จ").font(.system(size: 11)).foregroundStyle(FC.muted)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text(baht(s.price)).font(.system(size: 15, weight: .semibold))
                                Text("/kWh").font(.system(size: 12)).foregroundStyle(FC.muted)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                CardView(padding: 12) {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(FC.success.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "clock.fill")
                                .foregroundStyle(FC.success)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("เปิดทำการ").font(.system(size: 11)).foregroundStyle(FC.muted)
                            Text(s.open).font(.system(size: 15, weight: .semibold))
                        }
                        Spacer(minLength: 0)
                    }
                }
            }

            // Connectors
            HStack(alignment: .firstTextBaseline) {
                Text("หัวชาร์จ & ท่าลงจอด").font(.system(size: 18, weight: .semibold))
                Spacer()
                Text("อัปเดต 2 นาทีที่แล้ว").font(.system(size: 12)).foregroundStyle(FC.muted)
            }
            .padding(.top, 4)

            CardView(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(s.connectors.enumerated()), id: \.offset) { i, c in
                        if i > 0 {
                            Rectangle().fill(FC.line).frame(height: 0.5)
                                .padding(.horizontal, 16)
                        }
                        ConnectorRow(c: c)
                    }
                }
            }

            // Address
            Text("ที่อยู่").font(.system(size: 18, weight: .semibold))

            CardView {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16))
                        .foregroundStyle(FC.forest)
                        .padding(.top, 2)
                    Text(s.address)
                        .font(.system(size: 14))
                        .foregroundStyle(FC.ink)
                        .lineSpacing(2)
                    Spacer(minLength: 0)
                }
                HairlineDivider()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("เจ้าของ: สหกรณ์การเกษตรชุมชน")
                            .font(.system(size: 13)).foregroundStyle(FC.muted)
                        Text("โทร 081-234-5678")
                            .font(.system(size: 13)).foregroundStyle(FC.forest)
                    }
                    Spacer(minLength: 0)
                }
            }

            // Reviews
            HStack(alignment: .firstTextBaseline) {
                Text("รีวิว").font(.system(size: 18, weight: .semibold))
                Spacer()
                Button("ดูทั้งหมด \(s.reviews) →") {}
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(FC.forest)
            }
            .padding(.top, 4)

            CardView {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.1f", s.rating))
                            .serif(size: 44)
                            .foregroundStyle(FC.ink)
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(FC.sun)
                            }
                        }
                    }
                    VStack(spacing: 4) {
                        ForEach(Array([5, 4, 3].enumerated()), id: \.offset) { i, r in
                            HStack(spacing: 6) {
                                Text("\(r)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(FC.muted)
                                    .frame(width: 10)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(FC.forest.opacity(0.08))
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(FC.forest)
                                            .frame(width: geo.size.width * [0.7, 0.25, 0.05][i])
                                    }
                                }
                                .frame(height: 4)
                            }
                        }
                    }
                    .frame(height: 40)
                }
                HairlineDivider()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("น")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(FC.forest)
                            .frame(width: 32, height: 32)
                            .background(FC.cream2, in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("คุณนพดล").font(.system(size: 13, weight: .semibold))
                            Text("2 วันที่แล้ว").font(.system(size: 11)).foregroundStyle(FC.muted)
                        }
                        Spacer()
                        HStack(spacing: 1) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(FC.sun)
                            }
                        }
                    }
                    Text("\"ชาร์จเร็วดี มีที่จอดให้โดรนด้วย เจ้าของใจดี ให้ดื่มน้ำฟรี แนะนำครับ\"")
                        .font(.system(size: 13))
                        .foregroundStyle(FC.ink)
                        .lineSpacing(3)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func stat(label: String, v: String, u: String, border: Bool) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(FC.muted)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(v).serif(size: 26).foregroundStyle(FC.ink)
                Text(u).font(.system(size: 12)).foregroundStyle(FC.muted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .overlay(alignment: .leading) {
            if border {
                Rectangle().fill(FC.line).frame(width: 0.5)
            }
        }
    }

    private var ctaBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [FC.paper.opacity(0), FC.paper],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 24)
            Button {
                router.goto(.booking, stationId: s.id)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(FC.lime)
                    Text("จองช่องชาร์จ")
                        .font(.system(size: 16, weight: .semibold))
                    Rectangle().fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: 18)
                    Text("เริ่ม \(baht(s.price))/kWh")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(FC.lime)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(FC.forest)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: FC.forest.opacity(0.3), radius: 16, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .background(FC.paper)
        }
    }

    private func formatted(_ d: Double) -> String {
        String(format: d == floor(d) ? "%.0f" : "%.1f", d)
    }
}

private struct ConnectorRow: View {
    let c: Connector
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(c.isDrone ? FC.purple.opacity(0.08) : FC.forest.opacity(0.06))
                    .frame(width: 40, height: 40)
                ConnectorGlyph(connector: c, size: 20)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(c.kind).font(.system(size: 15, weight: .semibold))
                Text("สูงสุด \(c.kw) kW").font(.system(size: 12)).foregroundStyle(FC.muted)
            }
            Spacer()
            Pill("\(c.free)/\(c.total)",
                 icon: AnyView(AvailDot(free: c.free, size: 7)),
                 background: c.free > 0 ? FC.success.opacity(0.1) : FC.danger.opacity(0.1),
                 foreground: c.free > 0 ? FC.success : FC.danger)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let s: CGFloat = 40
        var x: CGFloat = 0
        while x <= rect.width {
            p.move(to: CGPoint(x: x, y: 0))
            p.addLine(to: CGPoint(x: x, y: rect.height))
            x += s
        }
        var y: CGFloat = 0
        while y <= rect.height {
            p.move(to: CGPoint(x: 0, y: y))
            p.addLine(to: CGPoint(x: rect.width, y: y))
            y += s
        }
        return p
    }
}
