import Foundation
import Network
import Combine

// MARK: - GameBridge
// NWListener port 8080.
// Serves GET /config → JSON-encoded GameControlConfiguration.
// Assembly-CSharp-patch.bytes dalam game GET ni masa boot.
// App guna UIBackgroundModes: audio → proxy survive waktu game foreground.

final class GameBridge: ObservableObject {

    @Published var isRunning: Bool = false
    @Published var statusLine: String = "Waiting…"

    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let queue = DispatchQueue(label: "com.3105.gamebridge", qos: .userInitiated)
    private var configData: Data = Data()

    // ── Start / Stop ──────────────────────────────────────────────────

    func start() {
        guard listener == nil else { return }
        do {
            listener = try NWListener(using: .tcp, on: 8080)
        } catch {
            status("init failed: \(error)")
            return
        }

        listener?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isRunning = true
                    self?.status(":8080 ready")
                case .failed(let e):
                    self?.isRunning = false
                    self?.status("failed: \(e)")
                    self?.restart()
                case .cancelled:
                    self?.isRunning = false
                default: break
                }
            }
        }

        listener?.newConnectionHandler = { [weak self] conn in
            self?.handle(conn)
        }

        listener?.start(queue: queue)
    }

    func stop() {
        listener?.cancel(); listener = nil
        connections.forEach { $0.cancel() }
        connections.removeAll()
        DispatchQueue.main.async { self.isRunning = false }
    }

    private func restart() {
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.start()
        }
    }

    func update(_ config: GameControlConfiguration) {
        guard let data = try? config.toJSONData() else { return }
        queue.async { self.configData = data }
    }

    // ── Connection ────────────────────────────────────────────────────

    private func handle(_ conn: NWConnection) {
        connections.append(conn)
        conn.stateUpdateHandler = { [weak self, weak conn] s in
            if case .failed = s, let c = conn {
                self?.connections.removeAll { $0 === c }
            }
        }
        conn.start(queue: queue)
        receive(conn)
    }

    private func receive(_ conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 4096) {
            [weak self] data, _, done, error in
            guard let self else { return }
            if let data, !data.isEmpty {
                let path = self.extractPath(data) ?? "/config"
                self.respond(conn, path: path)
                self.status("served \(path)")
            }
            if done || error != nil {
                conn.cancel()
                self.connections.removeAll { $0 === conn }
            }
        }
    }

    private func respond(_ conn: NWConnection, path: String) {
        let body = path.hasPrefix("/config") ? configData
            : Data("{\"error\":\"not found\"}".utf8)
        let header = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"
        var resp = Data(header.utf8); resp.append(body)
        conn.send(content: resp, completion: .idempotent)
    }

    private func extractPath(_ data: Data) -> String? {
        guard let line = String(data: data, encoding: .utf8)?
            .components(separatedBy: "\r\n").first else { return nil }
        let parts = line.components(separatedBy: " ")
        guard parts.count >= 2 else { return nil }
        return parts[1].components(separatedBy: "?").first
    }

    private func status(_ msg: String) {
        DispatchQueue.main.async { self.statusLine = msg }
        log("bridge: \(msg)")
    }
}
