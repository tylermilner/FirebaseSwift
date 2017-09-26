import PackageDescription

let package = Package(
    name: "firebase-swift",
    dependencies: [
        .Package(url: "https://github.com/gtchance/Just.git", majorVersion: 0, minor: 6)
    ]

)
