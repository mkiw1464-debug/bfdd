import SwiftUI

struct GameControllerView: View {
    @EnvironmentObject private var svc: GameControlService
    @Environment(\.appLanguage) private var language

    var body: some View {
        NavigationStack {
            List {
                // ── Bridge status ──────────────────────────────────────
                Section {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(svc.bridge.isRunning ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(svc.bridge.isRunning ? "Proxy :8080 Active" : "Proxy Offline")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(svc.bridge.isRunning ? Color.green : Color.red)
                        Spacer()
                        Text(svc.bridge.statusLine)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } header: { Text("Bridge") }

                // ── ESP ───────────────────────────────────────────────
                Section("ESP") {
                    Toggle("ESP On",        isOn: $svc.config.espon)
                    Toggle("Minimap",       isOn: $svc.config.espm)
                    Toggle("Canvas Layer",  isOn: $svc.config.espcv)
                    Toggle("Enemy Box",     isOn: $svc.config.ebox)
                    Toggle("Head Marker",   isOn: $svc.config.ehead)
                    Toggle("HP Bar",        isOn: $svc.config.ehp)
                    Toggle("Line to Enemy", isOn: $svc.config.eline)
                    Toggle("Nickname",      isOn: $svc.config.ename)
                    Toggle("Distance",      isOn: $svc.config.edist)
                    Toggle("Direction",     isOn: $svc.config.edir)
                    Toggle("Full ESP",      isOn: $svc.config.efull)
                    Toggle("Lag Comp",      isOn: $svc.config.elag)
                }

                // ── XRay ──────────────────────────────────────────────
                Section("XRay / Wallhack") {
                    Toggle("XRay",         isOn: $svc.config.xray)
                    Toggle("X-Through",    isOn: $svc.config.xron)
                    Toggle("XRay Reverse", isOn: $svc.config.xrrv)
                    Toggle("XRay Signal",  isOn: $svc.config.xsig)
                    Toggle("XRay Block",   isOn: $svc.config.xblk)
                    HStack {
                        Text("Radius")
                        Spacer()
                        Text("\(svc.config.xrad)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(
                        value: Binding(
                            get: { Double(svc.config.xrad) },
                            set: { svc.config.xrad = Int($0) }
                        ),
                        in: 0...200, step: 1
                    )
                }

                // ── Aim / Movement ────────────────────────────────────
                Section("Aim / Movement") {
                    Toggle("Hotkey",          isOn: $svc.config.hot)
                    Toggle("Move Correction", isOn: $svc.config.moco)
                    Toggle("Sweep Filter",    isOn: $svc.config.swpf)
                    Toggle("Lock Heading",    isOn: $svc.config.lhok)
                }

                // ── Feature Slots Q00–Q21 ─────────────────────────────
                Section("Feature Slots (Q00–Q21)") {
                    ForEach(GameControlConfiguration.slots) { slot in
                        SlotToggleRow(index: slot.id, label: slot.label)
                            .environmentObject(svc)
                    }
                }

                // ── Reset ─────────────────────────────────────────────
                Section {
                    Button(role: .destructive) {
                        svc.resetAll()
                    } label: {
                        Label("Reset All", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Controller")
            .navigationBarTitleDisplayMode(.large)
            .tint(AppTheme.accent)
        }
    }
}

// Separate view per slot so binding is owned cleanly inside the view
private struct SlotToggleRow: View {
    @EnvironmentObject var svc: GameControlService
    let index: Int
    let label: String

    var body: some View {
        Toggle(label, isOn: Binding(
            get: { svc.slotGet(index) },
            set: { svc.slotSet(index, $0) }
        ))
    }
}
