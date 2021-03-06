//
//  TMDBConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension TMDBClient {
    
    // MARK: Authentication (GET) Methods
    /*
        Steps for Authentication...
        https://www.themoviedb.org/documentation/api/sessions
        
        Step 1: Create a new request token
        Step 2a: Ask the user for permission via the website
        Step 3: Create a session ID
        Bonus Step: Go ahead and get the user id 😄!
    */
    func authenticateWithViewController(_ hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // chain completion handlers for each request so that they run one after the other
        getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                // success! we have the requestToken!
                print(requestToken ?? "Could not print requestToken")
                self.requestToken = requestToken
                
                self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
                    if success {
                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                // success! we have the sessionID!
                                self.sessionID = sessionID
                                
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            // and the userID 😄!
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandlerForAuth(success, errorString)
                                }
                            } else {
                                completionHandlerForAuth(success, errorString)
                            }
                        }
                    } else {
                        completionHandlerForAuth(success, errorString)
                    }
                }
            } else {
                completionHandlerForAuth(success, errorString)
            }
        }
    }
    
    private func getRequestToken(_ completionHandlerForToken: @escaping (_ success: Bool, _ requestToken: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        let method = Methods.AuthenticationTokenNew
        let parameters = [String:AnyObject]()
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */

        let _ = taskForGETMethod(method, parameters: parameters) { (results, error) in
            if let error = error {
                print(error)
                completionHandlerForToken(false, nil, "Login failed: Unable to get valid results for request token")
            } else {
                if let request_token = results?[JSONResponseKeys.RequestToken] as? String {
                    completionHandlerForToken(true, request_token, nil)
                } else {
                    print("Could not find request token in results")
                    completionHandlerForToken(false, nil, "Loging failed: Unable to get request token from results")
                }
            }
        }
 
    }
    
    private func loginWithToken(_ requestToken: String?, hostViewController: UIViewController, completionHandlerForLogin: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let authorizationURL = URL(string: "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)")
        let request = URLRequest(url: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewController(withIdentifier: "TMDBAuthViewController") as! TMDBAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = requestToken
        webAuthViewController.completionHandlerForView = completionHandlerForLogin
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        performUIUpdatesOnMain {
            hostViewController.present(webAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    private func getSessionID(_ requestToken: String?, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        let parameters = [ParameterKeys.RequestToken: requestToken! as AnyObject]
        let method = Methods.AuthenticationSessionNew
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
        let _ = taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            // Check for error
            if let error = error {
                print(error)
                completionHandlerForSession(false, nil, "Login failed: Unable to get a session ID")
            } else {
                // Try to get session id out
                if let session_id = results?[JSONResponseKeys.SessionID] as? String {
                    print(session_id)
                    completionHandlerForSession(true, session_id, nil)
                } else {
                    print("Unable to find session id in results")
                    completionHandlerForSession(false, nil, "Login failed: Unable to get session ID from results")
                }
            }
        }

    }
    
    private func getUserID(_ completionHandlerForUserID: @escaping (_ success: Bool, _ userID: Int?, _ errorString: String?) -> Void) {
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        let parameters = [ParameterKeys.SessionID: TMDBClient.sharedInstance().sessionID! as AnyObject]
        let method = Methods.Account

        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
        let _ = taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            // Check for error
            if let error = error {
                print(error)
                completionHandlerForUserID(false, nil, "Login failed: Unable to get a user id")
            } else {
                if let user_ID = results?[JSONResponseKeys.UserID] as? Int {
                    print(user_ID)
                    completionHandlerForUserID(true, user_ID, nil)
                } else {
                    print("Unable to get the user id from results")
                    completionHandlerForUserID(false, nil, "Login failed: Unable to get a user id from results")
                }
            }
        }

    }
    
    // MARK: GET Convenience Methods
    
    func getFavoriteMovies(_ completionHandlerForFavMovies: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
    }
    
    func getWatchlistMovies(_ completionHandlerForWatchlist: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
    }
    
    func getMoviesForSearchString(_ searchString: String, completionHandlerForMovies: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        return nil
    }
    
    func getConfig(_ completionHandlerForConfig: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
    }
    
    // MARK: POST Convenience Methods
    
    func postToFavorites(_ movie: TMDBMovie, favorite: Bool, completionHandlerForFavorite: @escaping (_ result: Int?, _ error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
    }
    
    func postToWatchlist(_ movie: TMDBMovie, watchlist: Bool, completionHandlerForWatchlist: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        
    }
}
