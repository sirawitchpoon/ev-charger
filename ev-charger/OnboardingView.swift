import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var router: Router
    @State private var step = 0

    private struct Slide { let title: String; let subtitle: String; let art: AnyView }

    private var slides: [Slide] {
        [
            Slide(title: "หาจุดชาร์จ\nใกล้ไร่ของคุณ",
                  subtitle: "สถานีชาร์จรถไฟฟ้าและโดรนเกษตร ครอบคลุมทั่วไทย ทั้งในและนอกเมือง",
                  art: AnyView(OnboardArt1())),
            Slide(title: "จองล่วงหน้า\nไม่ต้องรอคิว",
                  subtitle: "เลือกเวลาและหัวชาร์จที่ต้องการได้เลย ระบบจะจองช่องไว้ให้คุณ",
                  art: AnyView(OnboardArt2())),
            Slide(title: "จ่ายง่าย\nด้วยพร้อมเพย์",
                  subtitle: "รองรับพร้อมเพย์, TrueMoney, LINE Pay และบัตรเครดิต ใบเสร็จส่งอัตโนมัติ",
                  art: AnyView(OnboardArt3())),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(FC.forest)
                            .frame(width: 32, height: 32)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(FC.lime)
                    }
                    Text("FarmCharge")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FC.ink)
                }
                Spacer()
                Button("ข้าม") { router.goto(.map) }
                    .font(.system(size: 14))
                    .foregroundStyle(FC.muted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            // Art + title
            VStack(spacing: 24) {
                slides[step].art
                    .frame(width: 240, height: 180)
                    .transition(.opacity)
                Text(slides[step].title)
                    .font(.custom("Instrument Serif", size: 40))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(FC.ink)
                    .lineSpacing(-6)
                Text(slides[step].subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(FC.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 320)
                    .padding(.horizontal, 16)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Pager dots
            HStack(spacing: 6) {
                ForEach(0..<slides.count, id: \.self) { i in
                    Capsule()
                        .fill(i == step ? FC.forest : FC.forest.opacity(0.2))
                        .frame(width: i == step ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.22), value: step)
                }
            }
            .padding(.bottom, 20)

            // CTA
            VStack(spacing: 10) {
                PrimaryCTA(title: step < slides.count - 1 ? "ถัดไป" : "เริ่มใช้งาน",
                           trailingIcon: "chevron.right") {
                    if step < slides.count - 1 {
                        withAnimation { step += 1 }
                    } else {
                        router.goto(.map)
                    }
                }
                Button {
                    router.goto(.map)
                } label: {
                    HStack(spacing: 4) {
                        Text("มีบัญชีอยู่แล้ว?")
                            .foregroundStyle(FC.muted)
                        Text("เข้าสู่ระบบ")
                            .foregroundStyle(FC.forest)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 13))
                    .padding(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FC.paper.ignoresSafeArea())
    }
}

// Art pieces — simplified SwiftUI shapes

private struct OnboardArt1: View {
    var body: some View {
        ZStack {
            Rectangle().fill(FC.lime.opacity(0.2))
                .frame(width: 240, height: 40)
                .offset(y: 70)
            // pin
            Circle().fill(FC.lime)
                .frame(width: 56, height: 56)
                .overlay(Circle().fill(FC.forest).frame(width: 20, height: 20))
                .offset(x: -60, y: 0)
            // bolt medallion
            ZStack {
                Circle().fill(Color.white)
                    .overlay(Circle().strokeBorder(FC.forest, lineWidth: 1.5))
                Image(systemName: "bolt.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(FC.forest)
            }
            .frame(width: 72, height: 72)
            .offset(x: 30, y: -30)

            // houses
            HStack(spacing: 30) {
                Image(systemName: "house.fill").foregroundStyle(FC.forest).opacity(0.6)
                Image(systemName: "house.fill").foregroundStyle(FC.forest).opacity(0.6)
                Image(systemName: "house.fill").foregroundStyle(FC.forest).opacity(0.6)
            }
            .offset(y: 80)
        }
        .frame(width: 240, height: 180)
    }
}

private struct OnboardArt2: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(FC.forest, lineWidth: 1.5)
            )
            .frame(width: 160, height: 120)
            .overlay(
                VStack(spacing: 10) {
                    Capsule().fill(FC.lime).frame(width: 128, height: 8)
                    ForEach(0..<3) { r in
                        HStack(spacing: 8) {
                            ForEach(0..<4) { c in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(r == 1 && c == 1 ? FC.forest : FC.cream2)
                                    .frame(width: 24, height: 20)
                            }
                        }
                    }
                }
            )
    }
}

private struct OnboardArt3: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(FC.forest)
                .frame(width: 160, height: 100)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Capsule().fill(FC.lime).frame(width: 60, height: 8)
                    Spacer()
                }
                HStack {
                    Capsule().fill(Color.white.opacity(0.3)).frame(width: 40, height: 6)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        Circle().fill(FC.sun.opacity(0.8)).frame(width: 28, height: 28)
                            .offset(x: -8)
                        Circle().fill(FC.lime).frame(width: 28, height: 28)
                    }
                }
            }
            .padding(16)
            .frame(width: 160, height: 100)
        }
    }
}
