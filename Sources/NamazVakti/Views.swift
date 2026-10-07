import SwiftUI

struct AnaGorunum: View {
    @ObservedObject var store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            baslik
            Divider()
            vakitListesi
            Divider()
            konumSecimi
            Divider()
            ayarlar
            kredi
        }
        .padding(16)
        .frame(width: 300)
    }

    private var baslik: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(store.siradaki.map { "\($0.ad) vaktine kalan" } ?? "Vakitler yükleniyor")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(store.kalan)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
            if let durum = store.durum {
                Text(durum).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var vakitListesi: some View {
        VStack(spacing: 6) {
            ForEach(store.bugun) { v in
                let siradaki = v.id == store.siradaki?.id
                HStack {
                    Text(v.ad)
                    Spacer()
                    Text(v.zaman, format: .dateTime.hour().minute()
                        .locale(Locale(identifier: "tr_TR")))
                        .monospacedDigit()
                }
                .fontWeight(siradaki ? .bold : .regular)
                .foregroundStyle(siradaki ? Color.accentColor : Color.primary)
            }
        }
    }

    private var konumSecimi: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Konumumu otomatik bul", isOn: Binding(
                get: { store.otomatik },
                set: { store.otomatikAyarla($0) }
            ))
            Group {
                secici("Ülke", store.ulkeler, secili: store.konum.ulke,
                       ad: { $0.UlkeAdi.capitalizedTR }) { u in Task { await store.ulkeSec(u) } }
                secici("Şehir", store.sehirler, secili: store.konum.sehir,
                       ad: { $0.SehirAdi.capitalizedTR }) { s in Task { await store.sehirSec(s) } }
                secici("İlçe", store.ilceler, secili: store.konum.ilce,
                       ad: { $0.IlceAdi.capitalizedTR }) { i in store.ilceSec(i) }
            }
            .disabled(store.otomatik)
        }
    }

    private func secici<T: Identifiable & Hashable>(
        _ baslik: String, _ liste: [T], secili: T,
        ad: @escaping (T) -> String, degisti: @escaping (T) -> Void
    ) -> some View where T.ID == String {
        let secenekler = liste.contains(secili) ? liste : [secili] + liste
        return HStack {
            Text(baslik).frame(width: 44, alignment: .leading)
            Picker(baslik, selection: Binding(get: { secili }, set: degisti)) {
                ForEach(secenekler) { Text(ad($0)).tag($0) }
            }
            .labelsHidden()
        }
    }

    private var ayarlar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Açılışta başlat", isOn: Binding(
                get: { store.acilistaBaslat },
                set: { store.acilistaBaslatAyarla($0) }
            ))
            HStack {
                Text("Diyanet verisi · resmi olmayan uygulama")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Çıkış") { NSApplication.shared.terminate(nil) }
            }
        }
    }

    private var kredi: some View {
        HStack(spacing: 4) {
            Text("Designed by")
            Link("16:40", destination: URL(string: "https://www.1640.com.tr/")!)
            Text("|")
            Link("Social", destination: URL(string: "https://www.instagram.com/1640dijital/")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
    }
}
