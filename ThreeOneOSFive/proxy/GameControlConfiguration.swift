import Foundation

// MARK: - GameControlConfiguration
// Struct ini di-encode ke JSON dan served kat http://127.0.0.1:8080/config
// Game patch (Assembly-CSharp-patch.bytes) GET endpoint ni masa boot
// lalu apply semua toggle via PlayerPrefs.SetInt / SetBool

struct GameControlConfiguration: Codable, Equatable {

    // ── Q-Slots: 22 generic feature booleans ──────────────────────────
    var q00: Bool = false
    var q01: Bool = false
    var q02: Bool = false
    var q03: Bool = false
    var q04: Bool = false
    var q05: Bool = false
    var q06: Bool = false
    var q07: Bool = false
    var q08: Bool = false
    var q09: Bool = false
    var q10: Bool = false
    var q11: Bool = false
    var q12: Bool = false
    var q13: Bool = false
    var q14: Bool = false
    var q15: Bool = false
    var q16: Bool = false
    var q17: Bool = false
    var q18: Bool = false
    var q19: Bool = false
    var q20: Bool = false
    var q21: Bool = false

    // ── ESP suite ─────────────────────────────────────────────────────
    var espon:  Bool = false   // ESP master toggle
    var espm:   Bool = false   // minimap ESP
    var espcv:  Bool = false   // canvas/visual layer
    var ebox:   Bool = false   // enemy box
    var ehead:  Bool = false   // head marker
    var ehp:    Bool = false   // HP bar
    var eline:  Bool = false   // line to enemy
    var ename:  Bool = false   // nickname
    var edist:  Bool = false   // distance display
    var edir:   Bool = false   // direction indicator
    var efull:  Bool = false   // full ESP mode
    var elag:   Bool = false   // lag compensation

    // ── XRay / Wallhack ───────────────────────────────────────────────
    var xray:   Bool = false   // xray on
    var xroff:  Bool = false   // xray off
    var xron:   Bool = false   // x-through on
    var xblk:   Bool = false   // xray block setting
    var xsig:   Bool = false   // xray signal
    var xrrv:   Bool = false   // xray reverse
    var xrad:   Int  = 50      // xray radius

    // ── Aim / Movement ────────────────────────────────────────────────
    var hot:    Bool = false   // hotkey trigger
    var moco:   Bool = false   // movement correction
    var swpf:   Bool = false   // sweep path filter
    var lhok:   Bool = false   // lock heading
    var lhx:    Int  = 0       // lock heading X axis
    var lhy:    Int  = 0       // lock heading Y axis
    var lhz:    Int  = 0       // lock heading Z axis
    var camid:  Int  = 0       // camera ID

    enum CodingKeys: String, CodingKey {
        case q00 = "__q00"; case q01 = "__q01"; case q02 = "__q02"
        case q03 = "__q03"; case q04 = "__q04"; case q05 = "__q05"
        case q06 = "__q06"; case q07 = "__q07"; case q08 = "__q08"
        case q09 = "__q09"; case q10 = "__q10"; case q11 = "__q11"
        case q12 = "__q12"; case q13 = "__q13"; case q14 = "__q14"
        case q15 = "__q15"; case q16 = "__q16"; case q17 = "__q17"
        case q18 = "__q18"; case q19 = "__q19"; case q20 = "__q20"
        case q21 = "__q21"
        case espon = "__espon"; case espm = "__espm"; case espcv = "__espcv"
        case ebox = "__ebox";   case ehead = "__ehead"; case ehp = "__ehp"
        case eline = "__eline"; case ename = "__ename"; case edist = "__edist"
        case edir = "__edir";   case efull = "__efull"; case elag = "__elag"
        case xray = "__xray";   case xroff = "__xroff"; case xron = "__xron"
        case xblk = "__xblk";   case xsig = "__xsig";   case xrrv = "__xrrv"
        case xrad = "__xrad"
        case hot = "__hot";     case moco = "__moco";   case swpf = "__swpf"
        case lhok = "__lhok";   case lhx = "__lhx";     case lhy = "__lhy"
        case lhz = "__lhz";     case camid = "__camid"
    }

    func toJSONData() throws -> Data {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try enc.encode(self)
    }
}

// ── Slot descriptors (UI labels for q00..q21) ──────────────────────────
struct GameFeatureSlot: Identifiable {
    let id: Int
    let label: String
    let icon:  String
}

extension GameControlConfiguration {
    // Tukar label ikut game kau
    static let slots: [GameFeatureSlot] = (0..<22).map {
        GameFeatureSlot(id: $0,
                        label: String(format: "Feature %02d", $0),
                        icon: "bolt.fill")
    }
}
