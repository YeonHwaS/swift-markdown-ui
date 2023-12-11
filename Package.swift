// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "swift-markdown-ui",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "MarkdownUI",
      targets: ["MarkdownUI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/gonzalezreal/NetworkImage", from: "6.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0"),
  ],
  targets: [
    .target(name: "cmark-gfm",
      path: "Sources/cmark-gfm/src",
      exclude: [
        "scanners.re",
        "libcmark-gfm.pc.in",
        "config.h.in",
        "CMakeLists.txt",
        "cmark-gfm_version.h.in",
        "case_fold_switch.inc",
        "entities.inc",
      ],
      publicHeadersPath: "Sources/cmark-gfm/src/include",
      cSettings: []
    ),
    .target(name: "cmark-gfm-extensions",
      dependencies: [
        "cmark-gfm",
      ],
      path: "Sources/cmark-gfm/extensions",
      exclude: [
        "CMakeLists.txt",
        "ext_scanners.re",
      ],
      publicHeadersPath: "Sources/cmark-gfm/extensions/include",
      cSettings: []
    ),
    .target(
      name: "MarkdownUI",
      dependencies: [
        "cmark-gfm",
        "cmark-gfm-extensions",
        .product(name: "NetworkImage", package: "NetworkImage"),
      ]
    ),
    .testTarget(
      name: "MarkdownUITests",
      dependencies: [
        "MarkdownUI",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
