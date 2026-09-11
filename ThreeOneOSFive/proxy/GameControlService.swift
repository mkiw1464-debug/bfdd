import Foundation
import Combine

// MARK: - GameControlService
// Central @ObservableObject — holds config state, wires ke GameBridge.
// SwiftUI views @EnvironmentObject ini.

final class GameControlService: ObservableObject {

    @Published var config = GameControlConfiguration()
    let bridge = GameBridge()
    private var bag = Set<AnyCancellable>()
    private let saveKey = "com.3105.gameconfig.v1"

    init() {
        loadSaved()
        bridge.update(config)
        bridge.start()

        $config
            .debounce(for: .milliseconds(80), scheduler: RunLoop.main)
            .sink { [weak self] c in
                self?.bridge.update(c)
                self?.persist(c)
            }
            .store(in: &bag)
    }

    // ── Slot binding ──────────────────────────────────────────────────

    func slotBinding(_ idx: Int) -> Binding<Bool> {
        Binding(get: { self.slotGet(idx) }, set: { self.slotSet(idx, $0) })
    }

    private func slotGet(_ i: Int) -> Bool {
        switch i {
        case 0:  return config.q00; case 1:  return config.q01
        case 2:  return config.q02; case 3:  return config.q03
        case 4:  return config.q04; case 5:  return config.q05
        case 6:  return config.q06; case 7:  return config.q07
        case 8:  return config.q08; case 9:  return config.q09
        case 10: return config.q10; case 11: return config.q11
        case 12: return config.q12; case 13: return config.q13
        case 14: return config.q14; case 15: return config.q15
        case 16: return config.q16; case 17: return config.q17
        case 18: return config.q18; case 19: return config.q19
        case 20: return config.q20; case 21: return config.q21
        default: return false
        }
    }

    private func slotSet(_ i: Int, _ v: Bool) {
        switch i {
        case 0:  config.q00 = v; case 1:  config.q01 = v
        case 2:  config.q02 = v; case 3:  config.q03 = v
        case 4:  config.q04 = v; case 5:  config.q05 = v
        case 6:  config.q06 = v; case 7:  config.q07 = v
        case 8:  config.q08 = v; case 9:  config.q09 = v
        case 10: config.q10 = v; case 11: config.q11 = v
        case 12: config.q12 = v; case 13: config.q13 = v
        case 14: config.q14 = v; case 15: config.q15 = v
        case 16: config.q16 = v; case 17: config.q17 = v
        case 18: config.q18 = v; case 19: config.q19 = v
        case 20: config.q20 = v; case 21: config.q21 = v
        default: break
        }
    }

    func resetAll() { config = GameControlConfiguration() }

    // ── Persistence ───────────────────────────────────────────────────

    private func persist(_ c: GameControlConfiguration) {
        guard let d = try? JSONEncoder().encode(c) else { return }
        UserDefaults.standard.set(d, forKey: saveKey)
    }

    private func loadSaved() {
        guard let d = UserDefaults.standard.data(forKey: saveKey),
              let c = try? JSONDecoder().decode(GameControlConfiguration.self, from: d)
        else { return }
        config = c
    }
}
