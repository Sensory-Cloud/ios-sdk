//
//  TranscriptAggregator.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 7/25/22.
//

import Foundation

/// A structure that aggregates and stores transcription responses
///
/// This class can maintain the full transcript returned from the server's windowed response
public class TranscriptAggregator {
    private let filler = Sensory_Api_V1_Audio_TranscribeWord()
    private var wordList: [Sensory_Api_V1_Audio_TranscribeWord] = []

    /// Returns a new transcript aggregator
    public init() {
        return
    }

    /// Processes a single sliding-window response from the server
    ///
    /// - Parameter response: The current word list response from the server
    public func processResponse(_ response: Sensory_Api_V1_Audio_TranscribeWordResponse) throws {
        if response.words.isEmpty {
            return
        }

        // Expand the internal word list if needed
        let responseSize = Int(response.lastWordIndex) + 1
        if responseSize > wordList.count {
            wordList.reserveCapacity(responseSize)
            wordList.append(contentsOf: repeatElement(filler, count: responseSize - wordList.count))
        }

        // Copy over the words in the response to the internal word list
        for word in response.words {
            if word.wordIndex >= wordList.count {
                throw AggregatorError.outOfBounds
            }
            wordList[Int(word.wordIndex)] = word
        }

        // Shrink the internal word list if needed
        if responseSize < wordList.count {
            wordList.removeLast(wordList.count - responseSize)
        }
    }

    /// Returns the current raw transcript and associated metadata
    ///
    /// - Returns: The current transcript
    public func getWordList() -> [Sensory_Api_V1_Audio_TranscribeWord] {
        return wordList
    }

    /// The full transcript as computed from the current word list
    /// - Parameter delimiter: delimiter character(s) to put between transcribed words. Defaults to a single space " ". Pass in an empty string to use no delimiter
    /// - Returns: The full transcript as a string
    public func getTranscript(delimiter: String = " ") -> String {
        // Grab all the raw words and join w/ spaces
        return wordList.map { trim($0.word) }.joined(separator: delimiter)
    }

    private func trim(_ str: String) -> String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Possible errors that may occur during transcript aggregation
public enum AggregatorError: Error {
    /// A transcribed word in the response has an index greater than `response.lastWordIndex`
    case outOfBounds
}

extension AggregatorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .outOfBounds:
            return "Response contained a word with an out of bounds index"
        }
    }
}
