// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombinePlus",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "CombinePlus",
            targets: ["CombinePlus"]
        ),
        .library(
            name: "FirestoreCombine",
            targets: ["FirestoreCombine"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/CombineCommunity/CombineCocoa.git",
            from: "0.4.1"
        ),
        .package(
            url: "https://github.com/CombineCommunity/CombineExt",
            from: "1.8.1"
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "11.3.0"
        )
    ],
    targets: [
        .target(name: "COpenCombineHelpers"),
        .target(
            name: "CombinePlus",
            dependencies: [
                "CombineCocoa",
                "CombineExt",
                "COpenCombineHelpers"
            ]
        ),
        .target(
            name: "FirestoreCombine",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "CombinePlusTests",
            dependencies: ["CombinePlus"]
        )
    ]
)
