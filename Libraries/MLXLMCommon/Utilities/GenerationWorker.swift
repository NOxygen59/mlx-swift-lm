// Copyright © 2026 Apple Inc.

import Dispatch

/// Runs one generation's blocking work outside Swift's cooperative pool.
actor GenerationWorker {
    // ipad-ios16 : `DispatchSerialQueue` est iOS 17+ ; exécuteur série maison sur une file Dispatch classique.
    private nonisolated let executor = QueueSerialExecutor(label: "ml-explore.mlx-swift-lm.generation")

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    // Keep the body synchronous so all evaluation and cleanup stay on this executor.
    func run<R: Sendable>(_ body: @Sendable () -> R) -> R {
        body()
    }
}

/// ipad-ios16 : exécuteur série sur `DispatchQueue` (remplace `DispatchSerialQueue`, iOS 17+).
final class QueueSerialExecutor: SerialExecutor, @unchecked Sendable {
    private let queue: DispatchQueue

    init(label: String) { queue = DispatchQueue(label: label) }

    func enqueue(_ job: UnownedJob) {
        queue.async { job.runSynchronously(on: self.asUnownedSerialExecutor()) }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}
