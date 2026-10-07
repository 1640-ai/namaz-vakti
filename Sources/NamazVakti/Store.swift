import Foundation
import ServiceManagement

@MainActor
final class Store: ObservableObject {
    static let varsayilan = SecilenKonum(
        ulke: Ulke(UlkeAdi: "TÜRKİYE", UlkeAdiEn: "TÜRKİYE", UlkeID: "2"),
        sehir: Sehir(SehirAdi: "İSTANBUL", SehirAdiEn: "ISTANBUL", SehirID: "539"),
        ilce: Ilce(IlceAdi: "İSTANBUL", IlceAdiEn: "ISTANBUL", IlceID: "9541")
    )
    static let adlar = ["Imsak": "İmsak", "Gunes": "Güneş", "Ogle": "Öğle",
                        "Ikindi": "İkindi", "Aksam": "Akşam", "Yatsi": "Yatsı"]

    @Published var simdi = Date()
    @Published var konum: SecilenKonum
    @Published var otomatik: Bool
    @Published var acilistaBaslat: Bool
    @Published var gunler: [GunlukVakit] = []
    @Published var ulkeler: [Ulke] = []
    @Published var sehirler: [Sehir] = []
    @Published var ilceler: [Ilce] = []
    @Published var durum: String?

    private let ud = UserDefaults.standard
    private var sonYenileme = Date.distantPast
    private var sonOtomatik = Date.distantPast

    init() {
        if let veri = ud.data(forKey: "konum"), let k = try? JSONDecoder().decode(SecilenKonum.self, from: veri) {
            konum = k
        } else {
            konum = Store.varsayilan
        }
        otomatik = ud.bool(forKey: "otomatik")
        acilistaBaslat = SMAppService.mainApp.status == .enabled
        if let veri = ud.data(forKey: "gunler_\(konum.ilce.IlceID)"),
           let g = try? JSONDecoder().decode([GunlukVakit].self, from: veri) {
            gunler = g
        }
        Task { await baslat() }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tik() }
        }
    }

    // MARK: Zamanlayıcı

    private func tik() {
        simdi = Date()
        if simdi.timeIntervalSince(sonYenileme) > 6 * 3600 || gunler.isEmpty && simdi.timeIntervalSince(sonYenileme) > 60 {
            Task { await vakitleriYenile() }
        }
        if otomatik && simdi.timeIntervalSince(sonOtomatik) > 6 * 3600 {
            Task { await otomatikBul() }
        }
    }

    private func baslat() async {
        if otomatik { await otomatikBul() }
        await vakitleriYenile()
        await listeleriYukle()
    }

    // MARK: Vakitler

    func vakitleriYenile() async {
        sonYenileme = Date()
        let id = konum.ilce.IlceID
        do {
            let g = try await API.vakitler(ilce: id)
            guard id == konum.ilce.IlceID else { return }
            gunler = g
            if let veri = try? JSONEncoder().encode(g) { ud.set(veri, forKey: "gunler_\(id)") }
            durum = nil
        } catch {
            if gunler.isEmpty { durum = "Vakitler alınamadı. İnternet bağlantısını kontrol et." }
        }
    }

    private func tarih(_ gun: GunlukVakit, _ saat: String) -> Date? {
        let p = gun.MiladiTarihKisa.split(separator: ".").compactMap { Int($0) }
        let s = saat.split(separator: ":").compactMap { Int($0) }
        guard p.count == 3, s.count == 2 else { return nil }
        var takvim = Calendar(identifier: .gregorian)
        takvim.timeZone = TimeZone(secondsFromGMT: Int(gun.GreenwichOrtalamaZamani * 3600)) ?? .current
        return takvim.date(from: DateComponents(year: p[2], month: p[1], day: p[0], hour: s[0], minute: s[1]))
    }

    private func vakitler(_ gun: GunlukVakit) -> [Vakit] {
        [("Imsak", gun.Imsak), ("Gunes", gun.Gunes), ("Ogle", gun.Ogle),
         ("Ikindi", gun.Ikindi), ("Aksam", gun.Aksam), ("Yatsi", gun.Yatsi)]
            .compactMap { ad, saat in
                tarih(gun, saat).map { Vakit(ad: Store.adlar[ad] ?? ad, zaman: $0) }
            }
    }

    var hepsi: [Vakit] { gunler.flatMap { vakitler($0) }.sorted { $0.zaman < $1.zaman } }

    var siradaki: Vakit? { hepsi.first { $0.zaman > simdi } }

    /// Bugünün altı vakti (konumun saat dilimine göre).
    var bugun: [Vakit] {
        let tz = TimeZone(secondsFromGMT: Int((gunler.first?.GreenwichOrtalamaZamani ?? 3) * 3600)) ?? .current
        var takvim = Calendar(identifier: .gregorian)
        takvim.timeZone = tz
        return hepsi.filter { takvim.isDate($0.zaman, inSameDayAs: simdi) }
    }

    var kalan: String {
        guard let s = siradaki else { return "--:--:--" }
        let t = max(0, Int(s.zaman.timeIntervalSince(simdi).rounded(.up)))
        return String(format: "%02d:%02d:%02d", t / 3600, t % 3600 / 60, t % 60)
    }

    var menuMetni: String {
        guard let s = siradaki else { return "Namaz Vakti" }
        return "\(s.ad) \(kalan)"
    }

    // MARK: Konum seçimi

    func listeleriYukle() async {
        if ulkeler.isEmpty, let u = try? await API.ulkeler() { ulkeler = u }
        if let s = try? await API.sehirler(ulke: konum.ulke.UlkeID) { sehirler = s }
        if let i = try? await API.ilceler(sehir: konum.sehir.SehirID) { ilceler = i }
    }

    private func kaydet() {
        if let veri = try? JSONEncoder().encode(konum) { ud.set(veri, forKey: "konum") }
    }

    func ulkeSec(_ u: Ulke) async {
        guard u != konum.ulke, let s = try? await API.sehirler(ulke: u.UlkeID), let ilkSehir = s.first else { return }
        sehirler = s
        await sehirSec(ilkSehir, ulke: u)
    }

    func sehirSec(_ s: Sehir, ulke: Ulke? = nil) async {
        guard let i = try? await API.ilceler(sehir: s.SehirID), let ilkIlce = i.first else { return }
        ilceler = i
        let merkez = i.first { $0.IlceAdiEn.anahtar == s.SehirAdiEn.anahtar } ?? ilkIlce
        konumAyarla(SecilenKonum(ulke: ulke ?? konum.ulke, sehir: s, ilce: merkez))
    }

    func ilceSec(_ i: Ilce) {
        konumAyarla(SecilenKonum(ulke: konum.ulke, sehir: konum.sehir, ilce: i))
    }

    private func konumAyarla(_ k: SecilenKonum) {
        guard k != konum else { return }
        konum = k
        kaydet()
        gunler = []
        if let veri = ud.data(forKey: "gunler_\(k.ilce.IlceID)"),
           let g = try? JSONDecoder().decode([GunlukVakit].self, from: veri) {
            gunler = g
        }
        Task { await vakitleriYenile() }
    }

    // MARK: Otomatik konum

    func otomatikAyarla(_ acik: Bool) {
        otomatik = acik
        ud.set(acik, forKey: "otomatik")
        if acik { Task { await otomatikBul() } }
    }

    func otomatikBul() async {
        sonOtomatik = Date()
        do {
            let ip = try await IPKonum.bul()
            if ulkeler.isEmpty { ulkeler = try await API.ulkeler() }
            let ulkeAdi = (ip.country ?? "").anahtar
            guard let ulke = ip.country_code == "TR"
                    ? ulkeler.first(where: { $0.UlkeID == "2" })
                    : ulkeler.first(where: { $0.UlkeAdiEn.anahtar == ulkeAdi || $0.UlkeAdi.anahtar == ulkeAdi })
            else { durum = "Bu ülke Diyanet listesinde yok."; return }

            let sehirListesi = try await API.sehirler(ulke: ulke.UlkeID)
            let bolge = (ip.region ?? "").anahtar
            let sehirAdi = (ip.city ?? "").anahtar
            guard let sehir = sehirListesi.first(where: { $0.SehirAdiEn.anahtar == bolge || $0.SehirAdi.anahtar == bolge })
                    ?? sehirListesi.first(where: { $0.SehirAdiEn.anahtar == sehirAdi || $0.SehirAdi.anahtar == sehirAdi })
                    ?? sehirListesi.first
            else { return }

            let ilceListesi = try await API.ilceler(sehir: sehir.SehirID)
            guard let ilce = ilceListesi.first(where: { $0.IlceAdiEn.anahtar == sehirAdi || $0.IlceAdi.anahtar == sehirAdi })
                    ?? ilceListesi.first(where: { $0.IlceAdiEn.anahtar == sehir.SehirAdiEn.anahtar })
                    ?? ilceListesi.first
            else { return }

            sehirler = sehirListesi
            ilceler = ilceListesi
            konumAyarla(SecilenKonum(ulke: ulke, sehir: sehir, ilce: ilce))
            durum = nil
        } catch {
            durum = "Konum bulunamadı. İnternet bağlantısını kontrol et."
        }
    }

    // MARK: Açılışta başlat

    func acilistaBaslatAyarla(_ acik: Bool) {
        do {
            if acik { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            durum = "Açılışta başlatma ayarı değişmedi."
        }
        acilistaBaslat = SMAppService.mainApp.status == .enabled
    }
}
