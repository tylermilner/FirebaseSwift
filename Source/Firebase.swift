//
//  Firebase.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/15/16.
//
//

import Foundation
import Just

private enum Method: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"

    fileprivate var justMethod: JustSendRequestMethodType {
        switch self {
        case .delete:
            return Just.delete
        case .get:
            return Just.get
        case .patch:
            return Just.patch
        case .post:
            return Just.post
        case .put:
            return Just.put
        }
    }
}

// The type of all the Just package's methods (get, post, delete,...)
private typealias JustSendRequestMethodType =
    (URLComponentsConvertible, [String: Any], [String: Any],
    Any?, [String: String], [String: HTTPFile], (String, String)?,
    [String: String], Bool, Double?, String?, Data?,
    (TaskProgressHandler)?, ((HTTPResult) -> Void)?) -> HTTPResult

private typealias FBSCallback = (Any?) -> Void

public class Firebase {

    /// Auth token
    public var auth: String?

    /// Base URL (e.g. http://myapp.firebaseio.com)
    public let baseURL: String

    /// Timeout of http operations
    public let timeout: Double = 30.0 // seconds

    private let headers = ["Accept": "application/json"]

    /// Constructor
    ///
    /// - Parameters:
    ///   - baseURL: Base URL (e.g. http://myapp.firebaseio.com)
    ///   - auth: Auth token
    public init(baseURL: String = "", auth: String? = nil) {
        self.auth = auth

        var url = baseURL
        if url.characters.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url
    }

    /// Performs a PUT at base url plus given path
    ///
    /// - Parameters:
    ///   - path: path to append to base url
    ///   - value: value to set
    ///   - asyncCompletion: Causes the call to be asynchronous. Called on completion with the result.
    /// - Returns: resulting data IF a synchronous call
    public func setValue(path: String,
                         value: Any,
                         asyncCompletion: ((Any?) -> Void)? = nil) -> [String: AnyObject]? {
        return put(path: path, value:  value, asyncCompletion: asyncCompletion)
    }

    /// Performs a POST at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to post
    ///   - asyncCompletion: Causes the post to be asynchronous. Called on completion with the result.
    /// - Returns: resulting data IF a synchronous call
    public func post(path: String,
                     value: Any,
                     asyncCompletion: ((Any?) -> Void)? = nil) -> [String: AnyObject]? {
        return write(value: value, path: path, method: .post, complete: asyncCompletion)
    }

    /// Performs an asynchronous PUT at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to put
    ///   - asyncCompletion: Causes the put to be asynchronous. Called on completion with the result.
    ///   - Returns: resulting data IF a synchronous call
    public func put(path: String,
                    value: Any,
                    asyncCompletion: ((Any?) -> Void)? = nil) -> [String: AnyObject]? {
        return write(value: value, path: path, method: .put, complete: asyncCompletion)
    }

    /// Performs a PATCH at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to patch
    ///   - asyncCompletion: Causes the patch to be asynchronous. Called on completion with the result.
    /// - Returns: resulting data IF a synchronous call
    public func patch(path: String,
                      value: Any,
                      asyncCompletion: ((Any?) -> Void)? = nil) -> [String: AnyObject]? {
        return write(value: value, path: path, method: .patch, complete: asyncCompletion)
    }

    /// Performs a DELETE at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - asyncCompletion: Causes the delete to be asynchronous. Called on completion with the result.
    /// - Returns: deleted data IF a synchronous call
    public func delete(path: String,
                       asyncCompletion: ((Any?) -> Void)? = nil) -> [String: AnyObject]? {
        return delete(path: path, complete: asyncCompletion)
    }

    /// Performs an asynchronous GET at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - asyncCompletion: Causes the get to be asynchronous. Called on completion with the result.
    public func get(path: String,
                    asyncCompletion: ((Any?) -> Void)? = nil) -> Any? {
        return get(path: path, complete: asyncCompletion)
    }

    private func delete(path: String, complete: (([String: AnyObject]?) -> Void)?) -> [String: AnyObject]? {

        let url = completeURLWithPath(path: path)
        let completionHandler = createCompletionHandler(method: .delete, callback: complete)

        let result = Method.delete.justMethod(url, [:], [:], nil, headers, [:], nil, [:],
                                              false, timeout, nil, nil, nil, completionHandler)

        if let error = result.error {
            print("DELETE Error: \(error.localizedDescription)")
            return nil
        }

        do {
            if let jsonMap = try result.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print("DELETE Error: \(e.localizedDescription)")
        }

        guard complete == nil else { return nil }
        return process(httpResult: result, method: .delete)
    }

    private func get(path: String, complete: ((Any?) -> Void)?) -> Any? {

        let url = completeURLWithPath(path: path)
        let completionHandler = createCompletionHandler(method: .get, callback: complete)

        let httpResult = Method.get.justMethod(url, [:], [:], nil, headers, [:], nil, [:],
                                               false, timeout, nil, nil, nil, completionHandler)

        guard complete == nil else { return nil }
        return process(httpResult: httpResult, method: .get)
    }

    private func write(value: Any,
                       path: String,
                       method: Method,
                       complete: (([String: AnyObject]?) -> Void)? = nil) -> [String: AnyObject]? {

        let url = completeURLWithPath(path: path)
        let json: Any? = JSONSerialization.isValidJSONObject(value) ? value : [".value": value]

        let completionHandler = createCompletionHandler(method: method, callback: complete)
        let result = method.justMethod(url, [:], [:], json, headers, [:], nil, [:],
                                       false, timeout, nil, nil, nil, completionHandler)

        guard complete == nil else { return nil }
        return process(httpResult: result, method: method)
    }

    private func completeURLWithPath(path: String) -> String {
        var url = baseURL + path + ".json"
        if let auth = auth {
            url += "?auth=" + auth
        }
        return url
    }

    private func process(httpResult: HTTPResult, method: Method) -> [String: AnyObject]? {
        if let error = httpResult.error {
            print(method.rawValue + " Error: " + error.localizedDescription)
            return nil
        }

        do {
            if let jsonMap = try httpResult.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print(method.rawValue + " Error: " + e.localizedDescription)
        }
        return nil
    }

    private func createCompletionHandler(method: Method,
                                         callback: (([String: AnyObject]?) -> Void)?) -> ((HTTPResult) -> Void)? {
        if let callback = callback {
            let completionHandler: ((HTTPResult) -> Void)? = { result in
                callback(self.process(httpResult: result, method: method))
            }
            return completionHandler
        }
        return nil
    }
}
