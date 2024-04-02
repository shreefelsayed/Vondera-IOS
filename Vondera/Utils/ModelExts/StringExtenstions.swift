//
//  StringExtenstions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import PhotosUI

extension Timestamp {
    func toString(format: String = "yyyy MMM, dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: dateValue())
    }
}

extension LocalizedStringKey {
    public func toString() -> String {
        //use reflection
        let mirror = Mirror(reflecting: self)
        
        //try to find 'key' attribute value
        let attributeLabelAndValue = mirror.children.first { (arg0) -> Bool in
            let (label, _) = arg0
            if(label == "key"){
                return true;
            }
            return false;
        }
        
        if(attributeLabelAndValue != nil) {
            //ask for localization of found key via NSLocalizedString
            return String.localizedStringWithFormat(NSLocalizedString(attributeLabelAndValue!.value as! String, comment: ""));
        }
        else {
            return "Swift LocalizedStringKey signature must have changed. @see Apple documentation."
        }
    }
}

extension String {
    func localize() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
    
    var firstName: String {
        let components = self.components(separatedBy: " ")
        if let firstName = components.first {
            return firstName
        } else {
            return self
        }
    }
    
    var isValidEmail: Bool {
        // Regular expression pattern to match the email format
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        // Create a predicate with the email regex pattern
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        // Evaluate the predicate for the current string
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidName : Bool {
        
        return self.count >= 3
    }
    
    var isValidPassword:Bool {
        return self.count >= 6
    }
    
    var isNumeric: Bool {
        let numericSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: self)
        return numericSet.isSuperset(of: characterSet)
    }
    
    var isPhoneNumber: Bool {
        let requiredLength = 11
        let prefix = "01"
        
        guard count == requiredLength else {
            return false
        }
        
        guard self.isNumeric else {
            return false
        }
        
        return hasPrefix(prefix)
    }
    
    func containsOnlyEnglishLetters() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z]*$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
    
    func containsOnlyEnglishLettersOrNumbers() -> Bool {
            let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9]*$", options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.utf16.count)
            return regex?.firstMatch(in: self, options: [], range: range) != nil
        }
    
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func toHtml() -> NSAttributedString {
        let encodedData = self.data(using: String.Encoding.utf8)!
        var attributedString: NSAttributedString

        do {
            attributedString = try NSAttributedString(data: encodedData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            
            return attributedString
        } catch let error as NSError {
            print(error.localizedDescription)
            return NSAttributedString.empty
        } catch {
            print("error")
            return NSAttributedString.empty
        }
    }
    
    func capitalizeFirstLetter() -> String {
        guard let firstLetter = self.first else {
            return self
        }
        
        let restOfString = String(self.dropFirst())
        return String(firstLetter).uppercased() + restOfString.lowercased()
    }
    
    func containsNoNumbers() -> Bool {
        let numberCharacterSet = CharacterSet.decimalDigits
        return self.rangeOfCharacter(from: numberCharacterSet) == nil
    }
    
    var qrCodeData: Data? {
        let filter = CIFilter.qrCodeGenerator()
        guard let data = self.data(using: .ascii, allowLossyConversion: false) else { return nil }
        filter.message = data
        guard let ciimage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }
    
    func qrCodeDataWithLogo(assetName:String = "app_icon") -> Data? {
        guard let logoImage = UIImage(named: assetName) else {
            return nil
        }
        
        // Generate the QR code
        let filter = CIFilter.qrCodeGenerator()
        guard let data = self.data(using: .ascii, allowLossyConversion: false) else {
            return nil
        }
        filter.message = data
        guard let qrCIImage = filter.outputImage else {
            return nil
        }
        
        let scaleFactor: CGFloat = 20 // Adjust this value as needed
        let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        qrCIImage.transformed(by: transform)
        let qrCodeSize = qrCIImage.extent.size
        let logoSize = CGSize(width: qrCodeSize.width / 3, height: qrCodeSize.height / 3) // Adjust the size as needed
        
        // Scale the logo image to the desired size
        let scaledLogoImage = logoImage.resize(targetSize: logoSize)
        
        // Create a CGContext to composite the QR code and logo
        let context = CIContext()
        guard let qrCGImage = context.createCGImage(qrCIImage, from: qrCIImage.extent) else {
            return nil
        }
        
        UIGraphicsBeginImageContext(qrCodeSize)
        
        // Draw the QR code
        UIImage(cgImage: qrCGImage).draw(in: CGRect(origin: .zero, size: qrCodeSize))
        
        // Draw the logo in the center
        let originX = (qrCodeSize.width - logoSize.width) / 2
        let originY = (qrCodeSize.height - logoSize.height) / 2
        scaledLogoImage.draw(in: CGRect(origin: CGPoint(x: originX, y: originY), size: logoSize))
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return compositeImage?.pngData()
    }
    
    var qrCodeUIImage : UIImage? {
        if let data = qrCodeData {
            return UIImage(data: data)
        }
        
        return nil
    }
}

extension Binding where Value == String {
    init(fromOptional: Binding<String?>) {
        self.init {
            fromOptional.wrappedValue ?? ""
        } set : { newValue in
            fromOptional.wrappedValue = newValue
        }
    }
}

extension Binding where Value == Int {
    init(fromOptional: Binding<Int?>) {
        self.init {
            fromOptional.wrappedValue ?? 0
        } set : { newValue in
            fromOptional.wrappedValue = newValue
        }
    }
}



extension Binding where Value == Bool {
    init<T>(value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set : { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
    
    init(fromOptional: Binding<Bool?>, defaultValue:Bool) {
        self.init {
            fromOptional.wrappedValue ?? defaultValue
        } set : { newValue in
            fromOptional.wrappedValue = newValue
        }
    }
    
    
    init<T>(items: Binding<[T]>, currentItem: T) where T: Equatable {
        self.init(
            get: { items.wrappedValue.contains(currentItem) },
            set: { newValue in
                if newValue {
                    if !items.wrappedValue.contains(currentItem) {
                        items.wrappedValue.append(currentItem)
                    }
                } else {
                    items.wrappedValue.removeAll { $0 == currentItem }
                }
            }
        )
    }
}

extension Array where Element: Equatable {
    func uniqueElements() -> [Element] {
        var uniqueElements = [Element]()
        
        for element in self {
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
        
        return uniqueElements
    }
}


// Function to resize a UIImage
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}

extension NSAttributedString {
    var attributedString2Html: String? {
        do {
            let htmlData = try self.data(from: NSRange(location: 0, length: self.length), documentAttributes:[.documentType: NSAttributedString.DocumentType.html]);
            return String.init(data: htmlData, encoding: String.Encoding.utf8)
        } catch {
            print("error:", error)
            return nil
        }
    }
}

extension Array where Element == PhotosPickerItem {
    func getUIImages() async -> [UIImage] {
        var items:[UIImage] = []
        
        for image in self {
            if let uiImage = try? await image.getImage() {
                items.append(uiImage)
            }
        }
        
        return items
    }
    
    func addToListPhotos(list:[ImagePickerWithUrL]) async -> [ImagePickerWithUrL]{
        var listPhotos = list
        let uiImages = await self.getUIImages()
        for imageIndex in uiImages.indices {
            let image = uiImages[imageIndex]
            
            var foundImage = false
            for photoIndex in listPhotos.indices {
                // MARK : Delete changed images
                let item = listPhotos[photoIndex].image
                if let item = item, uiImages.firstIndex(of: item) == nil {
                    listPhotos.remove(at: photoIndex)
                    continue
                }
                
                if item == image {
                    foundImage = true
                }
            }
            
            // --> Add the image
            if !foundImage {
                listPhotos.append(ImagePickerWithUrL(image: image, link: nil, index: imageIndex))
            }
        }
        
        return listPhotos
    }
    
}

extension PhotosPickerItem {
    func getImage() async throws -> UIImage?{
        let data = try await self.loadTransferable(type: Data.self)
        guard let data = data, let image = UIImage(data: data) else{
            return nil
        }
        return image
    }
    
    func getPath() async  -> String {
        if let id = try? await self.getURL(item: self) {
            print("Path \(id)")
            return id.path()
        }
        
        print("Couldn't get id")
        return ""
    }
    
    func getURL(item: PhotosPickerItem) async throws -> URL? {
        // Step 1: Load as Data object.
        let data = try await item.loadTransferable(type: Data.self)

        if let contentType = item.supportedContentTypes.first {
            // Step 2: make the URL file name and get a file extension.
            let url = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")")

            if let data = data {
                do {
                    try data.write(to: url)
                    return url
                } catch {
                    throw error
                }
            }
            
        }
        
        return nil
    }

    /// from: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

}

extension Array where Element == String {
    func convertImageUrlsToItems() -> [ImagePickerWithUrL] {
        let items = self.filter { !$0.isBlank }
        return items.map { link in
            ImagePickerWithUrL(image: nil, link: link, index: 0)
        }
    }
}


    
extension Array where Element == ImagePickerWithUrL {
    func getItemsToUpload() -> [ImagePickerWithUrL] {
        var images = [ImagePickerWithUrL]()
        for items in self {
            if let image = items.image{
                images.append(items)
            }
        }
        return images
    }
    
    func mapUrlsToLinks(urls : [URL]) -> [ImagePickerWithUrL] {
        var listPhotos = self
        let uploadedItems = listPhotos.getItemsToUpload()
        for photoIndex in listPhotos.indices {
            let photo = listPhotos[photoIndex]
            
            for uiImageIndex in uploadedItems.indices {
                let uiImage = uploadedItems[uiImageIndex]
                if photo.id == uiImage.id {
                    listPhotos[photoIndex].image = nil
                    listPhotos[photoIndex].link = urls[uiImageIndex].absoluteString
                }
            }
        }
        
        return listPhotos
    }
    
    func getLinks() -> [String] {
        var allLinks = [String]()
        for item in self {
            if let link = item.link, !link.isBlank, item.image == nil {
                allLinks.append(link)
            }
        }
        
        return allLinks
    }
}

