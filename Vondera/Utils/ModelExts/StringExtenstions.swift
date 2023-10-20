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

extension String {
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
    
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        guard var qrCIImage = filter.outputImage else {
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

extension PhotosPickerItem{
    func getImage() async throws -> UIImage?{
        let data = try await self.loadTransferable(type: Data.self)
        guard let data = data, let image = UIImage(data: data) else{
            return nil
        }
        return image
    }
}
