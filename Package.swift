// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ivas-messenger-ui-ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "IVASMessengerUI",
            targets: ["IVASMessengerUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iwill/generic-json-swift", exact: "2.0.2"),
        .package(url: "https://github.com/socketio/socket.io-client-swift", exact: "16.1.0"),
        .package(url: "https://github.com/dkk/WrappingHStack", exact: "2.2.11"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.6")
    ],
    targets: [
        .target(
            name: "IVASMessengerUI",
            dependencies: [
                .product(name: "GenericJSON", package: "generic-json-swift"),
                .product(name: "SocketIO", package: "socket.io-client-swift"),
                .product(name: "Starscream", package: "Starscream"),
                .product(name: "WrappingHStack", package: "WrappingHStack")
            ]),
        .testTarget(
            name: "IVASMessengerUITests",
            dependencies: ["IVASMessengerUI"]),
    ]
)
