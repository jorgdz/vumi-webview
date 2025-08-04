// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VumiWebview",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "VumiWebview",
            targets: ["WebViewPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "WebViewPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/WebViewPluginPlugin"),
        .testTarget(
            name: "WebViewPluginPluginTests",
            dependencies: ["WebViewPluginPlugin"],
            path: "ios/Tests/WebViewPluginPluginTests")
    ]
)