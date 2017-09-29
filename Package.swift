import PackageDescription

let package = Package(
    name: "FirebaseSwift",
    dependencies: [
        .Package(url: "https://github.com/gtchance/Just.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1, 0, 0)..<Version(3, .max, .max)),
    ]

)
