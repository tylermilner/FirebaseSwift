import PackageDescription

let package = Package(
    name: "FirebaseSwift",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 14, minor: 2),
        .Package(url: "https://github.com/daltoniam/SwiftHTTP.git", majorVersion: 2, minor: 0),
        .Package(url: "https://github.com/JustHTTP/Just.git", majorVersion: 0, minor: 5)
    ]

)
