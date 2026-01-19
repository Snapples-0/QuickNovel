// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QuickNovel",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "QuickNovel",
            targets: ["QuickNovel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
    ],
    targets: [
        .target(
            name: "QuickNovel",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "QuickNovelTests",
            dependencies: ["QuickNovel"]),
    ]
)
