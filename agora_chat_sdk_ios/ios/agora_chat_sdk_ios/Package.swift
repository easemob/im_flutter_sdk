// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "agora_chat_sdk_ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "agora-chat-sdk-ios",
            targets: ["agora_chat_sdk_ios"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/easemob/HyphenateChat_iOS.git",
            exact: "5.2.0"
        ),
        .package(
            name: "FlutterFramework",
            path: "../FlutterFramework"
        )
    ],
    targets: [
        .target(
            name: "agora_chat_sdk_ios",
            dependencies: [
                .product(name: "HyphenateChat", package: "HyphenateChat_iOS"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/agora_chat_sdk_ios",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/agora_chat_sdk_ios")
            ]
        )
    ]
)
