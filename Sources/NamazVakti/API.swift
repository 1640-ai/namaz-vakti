import Foundation

/// Diyanet verisini sunan açık API (namazvakti.diyanet.gov.tr verisinin yansıması).
enum API {
    static let base = "https://ezanvakti.emushaf.net"

    static func get<T: Decodable>(_ yol: String) async throws -> T {
        guard let url = URL(string: base + yol) else { throw URLError(.badURL) }
        var istek = URLRequest(url: url)
        istek.timeoutInterval = 20
        let (veri, cevap) = try await URLSession.shared.data(for: istek)
        guard (cevap as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(T.self, from: veri)
    }

    static func ulkeler() async throws -> [Ulke] { try await get("/ulkeler") }
    static func sehirler(ulke: String) async throws -> [Sehir] { try await get("/sehirler/\(ulke)") }
    static func ilceler(sehir: String) async throws -> [Ilce] { try await get("/ilceler/\(sehir)") }
    static func vakitler(ilce: String) async throws -> [GunlukVakit] { try await get("/vakitler/\(ilce)") }
}

/// IP adresinden yaklaşık konum bulur.
struct IPKonum: Decodable {
    let success: Bool
    let country: String?
    let country_code: String?
    let region: String?
    let city: String?

    static func bul() async throws -> IPKonum {
        guard let url = URL(string: "https://ipwho.is/?fields=success,country,country_code,region,city") else {
            throw URLError(.badURL)
        }
        let (veri, _) = try await URLSession.shared.data(from: url)
        let sonuc = try JSONDecoder().decode(IPKonum.self, from: veri)
        guard sonuc.success else { throw URLError(.cannotFindHost) }
        return sonuc
    }
}
