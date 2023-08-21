// 
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import SDNSDK

private enum Constants {
    static let roomId = "someRoomId"
    static let repliedEventId = "repliedEventId"
    static let repliedEventBody = "Test message"
    static let repliedEventEditedBody = "Edited message"
    static let repliedEventNewContentBody = "New content"
    static let replyBody = "> <@alice:sdn.org> Test message\n\nReply"
    static let replyFormattedBodyWithItalic = "<mx-reply><blockquote><a href=\"https://sdn.to/#/someRoomId/repliedEventId\">In reply to</a> <a href=\"https://sdn.to/#/alice\">alice</a><br>Test message</blockquote></mx-reply><em>Reply</em>"
    static let expectedHTML = "<mx-reply><blockquote><a href=\"https://sdn.to/#/someRoomId/repliedEventId\">In reply to</a> <a href=\"https://sdn.to/#/alice\">alice</a><br>Test message</blockquote></mx-reply>Reply"
    static let expectedEditedHTML = "<mx-reply><blockquote><a href=\"https://sdn.to/#/someRoomId/repliedEventId\">In reply to</a> <a href=\"https://sdn.to/#/alice\">alice</a><br>Edited message</blockquote></mx-reply>Reply"
    static let expectedEditedHTMLWithNewContent = "<mx-reply><blockquote><a href=\"https://sdn.to/#/someRoomId/repliedEventId\">In reply to</a> <a href=\"https://sdn.to/#/alice\">alice</a><br>New content</blockquote></mx-reply>Reply"
    static let expectedEditedHTMLWithParsedItalic = "<mx-reply><blockquote><a href=\"https://sdn.to/#/someRoomId/repliedEventId\">In reply to</a> <a href=\"https://sdn.to/#/alice\">alice</a><br>New content</blockquote></mx-reply><em>Reply</em>"
    static let expectedReplyToPollEndedEvent = "<mx-reply><blockquote><a href=\"https://sdn.to/#/someRoomId/repliedEventId\">In reply to</a> <a href=\"https://sdn.to/#/alice\">alice</a><br>Ended poll</blockquote></mx-reply>Reply"
}

class MXKEventFormatterSwiftTests: XCTestCase {
    func testBuildHTMLString() {
        let formatter = MXKEventFormatter()
        let repliedEvent: MXEvent = .mockEvent(eventType: kMXEventTypeStringRoomMessage)
        let event = MXEvent()
        func buildHTML() -> String? { return formatter.buildHTMLString(for: event, inReplyTo: repliedEvent) }

        event.sender = "bob"
        event.wireType = kMXEventTypeStringRoomMessage
        event.wireContent = [
            kMXMessageTypeKey: kMXMessageTypeText,
            kMXMessageBodyKey: Constants.replyBody,
            kMXEventRelationRelatesToKey: [kMXEventContentRelatesToKeyInReplyTo: ["event_id": Constants.repliedEventId]]
        ]

        // Default render.
        XCTAssertEqual(buildHTML(), Constants.expectedHTML)

        // Render after edition.
        repliedEvent.wireContent[kMXMessageBodyKey] = Constants.repliedEventEditedBody
        XCTAssertEqual(buildHTML(), Constants.expectedEditedHTML)

        // m.new_content has prioritiy over base content.
        repliedEvent.wireContent[kMXMessageContentKeyNewContent] = [kMXMessageBodyKey: Constants.repliedEventNewContentBody]
        XCTAssertEqual(buildHTML(), Constants.expectedEditedHTMLWithNewContent)

        // If reply's formatted_body is available it's used to construct a brand new HTML.
        event.wireContent["formatted_body"] = Constants.replyFormattedBodyWithItalic
        XCTAssertEqual(buildHTML(), Constants.expectedEditedHTMLWithParsedItalic)

        // If content from replied event is missing. Reply can't be constructed (client will use fallback).
        repliedEvent.wireContent[kMXMessageBodyKey] = nil
        repliedEvent.wireContent[kMXMessageContentKeyNewContent] = nil
        XCTAssertNil(buildHTML())
    }
    
    func testBuildHTMLStringWithPollEndedReply() {
        let formatter = MXKEventFormatter()
        let repliedEvent: MXEvent = .mockEvent(eventType: kMXEventTypeStringPollEnd, body: nil)
        
        let event = MXEvent()
        event.sender = "bob"
        event.wireType = kMXEventTypeStringRoomMessage
        event.wireContent = [
            kMXMessageTypeKey: kMXMessageTypeText,
            kMXMessageBodyKey: Constants.replyBody,
            kMXEventRelationRelatesToKey: [kMXEventContentRelatesToKeyInReplyTo: ["event_id": Constants.repliedEventId]]
        ]
        
        let formattedText = formatter.buildHTMLString(for: event, inReplyTo: repliedEvent)
        
        XCTAssertEqual(formattedText, Constants.expectedReplyToPollEndedEvent)
    }
}

private extension MXEvent {
    static func mockEvent(eventType: String, body: String? = Constants.repliedEventBody) -> MXEvent {
        let repliedEvent = MXEvent()
        repliedEvent.sender = "alice"
        repliedEvent.roomId = Constants.roomId
        repliedEvent.eventId = Constants.repliedEventId
        repliedEvent.wireType = eventType
        repliedEvent.wireContent = [kMXMessageTypeKey: kMXMessageTypeText]
        
        if let body = body {
            repliedEvent.wireContent[kMXMessageBodyKey] = body
        }
        
        return repliedEvent
    }
}