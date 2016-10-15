import PackageDescription

let package = Package(
    name: "Firebase-Swift",
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", majorVersion: 2, minor: 0),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-libcurl.git", majorVersion: 2, minor: 0)
    ]
    
)
