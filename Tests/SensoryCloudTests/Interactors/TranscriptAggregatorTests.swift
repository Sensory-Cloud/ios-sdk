//
//  TranscriptAggregatorTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 7/25/22.
//

import XCTest
@testable import SensoryCloud

class TranscriptAggregatorTests: XCTestCase {

    var aggregator = TranscriptAggregator()

    override func setUpWithError() throws {
        aggregator = TranscriptAggregator()
    }

    func testEmptyResponse() throws {
        try aggregator.processResponse(Sensory_Api_V1_Audio_TranscribeWordResponse())
        XCTAssertTrue(aggregator.getWordList().isEmpty, "Empty response should result in an empty transcript")
        XCTAssertEqual(aggregator.getTranscript(), "")
    }

    func testSingleResponse() throws {
        var foo = Sensory_Api_V1_Audio_TranscribeWord()
        foo.word = "foo"
        foo.wordIndex = 0
        var bar = Sensory_Api_V1_Audio_TranscribeWord()
        bar.word = " bar "
        bar.wordIndex = 1
        let response = makeWordResponse(words: [foo, bar])

        try aggregator.processResponse(response)
        XCTAssertEqual(aggregator.getWordList().count, 2)
        XCTAssertEqual(aggregator.getTranscript(), "foo bar")
        XCTAssertEqual(aggregator.getTranscript(delimiter: ""), "foobar")
        XCTAssertEqual(aggregator.getTranscript(delimiter: "..."), "foo...bar")
    }

    func testMultipleResponses() throws {
        var foo = Sensory_Api_V1_Audio_TranscribeWord()
        foo.word = "foo"
        foo.wordIndex = 0
        var bar = Sensory_Api_V1_Audio_TranscribeWord()
        bar.word = " bar "
        bar.wordIndex = 1
        var response = makeWordResponse(words: [foo, bar])
        try aggregator.processResponse(response)

        // A response that adds a new word
        var baz = Sensory_Api_V1_Audio_TranscribeWord()
        baz.word = "baz"
        baz.wordIndex = 2
        response = makeWordResponse(words: [bar, baz])

        try aggregator.processResponse(response)
        XCTAssertEqual(aggregator.getWordList().count, 3)
        XCTAssertEqual(aggregator.getTranscript(), "foo bar baz")

        // A response that replaces a word
        var food = Sensory_Api_V1_Audio_TranscribeWord()
        food.word = "food"
        food.wordIndex = 0
        response = makeWordResponse(words: [food])
        response.lastWordIndex = 2

        try aggregator.processResponse(response)
        XCTAssertEqual(aggregator.getWordList().count, 3)
        XCTAssertEqual(aggregator.getTranscript(), "food bar baz")

        // A response that removes a word
        response = makeWordResponse(words: [foo])

        try aggregator.processResponse(response)
        XCTAssertEqual(aggregator.getWordList().count, 1)
        XCTAssertEqual(aggregator.getTranscript(), "foo")
    }

    func testInvalidResponse() throws {
        var foo = Sensory_Api_V1_Audio_TranscribeWord()
        foo.word = "foo"
        foo.wordIndex = 0
        var bar = Sensory_Api_V1_Audio_TranscribeWord()
        bar.word = "bar"
        bar.wordIndex = 1

        // bar's word index is > the response's maxWordIndex
        var response = makeWordResponse(words: [foo])
        response.words.append(bar)

        XCTAssertThrowsError(try aggregator.processResponse(response))
    }

    // Helper func to make a valid transcribeWordResponse
    private func makeWordResponse(words: [Sensory_Api_V1_Audio_TranscribeWord]) -> Sensory_Api_V1_Audio_TranscribeWordResponse {
        var response = Sensory_Api_V1_Audio_TranscribeWordResponse()
        response.words = words
        response.lastWordIndex = words.reduce(0) {max($0, $1.wordIndex)}
        response.firstWordIndex = words.reduce(UInt64.max) {min($0, $1.wordIndex)}
        return response
    }
}
