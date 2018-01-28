//
//  Firestore.swift
//  FirebaseSwift
//
//  Created by Tyler Milner on 1/22/18.
//

import Foundation
import Just

/// This class models an object that can send requests to a Firebase Cloud Firestore database, such as POST, GET PATCH and DELETE.
public final class Firestore {
    
    // MARK: - Properties
    
    /// Google OAuth2 access token
    public var accessToken: String?
    
    /// Base URL (e.g. https://firestore.googleapis.com/v1beta1/)
    private let baseURL: String
    
    /// The Firebase project identifier (e.g. project-3607d)
    private let projectId: String
    
    /// The Firestore database identifier (e.g. usually "(default)" for now)
    private let databaseId: String
    
    /// Timeout of http operations
    public var timeout: Double = 30.0 // seconds
    
    /// The default headers to send with every request
    private var headers: [String: String] {
        return ["Accept": "application/json",
                "Authorization": "Bearer \(accessToken ?? "")"]
    }
    
    // MARK: - Init
    
    /// Constructor
    ///
    /// - Parameters:
    ///   - baseURL: Base URL (e.g. https://firestore.googleapis.com/v1beta1/)
    ///   - auth: Database auth token
    public init(baseURL: String = "", accessToken: String? = nil, projectId: String = "", databaseId: String = "(default)") {
        self.accessToken = accessToken
        self.projectId = projectId
        self.databaseId = databaseId
        
        var url = baseURL
        if url.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url
    }
    
    // MARK: - Write
    
    /// Performs a synchronous PUT at base url plus given path.
    ///
    /// - Parameters:
    ///   - path: path to append to base url
    ///   - value: data to set
    /// - Returns: value of set data if successful
    public func setValue(path: String, value: Any) -> [String: Any]? {
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
                         asyncCompletion: @escaping ([String: Any]?) -> Void) {
        put(path: path, value:  value, asyncCompletion: asyncCompletion)
    }
    
    /// Performs a synchronous POST at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to post
    /// - Returns: value of posted data if successful
    public func post(path: String, value: Any) -> [String: Any]? {
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
                     asyncCompletion: @escaping ([String: Any]?) -> Void) {
        write(value: value, path: path, method: .post, complete: asyncCompletion)
    }
    
    /// Performs an synchronous PUT at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to put
    /// - Returns: Value of put data if successful
    public func put(path: String, value: Any) -> [String: Any]? {
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
                    asyncCompletion: @escaping ([String: Any]?) -> Void) {
        write(value: value, path: path, method: .put, complete: asyncCompletion)
    }
    
    // MARK: - Update
    
    /// Performs a synchronous PATCH at given path from the base url.
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: data to patch
    /// - Returns: value of patched data if successful
    public func patch(path: String, value: Any) -> [String: Any]? {
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
                      asyncCompletion: @escaping ([String: Any]?) -> Void) {
        write(value: value, path: path, method: .patch, complete: asyncCompletion)
    }
    
    // MARK: - Delete
    
    /// Performs a synchronous DELETE at given path from the base url.
    ///
    /// - Parameter path: path to append to the base url
    public func delete(path: String) {
        let url = completeURLWithPath(path: path)
        _ = HTTPMethod.delete.justRequest(url, [:], [:], nil, headers, [:], nil, [:],
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
        _ = HTTPMethod.delete.justRequest(url, [:], [:], nil, headers, [:], nil, [:],
                                          false, timeout, nil, nil, nil) { _ in
                                            asyncCompletion()
        }
    }
    
    // MARK: - Get
    
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
    
    // MARK: - Private
    
    @discardableResult
    private func get(path: String, complete: ((Any?) -> Void)?) -> Any? {
        
        let url = completeURLWithPath(path: path)
        let completionHandler = createCompletionHandler(method: .get, callback: complete)
        
        let httpResult = HTTPMethod.get.justRequest(url, [:], [:], nil, headers, [:], nil, [:],
                                                    false, timeout, nil, nil, nil, completionHandler)
        
        guard complete == nil else { return nil }
        return process(httpResult: httpResult, method: .get)
    }
    
    @discardableResult
    private func write(value: Any,
                       path: String,
                       method: HTTPMethod,
                       complete: (([String: Any]?) -> Void)? = nil) -> [String: Any]? {
        
        let url = completeURLWithPath(path: path)
        let json: Any? = JSONSerialization.isValidJSONObject(value) ? value : [".value": value]
        
        let callback: ((Any?) -> Void)? = complete == nil ? nil : { result in
            complete?(result as? [String: Any])
        }
        let completionHandler = createCompletionHandler(method: method, callback: callback)
        let result = method.justRequest(url, [:], [:], json, headers, [:], nil, [:],
                                        false, timeout, nil, nil, nil, completionHandler)
        
        guard complete == nil else { return nil }
        return process(httpResult: result, method: method) as? [String : Any]
    }
    
    private func completeURLWithPath(path: String) -> String {
        // In the form https://firestore.googleapis.com/v1beta1/projects/PROJECT_ID/databases/(default)/documents/COLLECTION_ID/DOCUMENT_ID
        return baseURL + "projects/\(projectId)/" + "databases/\(databaseId)/" + path
    }
    
    private func process(httpResult: HTTPResult, method: HTTPMethod) -> Any? {
        if let e = httpResult.error {
            print("ERROR FirebaseSwift-\(method.rawValue) message: \(e.localizedDescription)")
            return nil
        }
        
        guard httpResult.content != nil else {
            print("ERROR FirebaseSwift-\(method.rawValue) message: No content in http response.")
            return nil
        }
        
        if let json = httpResult.contentAsJSONMap() {
            return json
        } else {
            print("ERROR FirebaseSwift-\(method.rawValue) message: Failed to parse json response. Status code: \(String(describing: httpResult.statusCode))")
            return nil
        }
    }
    
    private func createCompletionHandler(method: HTTPMethod,
                                         callback: ((Any?) -> Void)?) -> ((HTTPResult) -> Void)? {
        if let callback = callback {
            let completionHandler: ((HTTPResult) -> Void)? = { result in
                callback(self.process(httpResult: result, method: method))
            }
            return completionHandler
        }
        return nil
    }
}
