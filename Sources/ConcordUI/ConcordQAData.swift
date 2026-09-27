//
//  ConcordQAData.swift
//  ConcordUI
//
//  Reusable question-and-answer data.
//

import Foundation

/// A reusable question, its answer, and optional references for further reading.
public struct ConcordQAData: Codable, Sendable, Equatable {
    public let question: String
    public let answer: String
    public let access: [ConcordAccessData]

    public init(
        question: String,
        answer: String,
        access: [ConcordAccessData] = []
    ) {
        precondition(!question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Question must not be empty.")
        precondition(!answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Answer must not be empty.")
        self.question = question
        self.answer = answer
        self.access = access
    }

    private enum CodingKeys: String, CodingKey {
        case question
        case answer
        case access
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let question = try container.decode(String.self, forKey: .question)
        let answer = try container.decode(String.self, forKey: .answer)
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .question,
                in: container,
                debugDescription: "Question must not be empty."
            )
        }
        guard !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .answer,
                in: container,
                debugDescription: "Answer must not be empty."
            )
        }
        self.question = question
        self.answer = answer
        self.access = try container.decodeIfPresent(
            [ConcordAccessData].self,
            forKey: .access
        ) ?? []
    }

    /// Creates one question-and-answer item from a JSON text string.
    public init(json: String) throws {
        self = try JSONDecoder().decode(Self.self, from: Data(json.utf8))
    }
}

/// A titled collection of reusable question-and-answer items.
public struct ConcordQAListData: Codable, Sendable, Equatable {
    public let title: String
    public let questions: [ConcordQAData]

    public init(
        title: String = "",
        questions: [ConcordQAData]
    ) {
        self.title = title
        self.questions = questions
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case questions
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.questions = try container.decodeIfPresent(
            [ConcordQAData].self,
            forKey: .questions
        ) ?? []
    }

    /// Creates a question-and-answer list from a JSON text string.
    public init(json: String) throws {
        self = try JSONDecoder().decode(Self.self, from: Data(json.utf8))
    }
}


/// Complete data used by the standard FAQ feature.
///
/// Wrapping the section array gives FAQ JSON one clear document root.
public struct ConcordFAQFeatureData: Codable, Sendable, Equatable {
    public let sections: [ConcordQAListData]

    public init(sections: [ConcordQAListData] = []) {
        self.sections = sections
    }

    /// Creates complete FAQ feature data from a JSON text string.
    public init(json: String) throws {
        self = try JSONDecoder().decode(Self.self, from: Data(json.utf8))
    }
}
