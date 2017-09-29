//
//  Tests.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 7/26/17.
//
//

import Foundation
import XCTest

@testable import FirebaseSwift

class FirebaseTests: XCTestCase {

    static var allTests = [
        ("testPostSync", testPostSync),
        ("testPostAsync", testPostAsync),
        ("testGetSync", testGetSync),
        ("testGetSingleValue", testGetSingleValue),
        ("testGetAsync", testGetAsync),
        ("testPutSync", testPutSync),
        ("testPutAsync", testPutAsync),
        ("testPatchSync", testPatchSync),
        ("testPatchAsync", testPatchAsync),
        ("testDeleteSync", testDeleteSync),
        ("testDeleteAsync", testDeleteAsync),
        ("testGetAsync", testGetAsync),
        ]

    var url: String!
    var key: String!
    var firebase: Firebase!

    let fakeUser = ["id": "123abc", "name": "Bob"]
    let patchValue = ["id": "xyz"]

    override func setUp() {
        super.setUp()
        let dict = ProcessInfo.processInfo.environment
        print("dict \(dict)")
        url = dict["fb_url"]
        key = dict["fb_token"]
        firebase = Firebase(baseURL: url, accessToken: key)
        firebase.delete(path: "")
    }

    override func tearDown() {
        super.tearDown()
        firebase.delete(path: "")
    }

    func testPostSync() {
        let result = firebase.post(path: "users", value: fakeUser)
        processPostOrPutResponse(result)
    }

    func testPostAsync() {
        let postExpectation = self.expectation(description: "post")
        firebase.post(path: "users", value: fakeUser) { result in
            postExpectation.fulfill()
            self.processPostOrPutResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Post Timed Out")
        }
    }

    func testGetSync() {
        let result = firebase.post(path: "users", value: fakeUser)
        if let id = processPostOrPutResponse(result) {
            processGetResponse(firebase.get(path: "users/" + id))
        }
    }

    func testGetSingleValue() {
        let result = firebase.post(path: "users", value: fakeUser)
        if let id = processPostOrPutResponse(result) {
            let getResult = firebase.get(path: "users/" + id + "/name") as? String
            XCTAssertNotNil(getResult)
            XCTAssertEqual(getResult, "Bob")
        }
    }

    func testGetAsync() {
        let result = firebase.post(path: "users", value: fakeUser)
        if let id = processPostOrPutResponse(result) {
            let getExpectation = self.expectation(description: "get")
            self.firebase.get(path: "users/" + id) { result in
                getExpectation.fulfill()
                self.processGetResponse(result)
            }
            self.waitForExpectations(timeout: 30) { error in
                XCTAssertNil(error, "Get Timed Out")
            }
        }
    }

    func testPutSync() {
        let result = firebase.post(path: "users", value: fakeUser)
        XCTAssertNotNil(result)
        let id = result?["name"] as? String
        XCTAssertNotNil(id)
    }

    func testPutAsync() {
        let putExpectation = self.expectation(description: "put")
        firebase.post(path: "users", value: fakeUser) { result in
            putExpectation.fulfill()
            self.processPostOrPutResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Put Timed Out")
        }
    }

    func testPatchSync() {
        let result = firebase.patch(path: "users", value: patchValue)
        processPatchResponse(result)
    }

    func testPatchAsync() {
        let patchExpectation = self.expectation(description: "patch")
        firebase.patch(path: "users", value: patchValue) { result in
            patchExpectation.fulfill()
            self.processPatchResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Patch Timed Out")
        }
    }

    func testDeleteSync() {
        let result = firebase.post(path: "users", value: fakeUser)
        processPostOrPutResponse(result)
        firebase.delete(path: "users")
        let getResult = firebase.get(path: "users") as? [String: AnyObject]
        XCTAssertNil(getResult)
    }

    func testDeleteAsync() {
        let result = firebase.post(path: "users", value: fakeUser)
        processPostOrPutResponse(result)
        let deleteExpectation = self.expectation(description: "delete")
        firebase.delete(path: "users") {
            deleteExpectation.fulfill()
            self.firebase.get(path: "users") {
                XCTAssertNil($0 as? [String: AnyObject])
            }
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Post/Delete Timed Out")
        }
    }

    @discardableResult
    private func processPostOrPutResponse(_ result: [String: AnyObject]?) -> String? {
        XCTAssertNotNil(result)
        let id = result?["name"] as? String
        XCTAssertNotNil(id)
        return id
    }

    func processGetResponse(_ result: Any?) {
        let getResultID = result as? [String: String]
        XCTAssertNotNil(getResultID)
        if let getResultID = getResultID {
            XCTAssertEqual(getResultID, self.fakeUser)
        }
    }

    func processPatchResponse(_ result: [String: AnyObject]?) {
        let patchResult = result as? [String: String]
        XCTAssertNotNil(patchResult)
        if let patchResult = patchResult {
            XCTAssertEqual(patchValue, patchResult)
        }
    }

}
