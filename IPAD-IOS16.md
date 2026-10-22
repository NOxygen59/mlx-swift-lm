# mlx-swift-lm — branche `ipad-ios16`

> Vibecodé par Claude pour iPad Pro 12,9" M1 (iOS 16.6.1, TrollStore). Basé sur mlx-swift-lm **3.32.3** officiel.

| Fichier | Changement |
|---|---|
| `Package.swift` | `.iOS(.v16)` / `.tvOS(.v16)` ; trait `FoundationModelsIntegration` coupé par défaut (iOS 27+) ; dépend du fork `NOxygen59/mlx-swift` branche `ipad-ios16` (bfloat logiciel) |
| `Libraries/MLXLMCommon/Utilities/GenerationWorker.swift` | `DispatchSerialQueue` (iOS 17+) → `QueueSerialExecutor` maison sur `DispatchQueue` |

Compile : `xcodebuild -scheme MLXVLM -destination 'generic/platform=iOS Simulator' build`.
Non testé à l'exécution sur l'appareil au moment du rétroportage.
