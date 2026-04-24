import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var router: Router

    private struct Row { let icon: AnyView; let title: String; let sub: String; let dest: AppScreen? }

    private var rows: [Row] {
        [
            Row(icon: AnyView(Image(systemName: "car.fill").font(.system(size: 16))), title: "รถของฉัน", sub: "1 คัน · Isuzu D-Max EV", dest: nil),
            Row(icon: AnyView(DroneGlyph(size: 16)), title: "โดรนของฉัน", sub: "1 เครื่อง · DJI Agras T40", dest: nil),
            Row(icon: AnyView(Image(systemName: "creditcard.fill").font(.system(size: 16))), title: "วิธีชำระเงิน", sub: "PromptPay, บัตร **** 4521", dest: nil),
            Row(icon: AnyView(Image(systemName: "doc.text.fill").font(.system(size: 16))), title: "ประวัติการชาร์จ", sub: "12 ครั้งเดือนนี้", dest: .trips),
            Row(icon: AnyView(Image(systemName: "star.fill").font(.system(size: 16))), title: "สถานีที่บันทึกไว้", sub: "4 สถานี", dest: nil),
            Row(icon: AnyView(Image(systemName: "globe").font(.system(size: 16))), title: "ภาษา", sub: "ไทย", dest: nil),
            Row(icon: AnyView(Image(systemName: "message.fill").font(.system(size: 16))), title: "ช่วยเหลือ", sub: "ติดต่อ LINE @farmcharge", dest: nil),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            TopNav(title: "โปรไฟล์") { router.goto(.map) }
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    CardView(padding: 0) {
                        VStack(spacing: 0) {
                            ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                                Button {
                                    if let d = r.dest { router.goto(d) }
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(FC.forest.opacity(0.06))
                                                .frame(width: 36, height: 36)
                                            r.icon.foregroundStyle(FC.forest)
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(r.title).font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(FC.ink)
                                            Text(r.sub).font(.system(size: 12))
                                                .foregroundStyle(FC.muted)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(FC.muted2)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(.plain)
                                if i < rows.count - 1 {
                                    Rectangle().fill(FC.line).frame(height: 0.5)
                                        .padding(.leading, 64)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(FC.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(FC.forest)
            Circle()
                .fill(FC.lime.opacity(0.1))
                .frame(width: 120, height: 120)
                .offset(x: 130, y: -40)
            HStack(spacing: 14) {
                Text("ส")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(FC.forest)
                    .frame(width: 64, height: 64)
                    .background(FC.lime, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("สมชาย ใจดี")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("สมาชิก FarmCharge · ร้อยเอ็ด")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.75))
                    Pill("ประหยัดได้ ฿1,240 เดือนนี้",
                         icon: AnyView(Image(systemName: "leaf.fill").font(.system(size: 10))),
                         background: FC.lime, foreground: FC.forest)
                        .padding(.top, 6)
                }
                Spacer()
            }
            .padding(20)
        }
        .frame(height: 140)
    }
}

struct TripsView: View {
    @EnvironmentObject var router: Router

    private struct Trip { let date: String; let station: String; let kwh: Double; let cost: Int; let isDrone: Bool }
    private let trips: [Trip] = [
        Trip(date: "18 เม.ย.", station: "สถานีนาข้าวทุ่งกุลา", kwh: 28, cost: 126, isDrone: false),
        Trip(date: "15 เม.ย.", station: "ฟาร์มมะม่วงลุงสาย", kwh: 4.2, cost: 17, isDrone: true),
        Trip(date: "14 เม.ย.", station: "จุดชาร์จสวนยางหนองบัว", kwh: 42, cost: 218, isDrone: false),
        Trip(date: "12 เม.ย.", station: "ปั๊มชุมชนบ้านดอน", kwh: 30, cost: 126, isDrone: false),
        Trip(date: "10 เม.ย.", station: "ฟาร์มมะม่วงลุงสาย", kwh: 3.8, cost: 15, isDrone: true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TopNav(title: "ประวัติการชาร์จ") { router.goto(.profile) }
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    CardView(background: FC.forest) {
                        Text("สรุปเดือน เม.ย.")
                            .font(.system(size: 12, weight: .medium))
                            .tracking(0.5)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.white.opacity(0.7))
                        HStack(spacing: 20) {
                            summary(v: "12", u: "ครั้ง", label: "ชาร์จ")
                            summary(v: "168", u: "kWh", label: "รวม")
                            summary(v: "฿720", u: "", label: "ใช้จ่าย")
                        }
                        .padding(.top, 10)
                    }

                    CardView(padding: 0) {
                        VStack(spacing: 0) {
                            ForEach(Array(trips.enumerated()), id: \.offset) { i, t in
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                                            .fill(t.isDrone ? FC.purple.opacity(0.1) : FC.forest.opacity(0.06))
                                            .frame(width: 40, height: 40)
                                        if t.isDrone {
                                            DroneGlyph(size: 20, color: FC.purple)
                                        } else {
                                            Image(systemName: "car.fill")
                                                .font(.system(size: 18))
                                                .foregroundStyle(FC.forest)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(t.station).font(.system(size: 14, weight: .semibold))
                                        Text("\(t.date) · \(formatted(t.kwh)) kWh")
                                            .font(.system(size: 12))
                                            .foregroundStyle(FC.muted)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("฿\(t.cost)").font(.system(size: 15, weight: .semibold))
                                        Text("ใบเสร็จ →").font(.system(size: 11)).foregroundStyle(FC.muted)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                if i < trips.count - 1 {
                                    Rectangle().fill(FC.line).frame(height: 0.5)
                                        .padding(.leading, 64)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .background(FC.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func summary(v: String, u: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(v).serif(size: 28).foregroundStyle(FC.lime)
                Text(u).font(.system(size: 11)).foregroundStyle(Color.white.opacity(0.7))
            }
            Text(label).font(.system(size: 11)).foregroundStyle(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatted(_ d: Double) -> String {
        String(format: d == floor(d) ? "%.0f" : "%.1f", d)
    }
}

struct SearchView: View {
    @EnvironmentObject var router: Router
    @State private var query = "ทุ่งกุลา"

    private let suggestions = ["สถานีใกล้ฉัน", "จุดชาร์จโดรน", "ทุ่งกุลาร้องไห้", "บ้านไผ่ ขอนแก่น"]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button { router.goto(.map) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(FC.ink)
                        .frame(width: 40, height: 40)
                        .background(Color.white, in: Circle())
                        .overlay(Circle().strokeBorder(FC.line, lineWidth: 0.5))
                }
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(FC.forest)
                    TextField("ค้นหา...", text: $query)
                        .font(.system(size: 15))
                        .foregroundStyle(FC.ink)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(FC.forest, lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel(text: "แนะนำ")
                    VStack(spacing: 0) {
                        ForEach(suggestions, id: \.self) { s in
                            Button { router.goto(.map) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 14))
                                        .foregroundStyle(FC.muted)
                                    Text(s).font(.system(size: 15))
                                        .foregroundStyle(FC.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(FC.muted2)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .overlay(alignment: .bottom) {
                                    Rectangle().fill(FC.line).frame(height: 0.5)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    SectionLabel(text: "ผลลัพธ์")
                        .padding(.top, 20)
                    VStack(spacing: 10) {
                        ForEach(Station.all.prefix(3)) { s in
                            StationCardView(s: s) {
                                router.goto(.detail, stationId: s.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .background(FC.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
