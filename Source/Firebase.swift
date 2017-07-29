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

/// This class models an object that can send requests to Firebase, such as POST, GET PATCH and DELETE.
public final class Firebase {

    /// Database auth token
    public var auth: String?

    /// Base URL (e.g. http://myapp.firebaseio.com)
    public let baseURL: String

    /// Timeout of http operations
    public var timeout: Double = 30.0 // seconds

    private let headers = ["Accept": "application/json"]

    /// Constructor
    ///
    /// - Parameters:
    ///   - baseURL: Base URL (e.g. http://myapp.firebaseio.com)
    ///   - auth: Database auth token
    public init(baseURL: String = "", auth: String? = nil) {
        self.auth = auth

        var url = baseURL
        if url.characters.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url
    }

    /// Performs a synchronous PUT at base url plus given path.
    ///
    /// - Parameters:
    ///   - path: path to append to base url
    ///   - value: data to set
    /// - Returns: value of set data if successful
    public func setValue(path: String, value: Any) -> [String: AnyObject]? {
        return put(path: path, value:  value)
    }

    /// Performs an asynchronous PUT at base url plus given path.
    ///
    /// - Parameters:
    ///   - path: path to append to base url.
    ///   - value: data to set
    ///   - asyncCompletion: called on completion with the value of set data if successful.
    public func setValue(path: String,
                         value: Any,
                         asyncCompletion: @escaping ([String: AnyObject]?) -> Void) {
        put(path: path, value:  value, asyncCompletion: asyncCompletion)
    }

    /// Performs a synchronous POST at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to post
    /// - Returns: value of posted data if successful
    public func post(path: String, value: Any) -> [String: AnyObject]? {
        return write(value: value, path: path, method: .post, complete: nil)
    }

    /// Performs an asynchronous POST at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to post
    ///   - asyncCompletion: called on completion with the value of posted data if successful.
    public func post(path: String,
                     value: Any,
                     asyncCompletion: @escaping ([String: AnyObject]?) -> Void) {
        write(value: value, path: path, method: .post, complete: asyncCompletion)
    }

    /// Performs an synchronous PUT at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to put
    /// - Returns: Value of put data if successful
    public func put(path: String, value: Any) -> [String: AnyObject]? {
        return write(value: value, path: path, method: .put, complete: nil)
    }

    /// Performs an asynchronous PUT at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to put
    ///   - asyncCompletion: called on completion with the value of put data if successful.
    public func put(path: String,
                    value: Any,
                    asyncCompletion: @escaping ([String: AnyObject]?) -> Void) {
        write(value: value, path: path, method: .put, complete: asyncCompletion)
    }

    /// Performs a synchronous PATCH at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to patch
    /// - Returns: value of patched data if successful
    public func patch(path: String, value: Any) -> [String: AnyObject]? {
        return write(value: value, path: path, method: .patch, complete: nil)
    }

    /// Performs an asynchronous PATCH at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to patch
    ///   - asyncCompletion: called on completion with the value of patched data if successful.
    public func patch(path: String,
                      value: Any,
                      asyncCompletion: @escaping ([String: AnyObject]?) -> Void) {
        write(value: value, path: path, method: .patch, complete: asyncCompletion)
    }

    /// Performs a synchronous DELETE at given path from the base url.
    ///
    /// - Parameter path: path to append to the base url
    public func delete(path: String) {
        let url = completeURLWithPath(path: path)
        _ = Method.delete.justMethod(url, [:], [:], nil, headers, [:], nil, [:],
                                     false, timeout, nil, nil, nil, nil)
    }

    /// Performs an asynchronous DELETE at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - asyncCompletion: called on completion
    public func delete(path: String,
                       asyncCompletion: @escaping () -> Void) {
        let url = completeURLWithPath(path: path)
        _ = Method.delete.justMethod(url, [:], [:], nil, headers, [:], nil, [:],
                                     false, timeout, nil, nil, nil) { _ in
                                        asyncCompletion()
        }
    }

    /// Performs a synchronous GET at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    /// - Returns: resulting data if successful
    public func get(path: String) -> Any? {
        return get(path: path, complete: nil)
    }

    /// Performs an asynchronous GET at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - asyncCompletion: called on completion with the resulting data if successful.
    public func get(path: String,
                    asyncCompletion: @escaping ((Any?) -> Void)) {
        get(path: path, complete: asyncCompletion)
    }

    @discardableResult
    private func get(path: String, complete: ((Any?) -> Void)?) -> Any? {

        let url = completeURLWithPath(path: path)
        let completionHandler = createCompletionHandler(method: .get, callback: complete)

        let httpResult = Method.get.justMethod(url, [:], [:], nil, headers, [:], nil, [:],
                                               false, timeout, nil, nil, nil, completionHandler)

        guard complete == nil else { return nil }
        return process(httpResult: httpResult, method: .get)
    }

    @discardableResult
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
