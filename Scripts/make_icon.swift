// Kullanım: swift Scripts/make_icon.swift Resources/AppIcon.icns
import AppKit

func ciz(_ boyut: Int) -> Data {
    let s = CGFloat(boyut)
    let img = NSImage(size: NSSize(width: s, height: s))
    img.lockFocus()
    let kare = NSRect(x: s * 0.06, y: s * 0.06, width: s * 0.88, height: s * 0.88)
    let zemin = NSBezierPath(roundedRect: kare, xRadius: s * 0.2, yRadius: s * 0.2)
    NSGradient(colors: [NSColor(red: 0.07, green: 0.45, blue: 0.33, alpha: 1),
                        NSColor(red: 0.02, green: 0.25, blue: 0.20, alpha: 1)])!
        .draw(in: zemin, angle: -90)

    // Hilal: büyük daireden kaydırılmış daire çıkarılır.
    let merkez = CGPoint(x: s * 0.46, y: s * 0.5)
    let r = s * 0.27
    let hilal = NSBezierPath()
    hilal.windingRule = .evenOdd
    hilal.appendOval(in: NSRect(x: merkez.x - r, y: merkez.y - r, width: 2 * r, height: 2 * r))
    let r2 = r * 0.82
    hilal.appendOval(in: NSRect(x: merkez.x - r2 + r * 0.45, y: merkez.y - r2 + r * 0.1, width: 2 * r2, height: 2 * r2))
    NSColor.white.setFill()
    // Çıkarma için önce kırp.
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(ovalIn: NSRect(x: merkez.x - r, y: merkez.y - r, width: 2 * r, height: 2 * r)).addClip()
    hilal.fill()
    NSGraphicsContext.restoreGraphicsState()

    // Beş köşeli yıldız.
    let yc = CGPoint(x: s * 0.62, y: s * 0.5)
    let yr = s * 0.075
    let yildiz = NSBezierPath()
    for i in 0..<10 {
        let aci = CGFloat.pi / 2 + CGFloat(i) * .pi / 5
        let rr = i % 2 == 0 ? yr : yr * 0.4
        let p = CGPoint(x: yc.x + cos(aci) * rr, y: yc.y + sin(aci) * rr)
        i == 0 ? yildiz.move(to: p) : yildiz.line(to: p)
    }
    yildiz.close()
    yildiz.fill()
    img.unlockFocus()

    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    return rep.representation(using: .png, properties: [:])!
}

let cikti = CommandLine.arguments[1]
let set = NSTemporaryDirectory() + "AppIcon.iconset"
try? FileManager.default.removeItem(atPath: set)
try FileManager.default.createDirectory(atPath: set, withIntermediateDirectories: true)
for (ad, boyut) in [("16", 16), ("16@2x", 32), ("32", 32), ("32@2x", 64), ("128", 128),
                    ("128@2x", 256), ("256", 256), ("256@2x", 512), ("512", 512), ("512@2x", 1024)] {
    let ad2 = ad.replacingOccurrences(of: "@2x", with: "")
    let sonek = ad.contains("@2x") ? "@2x" : ""
    try ciz(boyut).write(to: URL(fileURLWithPath: "\(set)/icon_\(ad2)x\(ad2)\(sonek).png"))
}
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", set, "-o", cikti]
try p.run(); p.waitUntilExit()
