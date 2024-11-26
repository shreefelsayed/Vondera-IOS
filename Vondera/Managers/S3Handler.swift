import Foundation
import AWSS3
import UIKit
import FirebaseFirestore

class S3Handler {
    static let s3BucketName = "vondera-bucket"

    static func configureAWS() {
        let accessKeyId = RemoteConfigManager.awsAccessKey
        let secretAccessKey = RemoteConfigManager.awsSecretKey
       
        print("Access Key \(accessKeyId)")
        print("Access Secret \(secretAccessKey)")

        let region = AWSRegionType.EUNorth1

        // Credentials provider
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKeyId, secretKey: secretAccessKey)

        // Service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)

        // Register the service configuration as the default
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration

        // Transfer Utility Configuration
        let transferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        transferUtilityConfiguration.isAccelerateModeEnabled = true // Enable S3 Transfer Acceleration if needed
        transferUtilityConfiguration.retryLimit = 3 // Retry 3 times before failing

        // Register Transfer Utility with the configuration
        AWSS3TransferUtility.register(
            with: serviceConfiguration!,
            transferUtilityConfiguration: transferUtilityConfiguration,
            forKey: "S3TransferUtility"
        )
    }
    
    @MainActor
    static func uploadImages(imagesToUpload: [UIImage],
                                 maxSizeMB: Double? = nil,
                                 path: String,
                                 createThumbnail: Bool = false,
                                 complete: @escaping (([String], [String?])) -> ()) {
            
            var uploadResults: ([String], [String?]) = ([], [])
            let uploadGroup = DispatchGroup()

            for image in imagesToUpload {
                let key = UUID().uuidString
                let imageKey = "\(path)/\(key).jpg"
                let thumbnailKey = "\(path)/\(key)_thumbnail.jpg"

                uploadGroup.enter()
                singleUpload(image: image, path: imageKey, maxSizeMB: maxSizeMB) { uploadedUrl in
                    if let url = uploadedUrl {
                        uploadResults.0.append(url)
                    }

                    if createThumbnail {
                        singleUpload(image: image, path: thumbnailKey, maxSizeMB: 0.1) { uploadedUrl in
                            if let url = uploadedUrl {
                                uploadResults.1.append(url)
                            } else {
                                uploadResults.1.append(nil)
                            }
                            uploadGroup.leave()
                        }
                    } else {
                        uploadGroup.leave()
                    }
                }
            }

            uploadGroup.notify(queue: DispatchQueue.main) {
                complete(uploadResults)
            }
        }

    @MainActor
    static func singleUpload(image: UIImage, path: String, maxSizeMB: Double? = nil, complete: @escaping (String?) -> ()) {
            var imageToUpload = image
            
            if let maxSize = maxSizeMB {
                let maxSizeKB = Int(maxSize * 1024)
                if let compressedData = image.compress(to: maxSizeKB), let compressedImage = UIImage(data: compressedData) {
                    imageToUpload = compressedImage
                }
            }
            
            guard let imageData = imageToUpload.jpegData(compressionQuality: 1.0) else {
                print("Failed to convert UIImage to JPEG data")
                complete("Error")
                return
            }
            
            let expression = AWSS3TransferUtilityUploadExpression()
            let transferUtility = AWSS3TransferUtility.default()

            print("Uploading image...")

            transferUtility.uploadData(imageData,
                                       bucket: s3BucketName,
                                       key: path,
                                       contentType: "image/jpeg",
                                       expression: expression) { task, error in
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    complete("Error")
                } else {
                    let fileUrl = getFileUrl(for: path)
                    removeImageCache(url: fileUrl)
                    complete(fileUrl)
                }
            }.continueWith { task -> AnyObject? in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                    complete("Error")
                }
                return nil
            }
        }
    
    @MainActor
    static func getFileUrl(for key: String) -> String {
        return "https://\(s3BucketName).s3.eu-north-1.amazonaws.com/\(key)"
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * percentage, height: size.height * percentage)

        return self.preparingThumbnail(of: newSize)
    }

    func compress(to kb: Int, allowedMargin: CGFloat = 0.1) -> Data? {
        let bytes = kb * 1024
        let threshold = Int(CGFloat(bytes) * (1 + allowedMargin))
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        while let data = holderImage.pngData() {
            let ratio = data.count / bytes
            if data.count < threshold {
                return data
            } else {
                let multiplier = CGFloat((ratio / 5) + 1)
                compression -= (step * multiplier)

                guard let newImage = self.resized(withPercentage: compression) else { break }
                holderImage = newImage
            }
        }

        return nil
    }
}
