//
//  FirebaseStorageUploader.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class FirebaseStorageUploader {
    
    func updateUserImage(image:UIImage, uId:String, completion : @escaping (Bool) -> Void) {
        oneImageUpload(image: image, ref: "users/\(uId).jpeg") { url, error in
            if let url = url {
                Task {
                    try? await UsersDao().update(id: uId, hash: ["userURL": url.absoluteString])
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.userURL = url.absoluteString
                        UserInformation.shared.updateUser()
                        completion(true)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func oneImageUpload(image:UIImage,ref:String, completion : @escaping (URL?, Error?) -> Void) {
        print("Uploading started")
        let imageRef = Storage.storage().reference().child(ref)
        
        image.compress(image: image) { compress in
            if let compress = compress, let data = compress.jpegData(compressionQuality: 1) {
                imageRef.putData(data, metadata: nil) { metadata, error in
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
        }
    }
    
    func uploadImagesToFirebaseStorage(images: [UIImage?], storageRef: String, completion: @escaping ([String]?, Error?) -> Void){
        
        var imageURLs: [String] = []
        let ref = Storage.storage().reference().child(storageRef)
        
        for (index, image) in images.enumerated() {
            

            let filename = "\(index) - \(generateRandomNumber()).jpeg" // Unique filename for each image
            let imageRef = ref.child(filename)
            
            guard let image = image else {
                imageURLs.append("")
                continue
            }

            image.compress(image: image) { compress in
                if let compress = compress, let data = compress.jpegData(compressionQuality: 1) {
                    imageRef.putData(data, metadata: nil) { metadata, error in
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
                                imageURLs.append(downloadURL.absoluteString)
                            }

                            // Check if all images have been uploaded and URLs retrieved
                            if imageURLs.count == images.count {
                                completion(imageURLs, nil)
                            }
                        }
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
