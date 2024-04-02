//
//  WebsiteSection.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct WebsiteSection : Codable, Identifiable{
    var id = "";
    var title = "";
    var body = "";
    var imagesUrls = [String]()
    var sortValue = 0;
    var date = Timestamp(date: Date())
    
    func getLink(baseLink:String) -> URL {
        let link = "\(baseLink)/page/\(id)"
        return URL(string: link)!
    }
}
