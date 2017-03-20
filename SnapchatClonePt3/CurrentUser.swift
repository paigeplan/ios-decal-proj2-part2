//
//  CurrentUser.swift
//  SnapchatClonePt3
//
//  Created by SAMEER SURESH on 3/19/17.
//  Copyright © 2017 iOS Decal. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CurrentUser {
    
    var username: String!
    var id: String!
    var readPostIDs: [String]?
    
    let dbRef = FIRDatabase.database().reference()
    
    init() {
        let currentUser = FIRAuth.auth()?.currentUser
        username = currentUser?.displayName
        id = currentUser?.uid
    }
    
    func getReadPostIDs(completion: @escaping ([String]) -> Void) {
        dbRef.child("Users/\(id!)/readPosts").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let posts = snapshot.value as? [String] {
                    self.readPostIDs = posts
                    completion(posts)
                } else {
                    completion([])
                }
            } else {
                completion([])
            }
        })
    }
    
    func addNewReadPost(postID: String) {
        dbRef.child("Users/\(id!)/readPosts").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if var posts = snapshot.value as? [String] {
                    posts.append(postID)
                    self.dbRef.child("Users/\(self.id!)/readPosts").setValue(posts)
                }
            } else {
                self.dbRef.child("Users/\(self.id!)/readPosts").setValue([postID])
            }
        })
    }
    
}
