#!/usr/bin/env swift

import Cocoa

let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

let ctx = NSGraphicsContext.current!.cgContext

// 背景: より深いダーク
ctx.setFillColor(NSColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 1.0).cgColor)
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

// 地面: 暗めの茶色
ctx.setFillColor(NSColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1.0).cgColor)
ctx.fill(CGRect(x: 0, y: 0, width: size, height: 200))

// 道路
ctx.setFillColor(NSColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0).cgColor)
ctx.fill(CGRect(x: 0, y: 190, width: size, height: 24))

// 黄色い点線
ctx.setFillColor(NSColor(red: 0.85, green: 0.75, blue: 0.15, alpha: 0.7).cgColor)
var dashX = 40
while dashX < size {
    ctx.fill(CGRect(x: dashX, y: 199, width: 32, height: 6))
    dashX += 64
}

// === 建物群（明るめシルエット＝コントラスト強化） ===
let bldgLight = NSColor(red: 0.40, green: 0.40, blue: 0.50, alpha: 1.0).cgColor
let bldgMid   = NSColor(red: 0.30, green: 0.30, blue: 0.40, alpha: 1.0).cgColor
let bldgDark  = NSColor(red: 0.20, green: 0.20, blue: 0.28, alpha: 1.0).cgColor

// ビル1: 左 高い
ctx.setFillColor(bldgLight)
ctx.fill(CGRect(x: 120, y: 214, width: 200, height: 460))
// 屋根
ctx.beginPath()
ctx.move(to: CGPoint(x: 100, y: 674))
ctx.addLine(to: CGPoint(x: 220, y: 780))
ctx.addLine(to: CGPoint(x: 340, y: 674))
ctx.closePath()
ctx.fillPath()

// ビル2: 中央
ctx.setFillColor(bldgMid)
ctx.fill(CGRect(x: 380, y: 214, width: 160, height: 320))

// ビル3: 右 崩壊
ctx.setFillColor(bldgDark)
ctx.fill(CGRect(x: 600, y: 214, width: 140, height: 180))
ctx.fill(CGRect(x: 620, y: 394, width: 80, height: 70))

// 小残骸
ctx.fill(CGRect(x: 800, y: 214, width: 100, height: 100))

// === 窓（黒穴＝コントラスト強い） ===
let windowHole = NSColor(red: 0.03, green: 0.03, blue: 0.06, alpha: 1.0).cgColor
let windowGlow = NSColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 0.9).cgColor

// ビル1の窓
let b1windows: [(Int, Int, Bool)] = [
    (160, 280, false), (240, 280, false),
    (160, 370, true),  (240, 370, false),
    (160, 460, false), (240, 460, false),
    (160, 550, false), (240, 550, true),
]
for (wx, wy, lit) in b1windows {
    ctx.setFillColor(lit ? windowGlow : windowHole)
    ctx.fill(CGRect(x: wx, y: wy, width: 44, height: 56))
}

// ビル2の窓
let b2windows: [(Int, Int, Bool)] = [
    (410, 280, false), (480, 280, false),
    (410, 370, false), (480, 370, true),
]
for (wx, wy, lit) in b2windows {
    ctx.setFillColor(lit ? windowGlow : windowHole)
    ctx.fill(CGRect(x: wx, y: wy, width: 36, height: 46))
}

// ビル3の窓（全部暗い）
ctx.setFillColor(windowHole)
ctx.fill(CGRect(x: 630, y: 260, width: 30, height: 40))
ctx.fill(CGRect(x: 690, y: 260, width: 30, height: 40))

// === スマホ（中央下・強い光） ===
let phoneX: CGFloat = 460
let phoneY: CGFloat = 90
let phoneW: CGFloat = 48
let phoneH: CGFloat = 76

// 強いグロウ
let glowColors = [
    NSColor(red: 0.15, green: 0.60, blue: 1.0, alpha: 0.7).cgColor,
    NSColor(red: 0.15, green: 0.60, blue: 1.0, alpha: 0.0).cgColor,
]
let glowGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glowColors as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(glowGradient,
    startCenter: CGPoint(x: phoneX + phoneW/2, y: phoneY + phoneH/2),
    startRadius: 0,
    endCenter: CGPoint(x: phoneX + phoneW/2, y: phoneY + phoneH/2),
    endRadius: 140,
    options: [])

// スマホ本体
ctx.setFillColor(NSColor(red: 0.10, green: 0.10, blue: 0.15, alpha: 1.0).cgColor)
let phoneRect = CGRect(x: phoneX, y: phoneY, width: phoneW, height: phoneH)
let phonePath = CGPath(roundedRect: phoneRect, cornerWidth: 10, cornerHeight: 10, transform: nil)
ctx.addPath(phonePath)
ctx.fillPath()

// スマホ画面（明るい）
ctx.setFillColor(NSColor(red: 0.3, green: 0.65, blue: 1.0, alpha: 1.0).cgColor)
let screenRect = CGRect(x: phoneX + 5, y: phoneY + 7, width: phoneW - 10, height: phoneH - 14)
let screenPath = CGPath(roundedRect: screenRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
ctx.addPath(screenPath)
ctx.fillPath()

// === 月（明るく） ===
ctx.setFillColor(NSColor(red: 0.95, green: 0.92, blue: 0.7, alpha: 0.15).cgColor)
ctx.fillEllipse(in: CGRect(x: 760, y: 740, width: 140, height: 140))
ctx.setFillColor(NSColor(red: 0.95, green: 0.92, blue: 0.7, alpha: 0.5).cgColor)
ctx.fillEllipse(in: CGRect(x: 780, y: 760, width: 100, height: 100))

// === ひび割れ（白寄りで目立たせる） ===
ctx.setStrokeColor(NSColor(red: 0.55, green: 0.55, blue: 0.60, alpha: 0.5).cgColor)
ctx.setLineWidth(2.5)
ctx.beginPath()
ctx.move(to: CGPoint(x: 310, y: 520))
ctx.addLine(to: CGPoint(x: 330, y: 470))
ctx.addLine(to: CGPoint(x: 318, y: 410))
ctx.strokePath()

ctx.beginPath()
ctx.move(to: CGPoint(x: 700, y: 394))
ctx.addLine(to: CGPoint(x: 715, y: 340))
ctx.addLine(to: CGPoint(x: 705, y: 290))
ctx.strokePath()

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("Failed"); exit(1)
}
let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.png"
try! pngData.write(to: URL(fileURLWithPath: outputPath))
print("Icon generated: \(outputPath)")
