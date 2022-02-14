@testable import GliaWidgets

extension FoundationBased.FileManager {
    static let failing = Self(
        urlsForDirectoryInDomainMask: { _, _ in
            fail("\(Self.self).urlsForDirectoryInDomainMask")
            return []
        },
        fileExistsAtPath: { _ in
            fail("\(Self.self).fileExistsAtPath")
            return false
        },
        createDirectoryAtUrlWithIntermediateDirectories: { _, _, _ in
            fail("\(Self.self).createDirectoryAtUrlWithIntermediateDirectories")
        },
        removeItemAtUrl: { _ in
            fail("\(Self.self).removeItemAtUrl")
        },
        copyItemAtPath: { _, _ in
            fail("\(Self.self).copyItemAtPath")
        },
        contentsOfDirectoryAtPath: { _ in
            fail("\(Self.self).contentsOfDirectoryAtPath")
            return []
        },
        attributesOfItemAtPath: { _ in
            fail("\(Self.self).attributesOfItemAtPath")
            return [:]
        },
        removeItemAtPath: { _ in
            fail("\(Self.self).removeItemAtPath")
        }
    )
}

extension FoundationBased.Data {
    static let failing = Self(
        writeDataToUrl: { _, _ in
            fail("\(Self.self).writeDataToUrl")
        },
        dataWithContentsOfFileUrl: { _ in
            fail("\(Self.self).dataWithContentsOfFileUrl")
            return .mock
        }
    )
}
