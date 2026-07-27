// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "im_flutter_sdk_ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "im-flutter-sdk-ios",
            targets: ["im_flutter_sdk_ios"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/easemob/HyphenateChat_iOS.git",
            exact: "4.19.1"
        ),
        .package(
            name: "FlutterFramework",
            path: "../FlutterFramework"
        )
    ],
    targets: [
        .target(
            name: "im_flutter_sdk_ios",
            dependencies: [
                .product(name: "HyphenateChat", package: "HyphenateChat_iOS"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/im_flutter_sdk_ios",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/im_flutter_sdk_ios")
            ]
        )
    ]
)
