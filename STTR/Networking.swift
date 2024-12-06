//
//  Networking.swift
//  STTR
//
//  Created by Martin Carlisle on 6/11/21.
//

import Foundation

//The following code defines the NSURLSessionPinning Delegate class to implement certificate pinning
//This class is mostly used to enable the self-signed and wrong certificate flagged sections
class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping  (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        
        let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
        let certificate: SecCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
        let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
        let cerPath: String = Bundle.main.path(forResource: "hulkcybr1", ofType: "cer")!
        let localCertificateData = NSData(contentsOfFile:cerPath)!
        //skips past the section that is used for checking if the sertificates are the same
        #if WRONGCERT_T
            let credential:URLCredential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        #endif
        //checks the certificate from the connection and compares it to the hulkcybr1.cer file
        //connects if they are the same
        if (remoteCertificateData.isEqual(localCertificateData as Data) == true) {
            let credential:URLCredential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
         
        } else {
            challenge.sender?.cancel(challenge)
            completionHandler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
        }
        
    }
    
}
