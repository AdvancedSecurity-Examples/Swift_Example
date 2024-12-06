//
//  StaticDatabase.swift
//  STTR
//
//  Created by Martin Carlisle on 6/11/21.
//

import Foundation

//struct used to hold spoonacular and kroger information
//necessary for passing data between different sections of the code
struct Database{
    static var recipe : RecipeInfo = RecipeInfo()
    static var kroger : KrogerAPI = KrogerAPI()
}



//This potentially opens up vunerabilities with mispackaged certificates. For example, say the following certificate was included for development but not removed
//Certificate created with openssl
// openssl s_client -connect my-http-website.com:443 -showcerts < /dev/null | openssl x509 -outform DER > my-http-website.der




