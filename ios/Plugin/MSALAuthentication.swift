//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------
import Foundation
import Capacitor
import UIKit
import MSAL

/// 😃 A View Controller that will respond to the events of the Storyboard.

class MSALAuthentication:UIViewController {
     typealias JSObject = [String:Any]
    // Update the below to your client ID you received in the portal. The below is for running the demo only
       var kClientID = ""
       var kGraphEndpoint = "https://graph.microsoft.com/"
       var kAuthority = ""
       var kRedirectUri = "msauth://auth"
       
       var kScopes: [String] = ["user.read","Calendars.Read","Calendars.ReadWrite"]
       
       var accessToken = String()
       var applicationContext : MSALPublicClientApplication?
       var webViewParamaters : MSALWebviewParameters?
        var call: CAPPluginCall?
       var currentAccount: MSALAccount?
       
    
        func setConfig(call: CAPPluginCall,  KClientID: String,kAuthority: String,kRedirectUri: String,kScopes: Array<String>?) {
              CAPLog.print("i am in setConfig");
              self.call = call
              self.kClientID = KClientID
            
              self.kAuthority = kAuthority
            self.kScopes = kScopes ?? ["user.read"]
               CAPLog.print("kClientID fn: \(kClientID)");
               CAPLog.print("kRedirectUri fn: \(kRedirectUri)");
              self.kRedirectUri =  kRedirectUri
             
           do {
                                 try self.initMSAL()
                             } catch let error {
                                 self.updateLogging(text: "Unable to create Application Context \(error)")
                             }
             self.loadCurrentAccount()
          }
    
    @objc func initMSAL() throws {
         CAPLog.print("kAuthority fn: \(self.kAuthority)");
            guard let authorityURL = URL(string: kAuthority) else {
                  self.updateLogging(text: "Unable to create authority URL")
                  return
              }
              let authority = try MSALAADAuthority(url: authorityURL)
              
              let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                        redirectUri: kRedirectUri,
                                                                        authority: authority)
              self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
              self.initWebViewParams()
        self.acquireTokenInteractively()
    }
    
    func initWebViewParams() {
         CAPLog.print("i am in initWebViewParams");
      self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }

    
    /**
     This will invoke the authorization flow.
     */
    
    @objc func callGraphAPI() {
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively()
                return
            }
            
            self.acquireTokenSilently(currentAccount)
        }
    }
    //viewController: bridge.viewController
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
             //self.call.success(["accessToken": result.accessToken])
            self.updateLogging(text: "Access token is \(self.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                 print("Could not acquire token silently: \(error)")
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            var ret = JSObject()
            ret["accessToken"] = result.accessToken
                      // ret["fullName"] = appleIDCredential.fullName?.description ?? "N/A"
                      // ret["email"] = appleIDCredential.email ?? "N/A"
                     //  ret["realUserStatus"] = appleIDCredential.realUserStatus.rawValue
                     //  ret["identityTokenString"] = self.identityTokenString as Any
            // self.call.success(["accessToken": result.accessToken])
            self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
            self.getContentWithToken()
        }
    }
    
    func getGraphEndpoint() -> String {
        return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
    }
    
    /**
     This will invoke the call to the Microsoft Graph API. It uses the
     built in URLSession to create a connection.
     */
    
    func getContentWithToken() {
        
        // Specify the Graph API endpoint
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                self.updateLogging(text: "Couldn't deserialize result JSON")
                return
            }
            
            self.updateLogging(text: "Result from Graph: \(result))")
            
            }.resume()
    }


    
    typealias AccountCompletion = (MSALAccount?) -> Void

    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
                
        // Note that this sample showcases an app that signs in a single account at a time
        // If you're building a more complex app that signs in multiple accounts at the same time, you'll need to use a different account retrieval API that specifies account identifier
        // For example, see "accountsFromDeviceForParameters:completionBlock:" - https://azuread.github.io/microsoft-authentication-library-for-objc/Classes/MSALPublicClientApplication.html#/c:objc(cs)MSALPublicClientApplication(im)accountsFromDeviceForParameters:completionBlock:
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                
                self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                
                self.updateCurrentAccount(account: currentAccount)
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                return
            }
            
            self.updateLogging(text: "Account signed out. Updating UX")
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    /**
     This action will invoke the remove account APIs to clear the token cache
     to sign out a user from this application.
     */
    @objc func signOut() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount else { return }
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.updateLogging(text: "Couldn't sign out account with error: \(error)")
                    return
                }
                
                self.updateLogging(text: "Sign out completed successfully")
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)
            })
            
        }
    }

    
    func updateLogging(text : String) {
        
        if Thread.isMainThread {
             CAPLog.print(text)
        } else {
            DispatchQueue.main.async {
                CAPLog.print(text)
            }
        }
    }
    
   
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
}
