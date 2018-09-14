// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "VaporChat",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/wmcginty/urbanvapor.git", from: "0.0.3")
    ],
    targets: [
    .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL", "Authentication", "Crypto", "UrbanVapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

