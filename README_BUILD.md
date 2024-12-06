## Install Xcode
* The first step to build and run the app is to install Xcode. To do this you will need to go to the Mac App Store and download Xcode. If your mac has the M1 chip in it you may need to download the beta version of Xcode in order to get the app to compile.
* Note, Xcode is only available on Mac devices.

## Download The Code
* Once you have Xcode installed you need to download the code for the app from the github. Go to the most recent release, found on the right side, and download the source code zip file. Unzip that file and open the file "STTR.xcworkspace." This should open the project in Xcode.

## Compile and Run the app
### Run on an Emulator
* Select your preferred iOS version and emulator from the emulator selection drop-down menu at the top of the Xcode window.
* Do not select "Any ios Device (arm64)"
* On the top bar select Product > Run (shortcut: ⌘ + R). This will build the code and run the app on your selected emulator once it is finished. 
![Screen Shot 2021-07-20 at 10 44 51 AM](https://user-images.githubusercontent.com/13321541/126357545-55d9c143-d0cc-4611-a723-3104e45d0a50.png)
### Run on a Physical Device
* Plug your device into the Mac.
* From the emulator selection drop-down menu at the top of the Xcode window select your physically connected device.
* On the top bar select Product > Run (shortcut: ⌘ + R). This will build the code and run the app on your selected device once it is finished. 
![Screen Shot 2021-07-20 at 10 44 51 AM](https://user-images.githubusercontent.com/13321541/126357545-55d9c143-d0cc-4611-a723-3104e45d0a50.png)

## Compile an IPA
### Secure
* In order to compile the secure version of the app you need to click on the active scheme located to the left of the current emulator (refer to picture below), then go to "Manage Schemes" at the bottom, then select "STTR" and hit edit.
![Screen Shot 2021-07-02 at 1 27 48 PM](https://user-images.githubusercontent.com/70813876/124315613-c9314400-db39-11eb-964f-9aee72a14a4f.png)
* From there select "Archive" on the side bar and change "Build Configuration" to secure. The app is now ready for an .ipa of the secure version.
* From the top bar select Product > Clean Build Folder. 
* From the emulator selection drop-down menu at the top of the Xcode window select "Any ios Device (arm64)"
* From the top bar select Product > Archive. This will take a while.
* Once completed, a new window will appear. Select "Distribute App." 
* From the next menu select "Development." 
* For the options select "App Thinning: None." Make sure that "Rebuild from Bitcode" and "Include manifest for over-the-air installation" are both deselected. 
* Choose "Automatically manage signing."
* Select "Export"
* Choose where to save the IPA. 

### Unsecure
* Go to the insecurities section below and follow the directions to set the flags as you want them.
* In order to compile the secure version of the app you need to click on the active scheme located to the left of the current emulator (refer to picture above), then go to "Manage Schemes" at the bottom, then select "STTR" and hit edit.
* From there select "Archive" from the side bar and change "Build Configuration" to Unsecure. The app is now ready for an .ipa of the unsecure version.
* From the top bar select Product > Clean Build Folder. 
* From the emulator selection drop-down menu at the top of the Xcode window select "Any ios Device (arm64)"
* From the top bar select Product > Archive. This will take a while.
* Once completed, a new window will appear. Select "Distribute App." 
* From the next menu select "Development." 
* For the options select "App Thinning: None." Make sure that "Rebuild from Bitcode" and "Include manifest for over-the-air installation" are both deselected. 
* Choose "Automatically manage signing."
* Select "Export"
* Choose where to save the IPA. 

## Select a Build Scheme
### Secure
* In order to compile the secure version of the app you need to click on the active scheme located to the left of the current emulator (refer to picture below), then go to "Manage Schemes" at the bottom, then select "STTR" and hit edit.
![Screen Shot 2021-07-02 at 1 27 48 PM](https://user-images.githubusercontent.com/70813876/124315613-c9314400-db39-11eb-964f-9aee72a14a4f.png)
* From there select "Run" on the side bar and change "Build Configuration" to "Secure".
* The app is now ready to be run as the secure version.
### Unsecure
* In order to compile the secure version of the app you need to click on the active scheme located to the left of the current emulator (refer to picture below), then go to "Manage Schemes" at the bottom, then select "STTR" and hit edit.
![Screen Shot 2021-07-02 at 1 27 48 PM](https://user-images.githubusercontent.com/70813876/124315613-c9314400-db39-11eb-964f-9aee72a14a4f.png)
* From there select "Run" on the side bar and change "Build Configuration" to "Unsecure".
* The app is now ready to be run as the unsecure version.
* In order to customize what vulnerabilities are being demonstrated go to the Vulnerabilities section below

## Vulnerabilities
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
