//
//  imageFeed.swift
//  snapChatProject
//
//  Created by Akilesh Bapu on 2/27/17.
//  Copyright © 2017 org.iosdecal. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

// This is the only line of code you should be modifying
var threads: [String: [Post]] = ["Memes": [], "Dog Spots": [], "Random": []]


let threadNames = ["Memes", "Dog Spots", "Random"]


func getPostFromIndexPath(indexPath: IndexPath) -> Post? {
    let sectionName = threadNames[indexPath.section]
    if let postsArray = threads[sectionName] {
        return postsArray[indexPath.row]
    }
    print("No post at index \(indexPath.row)")
    return nil
}

func addPostToThread(post: Post) {
    threads[post.thread]!.append(post)
}

func clearThreads() {
    threads = ["Memes": [], "Dog Spots": [], "Random": []]
}
/// Adds the given post to the thread associated with it
/// (the thread is set as an instance variable of the post)
///
/// - Parameter post: The post to be added to the model
func addPost(postImage: UIImage, thread: String, username: String) {
    let dbRef = FIRDatabase.database().reference()
    let data = UIImageJPEGRepresentation(postImage, 1.0)
    let path = "Images/\(UUID().uuidString)"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.A"
    let dateString = dateFormatter.string(from: Date())
    let postDict: [String:AnyObject] = ["imagePath": path as AnyObject,
                                        "username": username as AnyObject,
                                        "thread": thread as AnyObject,
                                        "date": dateString as AnyObject]
    
    dbRef.child("Posts").childByAutoId().setValue(postDict)
    store(data: data, toPath: path)
}

func store(data: Data?, toPath path: String) {
    let storageRef = FIRStorage.storage().reference()
    storageRef.child(path).put(data!, metadata: nil) { (metadata, error) in
        if let error = error {
            print(error)
        }
    }
}

func getPosts(user: CurrentUser, completion: @escaping ([Post]?) -> Void) {
    let dbRef = FIRDatabase.database().reference()
    var postArray: [Post] = []
    dbRef.child("Posts").observeSingleEvent(of: .value, with: { snapshot -> Void in
        if snapshot.exists() {
            if let posts = snapshot.value as? [String:AnyObject] {
                user.getReadPostIDs(completion: { (ids) in
                    for postKey in posts.keys {
                        let post = posts[postKey] as! [String:AnyObject]
                        let username = post["username"] as! String
                        let imagePath = post["imagePath"] as! String
                        let thread = post["thread"] as! String
                        let date = post["date"] as! String
                        let read = ids.contains(postKey)
                        postArray.append(Post(id: postKey, username: username, postImagePath: imagePath, thread: thread, dateString: date, read: read))
                    }
                    completion(postArray)
                })
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    })
}

func getDataFromPath(path: String, completion: @escaping (Data?) -> Void) {
    let storageRef = FIRStorage.storage().reference()
    storageRef.child(path).data(withMaxSize: 5 * 1024 * 1024) { (data, error) in
        if let error = error {
            print(error)
        }
        if let data = data {
            completion(data)
        } else {
            completion(nil)
        }
    }
}


