//
//  FirebaseStorageUploader.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseStorageUploader {
    
    func oneImageUpload(image:UIImage,name:String = "image" , ref:StorageReference, completion : @escaping (URL?, Error?) -> Void) {
        guard let imageData = image.compress() else {
            print("Couldn't compress image")
            completion(nil, nil) // Handle error if image data couldn't be generated
            return
        }

        print("Uploading started")
        let filename = "\(name).jpeg" // Unique filename for each image
        let imageRef = ref.child(filename)

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Couldn't upload image \(error.localizedDescription)")
                completion(nil, error) // Handle upload error
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Couldn't get image url \(error.localizedDescription)")
                    completion(nil, error) // Handle download URL error
                    return
                }

                if let downloadURL = url {
                    print("uploaded image \(downloadURL)")
                    completion(url, nil)
                }
            }
        }
    }
    
    func uploadImagesToFirebaseStorage(images: [UIImage], storageRef: StorageReference, completion: @escaping ([URL]?, Error?) -> Void){
        var imageURLs: [URL] = []

        for (index, image) in images.enumerated() {
            guard let imageData = image.compress() else {
                completion(nil, nil) // Handle error if image data couldn't be generated
                return
            }

            let filename = "\(index) - \(generateRandomNumber()).jpeg" // Unique filename for each image
            let imageRef = storageRef.child(filename)

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(nil, error) // Handle upload error
                    return
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(nil, error) // Handle download URL error
                        return
                    }

                    if let downloadURL = url {
                        imageURLs.append(downloadURL)
                    }

                    // Check if all images have been uploaded and URLs retrieved
                    if imageURLs.count == images.count {
                        completion(imageURLs, nil)
                    }
                }
            }
        }
    }

    func generateRandomNumber() -> String {
        let randomNumber = Int.random(in: 1...999)
        let formattedNumber = String(format: "%03d", randomNumber)
        return formattedNumber
    }

}
