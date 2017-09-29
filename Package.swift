import PackageDescription

let package = Package(
    name: "FirebaseSwift",
    dependencies: [
        .Package(url: "https://github.com/gtchance/Just.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 16, minor: 0),
    ]

)
