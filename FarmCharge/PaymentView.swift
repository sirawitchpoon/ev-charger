import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var router: Router
    let stationId: String

    @State private var method: String = "promptpay"
    @State private var loading = false
    @State private var done = false

    private var s: Station { Station.find(stationId) }
    private let amount = 135

    private struct PayMethod { let id: String; let label: String; let sub: String; let color: Color; let icon: AnyView }

    private var methods: [PayMethod] {
        [
            PayMethod(id: "promptpay", label: "PromptPay", sub: "พร้อมเพย์ · สแกน QR",
                      color: Color(hex: 0x0057B8),
                      icon: AnyView(Image(systemName: "qrcode").font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(hex: 0x0057B8)))),
            PayMethod(id: "truemoney", label: "TrueMoney Wallet", sub: "ยอดคงเหลือ ฿482",
                      color: Color(hex: 0xEB5B5B),
                      icon: AnyView(Text("T").font(.system(size: 17, weight: .bold)).foregroundStyle(Color(hex: 0xEB5B5B)))),
            PayMethod(id: "line", label: "Rabbit LINE Pay", sub: "เชื่อมต่อแล้ว",
                      color: Color(hex: 0x00B900),
                      icon: AnyView(Image(systemName: "message.fill").font(.system(size: 18)).foregroundStyle(Color(hex: 0x00B900)))),
            PayMethod(id: "scb", label: "SCB EASY", sub: "KBank, Bangkok Bank",
                      color: Color(hex: 0x4E2E7F),
                      icon: AnyView(Text("฿").font(.system(size: 18, weight: .bold)).foregroundStyle(Color(hex: 0x4E2E7F)))),
            PayMethod(id: "card", label: "บัตรเครดิต/เดบิต", sub: "**** 4521",
                      color: FC.forest,
                      icon: AnyView(Image(systemName: "creditcard.fill").font(.system(size: 18)).foregroundStyle(FC.forest))),
        ]
    }

    var body: some View {
        Group {
            if done {
                successView
            } else {
                paymentSheet
            }
        }
        .background(FC.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var paymentSheet: some View {
        VStack(spacing: 0) {
            TopNav(title: "ชำระเงิน") {
                router.goto(.booking, stationId: s.id)
            }
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    amountHero
                    SectionLabel(text: "เลือกวิธีชำระ")
                    VStack(spacing: 8) {
                        ForEach(methods, id: \.id) { m in
                            let on = method == m.id
                            Button { method = m.id } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(m.color.opacity(0.08))
                                            .frame(width: 44, height: 44)
                                        m.icon
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(m.label).font(.system(size: 14, weight: .semibold))
                                        Text(m.sub).font(.system(size: 12)).foregroundStyle(FC.muted)
                                    }
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .strokeBorder(on ? FC.forest : FC.line, lineWidth: 2)
                                            .background(Circle().fill(on ? FC.forest : .clear))
                                            .frame(width: 22, height: 22)
                                        if on {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .heavy))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .padding(14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(on ? FC.forest : FC.line, lineWidth: on ? 1.5 : 0.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if method == "promptpay" {
                        CardView {
                            VStack(spacing: 10) {
                                Text("แตะ \"ชำระ\" เพื่อสร้าง QR พร้อมเพย์")
                                    .font(.system(size: 12))
                                    .foregroundStyle(FC.muted)
                                FakeQR()
                                    .frame(width: 120, height: 120)
                                    .padding(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(FC.line, lineWidth: 1)
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            // CTA
            VStack(spacing: 0) {
                Rectangle().fill(FC.line).frame(height: 0.5)
                Button(action: pay) {
                    HStack(spacing: 8) {
                        if loading {
                            ProgressView()
                                .tint(FC.lime)
                            Text("กำลังดำเนินการ...")
                                .font(.system(size: 16, weight: .semibold))
                        } else {
                            Text("ชำระ ฿\(amount).00")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(FC.lime)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(FC.forest)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .opacity(loading ? 0.75 : 1)
                }
                .buttonStyle(.plain)
                .disabled(loading)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(FC.paper)
            }
        }
    }

    private var amountHero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(FC.forest)
            ZStack {
                Circle().fill(FC.lime).opacity(0.08).frame(width: 160, height: 160)
                    .offset(x: 110, y: -60)
                Circle().fill(FC.lime).opacity(0.08).frame(width: 200, height: 200)
                    .offset(x: -120, y: 100)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            VStack(spacing: 6) {
                Text("ยอดชำระ")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.white.opacity(0.7))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("฿").font(.system(size: 24)).foregroundStyle(FC.lime)
                    Text("\(amount)").serif(size: 72).foregroundStyle(FC.lime)
                    Text(".00").font(.system(size: 24)).foregroundStyle(FC.lime)
                }
                Text("30 kWh · \(s.name)")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
            .padding(24)
        }
        .frame(height: 180)
    }

    private var successView: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .fill(FC.lime)
                    .frame(width: 96, height: 96)
                    .shadow(color: FC.lime.opacity(0.4), radius: 24, x: 0, y: 12)
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(FC.forest)
            }
            .padding(.bottom, 24)
            Text("ชำระเงินสำเร็จ")
                .serif(size: 36)
                .foregroundStyle(FC.ink)
            Text("ใบเสร็จถูกส่งไปยังอีเมลของคุณแล้ว")
                .font(.system(size: 14))
                .foregroundStyle(FC.muted)
                .padding(.top, 8)
                .padding(.bottom, 32)

            CardView {
                HStack {
                    Text("สถานี").font(.system(size: 13)).foregroundStyle(FC.muted)
                    Spacer()
                    Text(s.name).font(.system(size: 13, weight: .medium))
                }
                HairlineDivider()
                HStack {
                    Text("รหัสอ้างอิง").font(.system(size: 13)).foregroundStyle(FC.muted)
                    Spacer()
                    Text("FC-2604-8821").font(.system(size: 13, weight: .medium, design: .monospaced))
                }
                HairlineDivider()
                HStack(alignment: .firstTextBaseline) {
                    Text("ยอดรวม").font(.system(size: 13)).foregroundStyle(FC.muted)
                    Spacer()
                    Text("฿\(amount)").serif(size: 28)
                }
            }
            .frame(maxWidth: 320)
            .padding(.horizontal, 16)

            PrimaryCTA(title: "กลับสู่แผนที่") {
                router.goto(.map)
            }
            .frame(maxWidth: 320)
            .padding(.horizontal, 16)
            .padding(.top, 24)

            Spacer()
        }
    }

    private func pay() {
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            loading = false
            withAnimation { done = true }
        }
    }
}

private struct FakeQR: View {
    var body: some View {
        Canvas { ctx, sz in
            let side: CGFloat = 21
            let cell = sz.width / side
            for r in 0..<Int(side) {
                for c in 0..<Int(side) {
                    let fill = (r*7 + c*13 + r*c) % 3 == 0
                        || (r < 3 && c < 3)
                        || (r < 3 && c > 17)
                        || (r > 17 && c < 3)
                    if fill {
                        let rect = CGRect(x: CGFloat(c) * cell, y: CGFloat(r) * cell,
                                          width: cell, height: cell)
                        ctx.fill(Path(rect), with: .color(FC.ink))
                    }
                }
            }
        }
    }
}
