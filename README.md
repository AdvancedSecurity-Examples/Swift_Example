## Function
* This app is used to generate grocery shopping lists based on the recipes that the user would like to make.
  
## Storyline
* The user authenicates to our server.
* The user then searches for recipes that they would like to make.
* Based on the recipes users can add items to their Kroger cart.

## Dependencies
* Users need a Kroger Account in order to transfer item from our app to Kroger and be able to checkout with their items.

## Compiling
* There are two ways to compile the app. A secure version and an insecure version.
    
## Free or Paid Spoonacular
* If you pay for a spoonacular subscription in order to get more calls per day you will get an api key of length 50. In order to make the app use this key you will need to swap the key in 4 places: 3 in the RecipeInfo.swift file and 1 on the server. In RecipeInfo.swift you will need to change the key wherever it appears in the embeded rapidapi_key variable. This appears in the searchRecipes, getRandomRecipes, and getIngredients functions. On the server you will need to change the node_backend/index.js file located in the android repository. It appears in the rapidapi header.
    
### Secure
* In order to compile the secure version of the app you need to click on the active scheme located to the left of the current emulator (refer to picture below), then go to "Manage Schemes" at the bottom, then select "STTR" and hit edit.
![Screen Shot 2021-07-02 at 1 27 48 PM](https://user-images.githubusercontent.com/70813876/124315613-c9314400-db39-11eb-964f-9aee72a14a4f.png)
* From there select "Archive" on the side bar and change "Build Configuration" to secure. The app is now ready for an .ipa of the secure version.
* Select "Run" on the side bar and change "Build Configuration" to secure to test in the emulator and you may now click close.

### Unsecure
* Go to the insecurities section below and follow the directions to set the flags as you want them.
* In order to compile the secure version of the app you need to click on the active scheme located to the left of the current emulator (refer to picture above), then go to "Manage Schemes" at the bottom, then select "STTR" and hit edit.
* From there select "Archive" from the side bar and change "Build Configuration" to Unsecure. The app is now ready for an .ipa of the unsecure version.
* Select "Run" from the side bar and change "Build Configuration" to Unsecure to test in the emulator and you may now click close.

## Insecurities
* When setting an insecurity, the flags are located in STTR/Pods/Pods-STTR.unsecure.xcconfig file on XCode, which can be found with clicking the folder icon in the top left of the menu.
* A flag will be in the format of "-D (name)_T" or "-D (name)_F"
* Setting the end of the flag to T (true) will include the insecurity in the app, whereas setting the end to F (false) will not include the insecurity.
* The flags are listed towards the end of the file, on the line that starts with "OTHER_SWIFT_FLAGS =".
* Each flag is listed below

#### HTTP
* This flag makes it such that the app communicates with sttr.martincarlisle over HTTP rather than HTTPS.
* The HTTP links are in plaintext as opposed to obfuscated behind AES.
* Used in: CartView.swift, DeactivateAccountView.swift, KrogerAPI.swift, RecipeInfo.swift, Session.swift.

#### EMBED
* This flag makes it such that the API keys are hardcoded into the binary of the app.
* If the flag is false, then the API keys will be recieved from sttr.martincarlisle.
* Used in: KrogerAPI.swift, RecipeInfo.swift.

#### SELFSIGNED and WRONGCERT
* SELFSIGNED will make it so the Accounts page recieves user information from a selfsigned server.
* WRONGCERT will make it so the Accounts page receives user information from a server with the wrong certificate.
* To use SELFSIGNED, set SELFSIGNED to true and WRONGCERT to false. 
* To use WRONGCERT, set both SELFSIGNED and WRONGCERT to true.
* Used in: Networking.swift, Usernameview.swift.

#### EMAIL
* This flag makes it so the app will leak the user's email to the device logs on sign in.
* Used in: Session.swift.

#### PASSWORD
* This flag makes it so the app will leak the user's password to the device logs on sign up.
* Used in: Session.swift.

#### FILE
* This flag makes it so the app will print the user's email to a file on the device at sign in.
* The file is located at Documents/output.txt.
* Used in: Session.swift.

#### KEYBOARD
* This flag makes it so the app will allow the use of third party keyboards.
* Used in: AppDelegate.swift.

#### CRYPTO
* This flag makes it so the app will hash the user's password using MD5. It will then print a hex string of that hash to the device logs on sign in.
* Used in: Session.swift.

#### NSCODING
* This flag makes it so the app will use unsafe NSCoding to make an NSObject of the user.
* This will occur when the user information is loaded in the Accounts page.
* Used in: Usernameview.swift.

#### ZIP
* This flag makes it so the app will download a zip file from sttr.martincarlisle.
* Currently this is downloaded when the Accounts page is loaded. We will move it to the settings menu on a "Check for Update" button.
* This flag is where we use AFNetworking with the insecure flags as well.
* Used in: AppDelegate.swift, Usernameview.swift.

#### LEAK
* This flag makes it so the app will leak the user's zip code, latitutde and longitude (if location services are allowed), display name, first name, last name, full name, phone number, date of birth and email.
* Used in: LocationView.swift, Usernameview.swift
