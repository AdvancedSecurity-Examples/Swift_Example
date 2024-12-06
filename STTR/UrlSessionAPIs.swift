//
//  UrlSessionAPIs.swift
//  STTR
//
//  Created by Jeb Malek on 5/27/21.
//

import UIKit
import FirebaseAuth

//urlSession Class
//used to get data from urls
//specifically used to interact with the docker server
class urlSesssion{
    
//    main function of the class
//    used to return the return value from a
//    url passed as a string
//    usage: getData(from: {URL}) returns: response
//    should be called inside of a dispatch queue in order
//    to guaruntee the response is returned correctly
    func getData(from: String) -> String{ //passing in a string
        guard let url = URL(string: from) else{ //sets url to the URL type from the string passed in
            return "ERROR"
        }
        var apiResponse: String = "error"
        let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDToken() { idToken, error in //used to get token from firebase in order to authenticate user with server
            if let error = error {
            return
            }

              // Send token to your backend via HTTPS
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(idToken, forHTTPHeaderField: "idToken")
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                guard let data = data, error == nil else{ //makes sure the data is not nil and error is nil
                    return
                }
                var result: Response? //got to the data response
                do{
                    result = try JSONDecoder().decode(Response.self, from: data) //converting bytes to actual readable data
                    guard let json = result else {
                        return //if we have gotten this far we have our object which is the Result? type
                    }
                    apiResponse = json.responded
                }
                catch{
                    do {
                        apiResponse = String(data: data, encoding: .utf8)! //this fixes the error when the response comes back as a string!
                    }
                }
                semaphore.signal() //task completed so we can stop waiting
            })
            URLCache.shared.removeAllCachedResponses()
            task.resume()
        }
        _ = semaphore.wait(wallTimeout: .distantFuture) // wait for the task to be completed before returning
        return apiResponse
    }
    
    //alternative getData function used to deal with some multithreading issues
    //passes in dispatch group in order to force a wait on the data
    func getData(from: String, group: DispatchGroup) -> String{ //passing in a string
        guard let url = URL(string: from) else{ //sets url to the URL type from the string passed in
            return "ERROR"
        }
        var apiResponse: String = "error"
        let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
        let currentUser = Auth.auth().currentUser
                currentUser?.getIDToken(completion: { idToken, error in
                if let _ = error{
                    return
                }

                  // Send token to your backend via HTTPS
                  // ...
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                    guard let data = data, error == nil else{ //makes sure the data is not nil and error is nil
                        return
                    }
                    var result: Response? //optional .. ?//got to the data response
                    do{
                        result = try JSONDecoder().decode(Response.self, from: data) //converting bytes to actual readable data
                        guard let json = result else {
                            return //if we have gotten this far we have our object which is the Result? type
                        }
                        apiResponse = json.responded
                    }
                    catch{
                        do {
                            apiResponse = String(data: data, encoding: .utf8)! //this fixes the error when the response comes back as a string!
                        }
                    }
                    semaphore.signal() //task completed so we can stop waiting
                    group.leave()
                })
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            })
        
        _ = semaphore.wait(wallTimeout: .distantFuture) // wait for the task to be completed before returning
        return apiResponse
    }
    
    //Used to store response from url
    public struct Response: Codable { //Codable by Swift,, lets data returned by a network call be passed into the struct with its protocol
        let responded : String
    }
}
