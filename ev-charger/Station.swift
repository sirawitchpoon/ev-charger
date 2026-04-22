import Foundation

struct Connector: Identifiable, Hashable {
    var id: String { kind }
    let kind: String
    let kw: Int
    let free: Int
    let total: Int
    var isDrone: Bool { kind == "Drone Pad" }
}

struct Station: Identifiable, Hashable {
    let id: String
    let name: String
    let nameEn: String
    let code: String
    let distance: Double
    let eta: Int
    let address: String
    let kw: Int
    let availTotal: Int
    let availFree: Int
    let price: Double
    let rating: Double
    let reviews: Int
    let open: String
    let solar: Bool
    let types: [String]
    let connectors: [Connector]
    let x: CGFloat
    let y: CGFloat

    static let all: [Station] = [
        Station(
            id: "s1",
            name: "สถานีนาข้าวทุ่งกุลา",
            nameEn: "Thung Kula Rice Field",
            code: "FC-TKL-01",
            distance: 2.4, eta: 6,
            address: "ต.ทุ่งกุลา อ.สุวรรณภูมิ จ.ร้อยเอ็ด",
            kw: 60, availTotal: 4, availFree: 3,
            price: 4.5, rating: 4.8, reviews: 126,
            open: "24 ชม.", solar: true,
            types: ["car", "drone"],
            connectors: [
                Connector(kind: "CCS2", kw: 60, free: 2, total: 2),
                Connector(kind: "Type 2", kw: 22, free: 1, total: 1),
                Connector(kind: "Drone Pad", kw: 12, free: 0, total: 1),
            ],
            x: 0.52, y: 0.42
        ),
        Station(
            id: "s2",
            name: "จุดชาร์จสวนยางหนองบัว",
            nameEn: "Nong Bua Rubber Grove",
            code: "FC-NBV-03",
            distance: 5.1, eta: 11,
            address: "ต.หนองบัว อ.บ้านไผ่ จ.ขอนแก่น",
            kw: 120, availTotal: 6, availFree: 2,
            price: 5.2, rating: 4.6, reviews: 84,
            open: "06:00 – 22:00", solar: true,
            types: ["car", "drone"],
            connectors: [
                Connector(kind: "CCS2", kw: 120, free: 1, total: 3),
                Connector(kind: "Type 2", kw: 22, free: 0, total: 1),
                Connector(kind: "Drone Pad", kw: 12, free: 1, total: 2),
            ],
            x: 0.30, y: 0.64
        ),
        Station(
            id: "s3",
            name: "ฟาร์มมะม่วงลุงสาย",
            nameEn: "Uncle Sai's Mango Farm",
            code: "FC-MAN-07",
            distance: 8.7, eta: 17,
            address: "ต.ท่ามะไฟ อ.บ้านหมี่ จ.ลพบุรี",
            kw: 22, availTotal: 2, availFree: 0,
            price: 3.9, rating: 4.9, reviews: 42,
            open: "05:00 – 20:00", solar: false,
            types: ["drone"],
            connectors: [
                Connector(kind: "Drone Pad", kw: 22, free: 0, total: 2),
            ],
            x: 0.72, y: 0.28
        ),
        Station(
            id: "s4",
            name: "ปั๊มชุมชนบ้านดอน",
            nameEn: "Ban Don Community Pump",
            code: "FC-BDN-12",
            distance: 12.3, eta: 22,
            address: "ต.บ้านดอน อ.ท่าหลวง จ.ลพบุรี",
            kw: 60, availTotal: 3, availFree: 3,
            price: 4.2, rating: 4.4, reviews: 61,
            open: "24 ชม.", solar: true,
            types: ["car"],
            connectors: [
                Connector(kind: "CCS2", kw: 60, free: 2, total: 2),
                Connector(kind: "Type 2", kw: 22, free: 1, total: 1),
            ],
            x: 0.18, y: 0.24
        ),
    ]

    static func find(_ id: String) -> Station {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}
