//
//  ImageControllerTests.swift
//  TBCTests
//
//  Created by Eli Heineman on 2021-04-21.
//

import XCTest
@testable import TBC

class ImageControllerTests: XCTestCase {
    
    var imageController: ImageController!
    var image: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        imageController = ImageController()
        image = #imageLiteral(resourceName: "elijahMemoji")
    }

    override func tearDownWithError() throws {
        imageController = nil
        image = nil
        try super.tearDownWithError()
    }
    
    func testSaveImage() {
        let imageName = imageController.saveImage(image: image)
        
        XCTAssert(imageName != nil, "imageName was nil after save attempt")
    }
    
    func testFetchImage() {
        guard let imageName = imageController.saveImage(image: image) else {
            return
        }
        
        let savedImage = imageController.fetchImage(imageName: imageName)
        
        XCTAssert(savedImage != nil, "savedImage was nil after fetch attempt")
    }
    
    func testFetchInvalidImage() {
        let savedImage = imageController.fetchImage(imageName: "imageName")
        
        XCTAssert(savedImage == nil, "savedImage was not nil after invalid fetch attempt")
    }
    
    func testDeleteImage() {
        guard let imageName = imageController.saveImage(image: image) else {
            return
        }
        
        imageController.deleteImage(imageName: imageName)
        
        let savedImage = imageController.fetchImage(imageName: imageName)
        
        XCTAssert(savedImage == nil, "savedImage was not nil after delete attempt")
    }
}
