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
    
    func getLink(mId:String) -> URL {
        let link = "https://vondera.store/pages?store=\(mId)&id=\(id)"
        return URL(string: link)!
    }
}
