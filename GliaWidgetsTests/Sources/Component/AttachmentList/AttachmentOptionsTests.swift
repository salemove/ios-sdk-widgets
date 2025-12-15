@testable import GliaWidgets
import XCTest
import UniformTypeIdentifiers

class AttachmentOptionsTests: XCTestCase {
    
    // MARK: - allowedMediaContentTypes Tests
    
    func test_allowedMediaContentTypes_filtersImageAndVideoTypes() {
        let allTypes = ["image/jpeg", "image/png", "video/quicktime", "application/pdf", "text/plain"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: allTypes)
        
        // Note: allowedMediaContentTypes is private, testing through public allowedMediaTypes
        let mediaTypes = mock.allowedMediaTypes
        XCTAssertTrue(mediaTypes.contains(.image))
        XCTAssertTrue(mediaTypes.contains(.movie))
    }
    
    func test_allowedMediaContentTypes_filtersImageTypes() {
        let allTypes = ["image/jpeg", "image/png", "application/pdf", "text/plain"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: allTypes)
        
        // Note: allowedMediaContentTypes is private, testing through public allowedMediaTypes
        let mediaTypes = mock.allowedMediaTypes
        XCTAssertTrue(mediaTypes.contains(.image))
        XCTAssertFalse(mediaTypes.contains(.movie))
    }
    
    func test_allowedMediaContentTypes_filtersVideoTypes() {
        let allTypes = ["video/quicktime", "video/mp4", "application/pdf"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: allTypes)
        
        // Note: allowedMediaContentTypes is private, testing through public allowedMediaTypes
        let mediaTypes = mock.allowedMediaTypes
        XCTAssertFalse(mediaTypes.contains(.image))
        XCTAssertTrue(mediaTypes.contains(.movie))
    }
    
    func test_allowedMediaContentTypes_returnsEmptyForNonMediaTypes() {
        let allTypes = ["application/pdf", "text/plain", "application/msword"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: allTypes)
        
        XCTAssertEqual(mock.allowedMediaTypes, [])
    }
    
    // MARK: - allowedAttachmentOptions Tests
    
    func test_allowedAttachmentOptions_includesAllOptionsWhenAllTypesSupported() {
        let types = ["image/jpeg", "video/quicktime", "application/pdf"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: types)
        
        let options = mock.allowedAttachmentOptions
        XCTAssertEqual(options.count, 3)
        XCTAssertTrue(options.contains(.photoLibrary))
        XCTAssertTrue(options.contains(.takePhotoOrVideo))
        XCTAssertTrue(options.contains(.browse))
    }
    
    func test_allowedAttachmentOptions_includesTakePhotoOnlyWhenOnlyJpegSupported() {
        let types = ["image/jpeg", "application/pdf"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: types)
        
        let options = mock.allowedAttachmentOptions
        XCTAssertTrue(options.contains(.photoLibrary))
        XCTAssertTrue(options.contains(.takePhoto))
        XCTAssertTrue(options.contains(.browse))
        XCTAssertFalse(options.contains(.takePhotoOrVideo))
        XCTAssertFalse(options.contains(.takeVideo))
    }
    
    func test_allowedAttachmentOptions_includesTakeVideoOnlyWhenOnlyQuicktimeSupported() {
        let types = ["video/quicktime", "application/pdf"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: types)
        
        let options = mock.allowedAttachmentOptions
        XCTAssertTrue(options.contains(.photoLibrary))
        XCTAssertTrue(options.contains(.takeVideo))
        XCTAssertTrue(options.contains(.browse))
        XCTAssertFalse(options.contains(.takePhotoOrVideo))
        XCTAssertFalse(options.contains(.takePhoto))
    }
    
    func test_allowedAttachmentOptions_onlyIncludesBrowseForNonMediaTypes() {
        let types = ["application/pdf", "text/plain"]
        let mock = MockAttachmentOptions(allowedFileContentTypes: types)
        
        let options = mock.allowedAttachmentOptions
        XCTAssertEqual(options.count, 1)
        XCTAssertTrue(options.contains(.browse))
    }
    
    func test_allowedAttachmentOptions_returnsEmptyForNoTypes() {
        let mock = MockAttachmentOptions(allowedFileContentTypes: [])
        
        XCTAssertEqual(mock.allowedAttachmentOptions, [])
    }
    
    // MARK: - Array Extension mimeTypesToUTIs Tests
    
    func test_mimeTypesToUTIs_convertsValidMimeTypes() {
        let mimeTypes = ["image/jpeg", "image/png", "application/pdf", "application/msword"]
        let utis = mimeTypes.mimeTypesToUTIs()
        
        XCTAssertEqual(utis.count, 4)
        XCTAssertTrue(utis.contains("public.jpeg"))
        XCTAssertTrue(utis.contains("public.png"))
        XCTAssertTrue(utis.contains("com.adobe.pdf"))
        XCTAssertTrue(utis.contains("com.microsoft.word.doc"))
    }
    
    func test_mimeTypesToUTIs_filtersOutInvalidMimeTypes() {
        let mimeTypes = ["image/jpeg", "invalid/mimetype", "application/pdf"]
        let utis = mimeTypes.mimeTypesToUTIs()
        
        // Valid MIME types should be converted
        XCTAssertTrue(utis.contains("public.jpeg"))
        XCTAssertTrue(utis.contains("com.adobe.pdf"))
    }
    
    func test_mimeTypesToUTIs_returnsEmptyForEmptyArray() {
        let mimeTypes: [String] = []
        let utis = mimeTypes.mimeTypesToUTIs()
        
        XCTAssertEqual(utis, [])
    }
    
    func test_mimeTypesToUTIs_handlesVideoMimeTypes() {
        let mimeTypes = ["video/quicktime", "video/mp4"]
        let utis = mimeTypes.mimeTypesToUTIs()
        
        XCTAssertEqual(utis.count, 2)
        XCTAssertTrue(utis.contains("com.apple.quicktime-movie"))
        XCTAssertTrue(utis.contains("public.mpeg-4"))
    }
    
    func test_mimeTypesToUTIs_handlesTextMimeTypes() {
        let mimeTypes = ["text/plain", "text/html"]
        let utis = mimeTypes.mimeTypesToUTIs()
        
        XCTAssertEqual(utis.count, 2)
        XCTAssertTrue(utis.contains("public.plain-text"))
        XCTAssertTrue(utis.contains("public.html"))
    }
    
    // MARK: - Test Implementation
    
    struct MockAttachmentOptions: AttachmentOptions {
        var allowedFileContentTypes: [String]
    }
}
