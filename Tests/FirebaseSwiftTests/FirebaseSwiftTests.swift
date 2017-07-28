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

    var url: String!
    var key: String!
    var fb: Firebase!

    let fakeUser = ["id": "123abc"]
    let patchValue = ["id": "xyz"]


    override func setUp() {
        super.setUp()
        let dict = ProcessInfo.processInfo.environment
        print("dict \(dict)")
        url = dict["fb_url"]
        key = dict["fb_secret"]
        fb = Firebase(baseURL: url, auth: key)
        fb.delete(path: "")
    }

    override func tearDown() {
        super.tearDown()
        fb.delete(path: "")
    }

    func testPostSync() {
        let result = fb.post(path: "users", value: fakeUser)
        processPostOrPutResponse(result)
    }

    func testPostAsync() {
        let postExpectation = self.expectation(description: "post")
        fb.post(path: "users", value: fakeUser) { result in
            postExpectation.fulfill()
            self.processPostOrPutResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Post Timed Out")
        }
    }

    func testGetSync() {
        let result = fb.post(path: "users", value: fakeUser)
        let id = processPostOrPutResponse(result)
        processGetResponse(fb.get(path: "users/" + id!))
    }

    func testGetAsync() {
        let result = fb.post(path: "users", value: fakeUser)
        let id = processPostOrPutResponse(result)
        let getExpectation = self.expectation(description: "get")
        self.fb.get(path: "users/" + id!) { result in
            getExpectation.fulfill()
            self.processGetResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Get Timed Out")
        }
    }

    func testPutSync() {
        let result = fb.post(path: "users", value: fakeUser)
        XCTAssertNotNil(result)
        let id = result?["name"] as? String
        XCTAssertNotNil(id)
    }

    func testPutAsync() {
        let putExpectation = self.expectation(description: "put")
        fb.post(path: "users", value: fakeUser) { result in
            putExpectation.fulfill()
            self.processPostOrPutResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Put Timed Out")
        }
    }

    func testPatchSync() {
        let result = fb.patch(path: "users", value: patchValue)
        processPatchResponse(result)
    }

    func testPatchAsync() {
        let patchExpectation = self.expectation(description: "patch")
        fb.patch(path: "users", value: patchValue) { result in
            patchExpectation.fulfill()
            self.processPatchResponse(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Patch Timed Out")
        }
    }

    func testDeleteSync() {
        let result = fb.post(path: "users", value: fakeUser)
        processPostOrPutResponse(result)
        let deleteResult = fb.delete(path: "users/" + name!)
        XCTAssertNil(deleteResult)
    }


    func testDeleteAsync() {
        let result = fb.post(path: "users", value: fakeUser)
        processPostOrPutResponse(result)
        let deleteExpectation = self.expectation(description: "delete")
        fb.delete(path: "users/" + name!) { result in
            deleteExpectation.fulfill()
            XCTAssertNil(result)
        }
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Post/Delete Timed Out")
        }
    }

    @discardableResult
    func processPostOrPutResponse(_ result: [String: AnyObject]?)->String? {
        XCTAssertNotNil(result)
        let id = result?["name"] as? String
        XCTAssertNotNil(id)
        return id
    }

    func processGetResponse(_ result: Any?) {
        let getResultID = result as? [String: String]
        XCTAssertNotNil(getResultID)
        XCTAssertEqual(getResultID!, self.fakeUser)
    }

    func processPatchResponse(_ result: [String: AnyObject]?) {
        let patchResult = result as? [String: String]
        XCTAssertNotNil(patchResult)
        XCTAssertEqual(patchValue, patchResult!)
    }

}

