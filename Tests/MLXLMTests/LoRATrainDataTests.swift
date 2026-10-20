// Copyright © 2026 Apple Inc.

import Foundation
import MLX
import MLXLLM
import MLXNN
import MLXOptimizers
import MLXScriptedLM
import Testing

struct LoRATrainDataTests {

    /// Throws from `train` before any training step, so the model and loss are never used.
    static func train(_ train: [String], validate: [String]) throws {
        let model = Linear(1, 1, bias: false)
        try LoRATrain.train(
            model: model, train: train, validate: validate,
            optimizer: SGD(learningRate: 0.01),
            loss: { model, _, _, _ in
                let prediction = (model as! Linear)(MLXArray.ones([1, 1]))
                return ((prediction * prediction).mean(), MLXArray(1))
            },
            tokenizer: PseudoWordTokenizer(),
            parameters: .init(batchSize: 1, iterations: 1, validationBatches: 1),
            progress: { _ in .more })
    }

    @Test func `a one-token training sample throws with its index`() {
        #expect(throws: LoRATrainError.sampleTooShort(kind: .train, index: 1, tokenCount: 1)) {
            try Self.train(["two words", "one", "three more words"], validate: ["fine here"])
        }
    }

    @Test func `a short validation sample throws`() {
        #expect(throws: LoRATrainError.sampleTooShort(kind: .validate, index: 0, tokenCount: 0)) {
            try Self.train(["two words"], validate: [""])
        }
    }

    @Test func `samples of two or more tokens train`() throws {
        try Self.train(["two words", "three more words"], validate: ["fine here"])
    }

    #if os(macOS)
    /// `evaluate` skips `checkSamples`, so a short sample reaches the precondition in `LoRABatchIterator`.
    @Test func `evaluate stops at the precondition for a short sample`() async throws {
        let result = await #expect(
            processExitsWith: .failure, observing: [\.standardErrorContent]
        ) {
            _ = LoRATrain.evaluate(
                model: Linear(1, 1, bias: false), dataset: ["one"],
                loss: { _, _, _, _ in (MLXArray(0.0), MLXArray(1)) },
                tokenizer: PseudoWordTokenizer(), batchSize: 1, batchCount: 1)
        }
        let standardError = String(
            decoding: try #require(result).standardErrorContent, as: UTF8.self)
        #expect(standardError.contains("LoRA batch has no sample of 2 or more tokens"))
    }
    #endif

    @Test func `the error names the dataset and sample`() {
        let error = LoRATrainError.sampleTooShort(kind: .train, index: 3, tokenCount: 1)
        #expect(error.localizedDescription.contains("train sample 3"))
    }
}
