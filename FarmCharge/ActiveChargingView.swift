import SwiftUI
import Combine

struct ActiveChargingView: View {
    @EnvironmentObject var router: Router
    let stationId: String

    @State private var pct: Double = 42
    @State private var elapsed: Double = 18

    private var s: Station { Station.find(stationId) }
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var kWhDone: Double { (pct / 100.0) * 60.0 }
    private var cost: Int { Int(kWhDone * s.price) }
    private var minsLeft: Int { Int((100 - pct) * 0.9) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [FC.forest, Color(hex: 0x0A2A1F)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // glow
            Circle()
                .fill(
                    RadialGradient(colors: [FC.lime.opacity(0.25), .clear],
                                   center: .center, startRadius: 0, endRadius: 200)
                )
                .frame(width: 400, height: 400)
                .offset(y: -200)

            VStack(spacing: 0) {
                // Top bar
                HStack(alignment: .center) {
                    Button { router.goto(.map) } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12), in: Circle())
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("กำลังชาร์จ")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(.white.opacity(0.6))
                        Text(s.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "message.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12), in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                // Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: pct / 100.0)
                        .stroke(FC.lime, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .shadow(color: FC.lime.opacity(0.6), radius: 8)
                        .animation(.linear(duration: 1), value: pct)
                    VStack(spacing: 4) {
                        Text("แบตเตอรี่")
                            .font(.system(size: 12, weight: .medium))
                            .tracking(0.5)
                            .textCase(.uppercase)
                            .foregroundStyle(.white.opacity(0.65))
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(Int(pct))").serif(size: 96).foregroundStyle(.white)
                            Text("%").font(.system(size: 24)).foregroundStyle(FC.lime)
                        }
                        Text("เหลืออีกประมาณ \(minsLeft) นาที")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.top, 4)
                    }
                }
                .frame(width: 260, height: 260)

                // Live stats
                HStack(spacing: 12) {
                    stat("กำลัง", v: "\(s.kw)", u: "kW", color: FC.lime)
                    stat("ชาร์จแล้ว", v: String(format: "%.1f", kWhDone), u: "kWh", color: .white)
                    stat("เวลา", v: "\(Int(elapsed))", u: "นาที", color: .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)

                Spacer()

                // Bottom info + CTA
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ค่าไฟสะสม")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(0.5)
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.6))
                            Text("฿\(cost)").serif(size: 22).foregroundStyle(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("หัวชาร์จ")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(0.5)
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.6))
                            Text("CCS2 · ช่อง A2")
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                    )

                    Button {
                        router.goto(.payment, stationId: s.id)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "power")
                                .font(.system(size: 17, weight: .bold))
                            Text("หยุดและชำระเงิน")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(FC.forest)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            pct = min(100, pct + 0.3)
            elapsed += 1.0 / 60.0
        }
    }

    private func stat(_ label: String, v: String, u: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.6))
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(v).serif(size: 24).foregroundStyle(color)
                Text(u).font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}
