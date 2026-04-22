import SwiftUI

struct BookingView: View {
    @EnvironmentObject var router: Router
    let stationId: String

    @State private var connector: String = ""
    @State private var duration: Int = 45
    @State private var slot: String = "14:30"
    @State private var vehicle: String = "car1"

    private var s: Station { Station.find(stationId) }
    private let slots = ["13:30","14:00","14:30","15:00","15:30","16:00","16:30","17:00"]
    private let unavailable = ["15:30", "16:30"]
    private var est: Int { Int((Double(duration)/60.0) * Double(s.kw) * s.price) }

    var body: some View {
        VStack(spacing: 0) {
            TopNav(title: "จองช่องชาร์จ") {
                router.goto(.detail, stationId: s.id)
            }
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    stationMini
                    vehicleSection
                    connectorSection
                    timeSection
                    durationSection
                    costSummary
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }

            // CTA
            VStack(spacing: 0) {
                Rectangle().fill(FC.line).frame(height: 0.5)
                Button {
                    router.goto(.payment, stationId: s.id)
                } label: {
                    HStack(spacing: 8) {
                        Text("ยืนยันและชำระเงิน")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(FC.lime)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(FC.forest)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(FC.paper)
            }
        }
        .background(FC.paper.ignoresSafeArea())
        .onAppear {
            if connector.isEmpty { connector = s.connectors.first?.kind ?? "" }
        }
        .navigationBarHidden(true)
    }

    private var stationMini: some View {
        CardView(padding: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(FC.forest)
                        .frame(width: 44, height: 44)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(FC.lime)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Text("\(formatted(s.distance)) กม. • ถึงใน \(s.eta) นาที")
                        .font(.system(size: 12))
                        .foregroundStyle(FC.muted)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var vehicleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "เลือกรถ/โดรน")
            HStack(spacing: 10) {
                vehicleButton(id: "car1", icon: AnyView(Image(systemName: "car.fill").font(.system(size: 20))),
                              label: "Isuzu D-Max EV", sub: "กข 1234 ร้อยเอ็ด")
                vehicleButton(id: "drone1", icon: AnyView(DroneGlyph(size: 20)),
                              label: "DJI Agras T40", sub: "SN-88127")
            }
        }
    }

    private func vehicleButton(id: String, icon: AnyView, label: String, sub: String) -> some View {
        let on = vehicle == id
        return Button { vehicle = id } label: {
            VStack(alignment: .leading, spacing: 8) {
                icon.foregroundStyle(on ? FC.lime : FC.forest)
                Text(label).font(.system(size: 13, weight: .semibold))
                Text(sub).font(.system(size: 11)).opacity(0.65)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .foregroundStyle(on ? .white : FC.ink)
            .background(on ? FC.forest : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(on ? FC.forest : FC.line, lineWidth: on ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var connectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "หัวชาร์จ")
            CardView(padding: 6) {
                VStack(spacing: 0) {
                    ForEach(s.connectors, id: \.kind) { c in
                        let on = connector == c.kind
                        let disabled = c.free == 0
                        Button {
                            if !disabled { connector = c.kind }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(on ? FC.forest : FC.line, lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                    if on {
                                        Circle().fill(FC.forest).frame(width: 10, height: 10)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.kind).font(.system(size: 14, weight: .semibold))
                                    Text("\(c.kw) kW • ว่าง \(c.free)/\(c.total)")
                                        .font(.system(size: 12)).foregroundStyle(FC.muted)
                                }
                                Spacer()
                                AvailDot(free: c.free, size: 8)
                            }
                            .padding(12)
                            .background(on ? FC.forest.opacity(0.06) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .opacity(disabled ? 0.4 : 1)
                        }
                        .buttonStyle(.plain)
                        .disabled(disabled)
                    }
                }
            }
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "เวลาเริ่มชาร์จ · วันนี้ 20 เม.ย.")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(slots, id: \.self) { t in
                    let on = slot == t
                    let off = unavailable.contains(t)
                    Button {
                        if !off { slot = t }
                    } label: {
                        Text(t)
                            .font(.system(size: 14, weight: .semibold))
                            .strikethrough(off)
                            .foregroundStyle(on ? .white : (off ? FC.muted2 : FC.ink))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(on ? FC.forest : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(on ? .clear : FC.line, lineWidth: 0.5)
                            )
                            .opacity(off ? 0.5 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(off)
                }
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "ระยะเวลา")
            CardView {
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(duration)").serif(size: 40).foregroundStyle(FC.ink)
                        Text("นาที").font(.system(size: 16)).foregroundStyle(FC.muted)
                    }
                    Spacer()
                    Pill("~\(Int(Double(duration)/60.0 * Double(s.kw))) kWh",
                         background: FC.sun2, foreground: Color(hex: 0x854D0E))
                }
                .padding(.bottom, 12)

                HStack(spacing: 8) {
                    ForEach([15, 30, 45, 60, 90, 120], id: \.self) { d in
                        Button { duration = d } label: {
                            Text("\(d)น")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(duration == d ? .white : FC.forest)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(duration == d ? FC.forest : FC.forest.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var costSummary: some View {
        CardView(background: FC.forest) {
            HStack {
                Text("ค่าไฟฟ้าโดยประมาณ")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.7))
                Spacer()
                Text("\(Int(Double(duration)/60.0 * Double(s.kw))) kWh × \(baht(s.price))")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            .padding(.bottom, 6)
            HStack(alignment: .firstTextBaseline) {
                Text("รวม")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.85))
                Spacer()
                Text("฿\(est)")
                    .serif(size: 36)
                    .foregroundStyle(FC.lime)
            }
        }
    }

    private func formatted(_ d: Double) -> String {
        String(format: d == floor(d) ? "%.0f" : "%.1f", d)
    }
}
