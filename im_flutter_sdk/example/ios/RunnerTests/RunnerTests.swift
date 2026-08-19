import Flutter
import HyphenateChat
import im_flutter_sdk_ios
import UIKit
import XCTest

final class RunnerTests: XCTestCase {

  func testMessageFromJsonPreservesObservableSendSemantics() throws {
    let message = try XCTUnwrap(EMChatMessage.fromJson(textMessageFixture()))

    XCTAssertEqual(message.direction.rawValue, 0)
    XCTAssertEqual(message.chatType.rawValue, 2)
    XCTAssertEqual(message.status.rawValue, 1)
    XCTAssertEqual(message.from, "alice")
    XCTAssertEqual(message.to, "room-001")
    XCTAssertEqual(message.conversationId, "room-001")
    XCTAssertEqual(message.localTime, 1_700_000_000_000)
    XCTAssertTrue(message.deliverOnlineOnly)
    XCTAssertEqual(message.receiverList, ["bob", "carol"])
    XCTAssertEqual(message.priority.rawValue, 0)

    let body = try XCTUnwrap(message.body as? EMTextMessageBody)
    XCTAssertEqual(body.text, "hello")
    XCTAssertEqual(body.targetLanguages, ["zh-Hans", "en"])

    let attributes = try XCTUnwrap(message.ext as? [String: Any])
    XCTAssertEqual(attributes["trace"] as? String, "trace-001")
    XCTAssertEqual((attributes["retry"] as? NSNumber)?.intValue, 2)
    XCTAssertEqual((attributes["silent"] as? NSNumber)?.boolValue, true)
    XCTAssertEqual((attributes["score"] as? NSNumber)?.doubleValue, 1.5)
    XCTAssertTrue(attributes["meta"] is [String: Any])
    XCTAssertTrue(attributes["tags"] is [String])
  }

  func testMessageToJsonPreservesStructuredAttributesAndTargeting() throws {
    let message = try XCTUnwrap(EMChatMessage.fromJson(textMessageFixture()))

    let output = message.toJson()
    let attributes = try XCTUnwrap(output["attributes"] as? [String: Any])
    XCTAssertEqual((attributes["score"] as? NSNumber)?.doubleValue, 1.5)
    XCTAssertTrue(attributes["meta"] is [String: Any])
    XCTAssertTrue(attributes["tags"] is [String])
    XCTAssertEqual(output["deliverOnlineOnly"] as? Bool, true)
    XCTAssertEqual(output["receiverList"] as? [String], ["bob", "carol"])
  }

  private func textMessageFixture() -> [String: Any] {
    [
      "from": "alice",
      "to": "room-001",
      "body": [
        "type": 0,
        "content": "hello",
        "targetLanguages": ["zh-Hans", "en"],
      ],
      "attributes": [
        "trace": "trace-001",
        "retry": 2,
        "silent": true,
        "score": 1.5,
        "meta": [
          "source": "contract-test",
          "level": 3,
        ],
        "tags": ["a", "b"],
      ],
      "direction": 0,
      "hasRead": true,
      "hasReadAck": false,
      "hasDeliverAck": false,
      "needGroupAck": false,
      "msgId": "local-001",
      "convId": "room-001",
      "chatType": 2,
      "localTime": 1_700_000_000_000,
      "serverTime": 0,
      "status": 1,
      "isThread": false,
      "isContentReplaced": false,
      "chatroomMessagePriority": 0,
      "deliverOnlineOnly": true,
      "receiverList": ["bob", "carol"],
    ]
  }
}
