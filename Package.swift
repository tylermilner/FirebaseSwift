import PackageDescription

let package = Package(
    name: "FirebaseSwift",
    dependencies: [
        .Package(url: "https://github.com/gtchance/Just.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3, minor: 1),
    ]

)
