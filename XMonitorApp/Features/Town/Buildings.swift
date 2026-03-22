import SwiftUI

/// レベルに応じた建物群を描画（起動ごとにシャッフル）
struct BuildingsView: View {
    let level: TownLevel
    @State private var shuffledBuildings: [Building] = []

    var body: some View {
        GeometryReader { geo in
            let buildingWidth = geo.size.width / 7

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(shuffledBuildings.enumerated()), id: \.offset) { _, building in
                    BuildingUnit(building: building, width: buildingWidth)
                }
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: -geo.size.height * 0.27)
        }
        .onAppear {
            shuffledBuildings = baseBuildings(for: level).shuffled()
        }
    }

    private func baseBuildings(for level: TownLevel) -> [Building] {
        switch level {
        case .paradise:
            return [
                .init(type: .castle, condition: .pristine),
                .init(type: .shop, condition: .pristine),
                .init(type: .house, condition: .pristine),
                .init(type: .house, condition: .pristine),
                .init(type: .shop, condition: .pristine),
                .init(type: .tree, condition: .pristine),
            ]
        case .prosperity:
            return [
                .init(type: .shop, condition: .pristine),
                .init(type: .house, condition: .pristine),
                .init(type: .house, condition: .pristine),
                .init(type: .shop, condition: .pristine),
                .init(type: .tree, condition: .pristine),
                .init(type: .tree, condition: .pristine),
            ]
        case .calm:
            return [
                .init(type: .shop, condition: .pristine),
                .init(type: .house, condition: .pristine),
                .init(type: .house, condition: .aged),
                .init(type: .house, condition: .pristine),
                .init(type: .tree, condition: .aged),
                .init(type: .empty, condition: .pristine),
            ]
        case .stagnation:
            return [
                .init(type: .shop, condition: .aged),
                .init(type: .house, condition: .ruined),
                .init(type: .house, condition: .aged),
                .init(type: .house, condition: .pristine),
                .init(type: .tree, condition: .aged),
                .init(type: .empty, condition: .pristine),
            ]
        case .decline:
            return [
                .init(type: .house, condition: .ruined),
                .init(type: .house, condition: .ruined),
                .init(type: .shop, condition: .ruined),
                .init(type: .tree, condition: .dead),
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
            ]
        case .ruins:
            return [
                .init(type: .rubble, condition: .ruined),
                .init(type: .house, condition: .ruined),
                .init(type: .empty, condition: .pristine),
                .init(type: .rubble, condition: .ruined),
                .init(type: .tree, condition: .dead),
                .init(type: .empty, condition: .pristine),
            ]
        case .extinction:
            return [
                .init(type: .empty, condition: .pristine),
                .init(type: .rubble, condition: .ruined),
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
                .init(type: .rubble, condition: .ruined),
                .init(type: .empty, condition: .pristine),
            ]
        case .reincarnation:
            return [
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
                .init(type: .empty, condition: .pristine),
            ]
        }
    }
}

// MARK: - Building Model

struct Building {
    enum BuildingType {
        case castle, shop, house, tree, rubble, empty
    }

    enum Condition {
        case pristine, aged, ruined, dead
    }

    let type: BuildingType
    let condition: Condition
}

// MARK: - Building Unit View

struct BuildingUnit: View {
    let building: Building
    let width: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            buildingEmoji
                .font(.system(size: emojiSize))
                .opacity(building.condition == .ruined ? 0.7 : 1.0)
                .saturation(saturation)
        }
        .frame(width: width)
    }

    @ViewBuilder
    private var buildingEmoji: some View {
        switch (building.type, building.condition) {
        case (.castle, _):       Text("🏰")
        case (.shop, .pristine): Text("🏪")
        case (.shop, .aged):     Text("🏪")
        case (.shop, .ruined):   Text("🏚️")
        case (.shop, .dead):     Text("🏚️")
        case (.house, .pristine): Text("🏠")
        case (.house, .aged):    Text("🏠")
        case (.house, .ruined):  Text("🏚️")
        case (.house, .dead):    Text("🏚️")
        case (.tree, .pristine): Text("🌳")
        case (.tree, .aged):     Text("🌲")
        case (.tree, .ruined):   Text("🪵")
        case (.tree, .dead):     Text("🪨")
        case (.rubble, _):       Text("🪨")
        case (.empty, _):        Text(" ")
        }
    }

    private var emojiSize: CGFloat {
        switch building.type {
        case .castle: 36
        case .shop, .house: 28
        case .tree: 24
        case .rubble: 20
        case .empty: 16
        }
    }

    private var saturation: Double {
        switch building.condition {
        case .pristine: 1.0
        case .aged: 0.7
        case .ruined: 0.4
        case .dead: 0.2
        }
    }
}
