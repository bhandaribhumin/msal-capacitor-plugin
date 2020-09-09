import Foundation
import Capacitor
import MSAL
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(msal)
public class msal: CAPPlugin {
    var clientID = ""
    var authority = ""
    var redirectURL = ""
    var scope: [String] = []
    private let dateFormatter = ISO8601DateFormatter()
    var accessToken = {};
    override public func load() {
          if #available(iOS 13.0, *) {
               dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
           } else {
               dateFormatter.formatOptions = [.withInternetDateTime]
           }

    }

    @objc func msalInit(_ call: CAPPluginCall) {
         CAPLog.print("msalInit is called")
        guard let KScope = call.getArray("Scope", String.self) else {
                   call.error("Missing Scope argument")
                   return;
        }
         self.scope = KScope
        guard let KClientID = call.getString("ClientID") else {
                  call.reject("ClientID not found")
                  return
              }
        self.clientID = KClientID
           guard let kAuthority = call.getString("Authority") else {
                  call.reject("Authority not found")
                  return
              }
        self.authority = kAuthority
        guard let kRedirectUri = call.getString("RedirectUri") else {
                  call.reject("RedirectUri not found")
                  return
              }
        self.redirectURL = kRedirectUri
        DispatchQueue.main.async {
             CAPLog.print("self.clientID \(self.clientID)")
            call.success([ "clientID": self.clientID ])
        }

        }
      
        @objc func signInInteractive(_ call: CAPPluginCall) {
            
         
        }
        @objc func signInSilent(_ call: CAPPluginCall) {
           
            
        }

        @objc func showAccountsList(_ call: CAPPluginCall) {
              
        }
        @objc func getAccounts(_ call: CAPPluginCall) {
          
            
        }
        @objc func signOut(_ call: CAPPluginCall) {
          
            
        }

    
    private func dateToJS(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    
   private func accessTokenToJson(_ accessToken: Any) -> [String: Any?] {
       return [
           "accessToken": accessToken
       ]
   }

   @objc func getCurrentAccessToken(_ call: CAPPluginCall) {
    if(self.accessToken as AnyObject !== "" as AnyObject){
          call.success()
         return
    }
  
    call.success([ "accessToken": accessTokenToJson(self.accessToken) ])
   }
    
    
    
    

    
        @objc func initMSAL(_ call: CAPPluginCall) {
    
              guard let KClientID = call.getString("ClientID") else {
                call.reject("ClientID not found")
                return
            }
            
    
         guard let kAuthority = call.getString("Authority") else {
                call.reject("Authority not found")
                return
            }
    
            guard let kRedirectUri = call.getString("RedirectUri") else {
                call.reject("RedirectUri not found")
                return
            }
            guard let KScope = call.getArray("Scope", String.self) else {
                              call.error("Missing Scope argument")
                              return;
            }
            if #available(iOS 13.0, *) {
                DispatchQueue.main.async {
                    let MSALAuthenticationObj =  MSALAuthentication()
                    MSALAuthenticationObj.setConfig(call: call, KClientID: KClientID,kAuthority: kAuthority,kRedirectUri: kRedirectUri,kScopes:KScope)
                }
    
            } else {
                // Fallback on earlier versions
            }
        }

       @objc func aquireTokenAsync(_ call: CAPPluginCall) {
           if #available(iOS 13.0, *) {
                DispatchQueue.main.async {
                        //MSALAuthenticationObj.acquireTokenInteractively(viewController: UIViewController,call: call)
                        MSALAuthenticationObj.acquireTokenInteractively()
                }
           }
        } 
    
}
