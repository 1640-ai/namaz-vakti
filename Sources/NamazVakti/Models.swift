import Foundation

struct Ulke: Codable, Hashable, Identifiable {
    let UlkeAdi: String
    let UlkeAdiEn: String
    let UlkeID: String
    var id: String { UlkeID }
}

struct Sehir: Codable, Hashable, Identifiable {
    let SehirAdi: String
    let SehirAdiEn: String
    let SehirID: String
    var id: String { SehirID }
}

struct Ilce: Codable, Hashable, Identifiable {
    let IlceAdi: String
    let IlceAdiEn: String
    let IlceID: String
    var id: String { IlceID }
}

/// Diyanet'in bir günlük vakit kaydı.
struct GunlukVakit: Codable {
    let MiladiTarihKisa: String          // "04.10.2026"
    let GreenwichOrtalamaZamani: Double  // UTC farkı (saat)
    let Imsak: String
    let Gunes: String
    let Ogle: String
    let Ikindi: String
    let Aksam: String
    let Yatsi: String
}

struct SecilenKonum: Codable, Equatable {
    var ulke: Ulke
    var sehir: Sehir
    var ilce: Ilce

    var gosterim: String { "\(ilce.IlceAdi.capitalizedTR) / \(sehir.SehirAdi.capitalizedTR)" }
}

struct Vakit: Identifiable {
    let ad: String
    let zaman: Date
    var id: String { ad }
}

extension String {
    var capitalizedTR: String {
        capitalized(with: Locale(identifier: "tr_TR"))
    }

    /// Harf büyüklüğü ve aksan farkını yok sayan karşılaştırma anahtarı.
    var anahtar: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
            .replacingOccurrences(of: "ı", with: "i")
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
    }
}
