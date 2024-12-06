/*
 Author: Joseph Iglecias
 Creation Date:
    June 9, 2021
 
 Automation for:
    STTR Rescript
 
*/

import XCTest
import UIKit
import Foundation

extension StringProtocol { // for Swift 4 you need to add the constrain `where Index == String.Index`
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}

extension XCUIElement {
    func forceTap() {
        _ = waitForExistence(timeout: 45)
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(2)
    }//forceTap.close
    
    func forceDoubleTap() {
        _ = waitForExistence(timeout: 45)
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).doubleTap()
        sleep(2)
    }//forceTap.close
    
    //Only tap an element if it exist. This is useful
    //for permissions that are not handled by the listener.
    func ifTap() {
        if exists {
            tap()
        }
    }//forceTap.close
    
    func forceTap3() {
        _ = waitForExistence(timeout: 45)
     coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 1.00)).tap()
    }//forceTap.close
    
    func tapCoordinate(at point: CGPoint) {
         let normalized = coordinate(withNormalizedOffset: .zero)
         let offset = CGVector(dx: point.x, dy: point.y)
         let coordinate = normalized.withOffset(offset)
         coordinate.tap()
     }
    
    func doubleTapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let offset = CGVector(dx: point.x, dy: point.y)
        let coordinate = normalized.withOffset(offset)
        coordinate.doubleTap()
    }
    
     func hasFocus() -> Bool {
         return self.value(forKey: "hasKeyboardFocus") as? Bool ?? false
     }
    
     func clearAndEnterText(text: String) {
         guard let stringValue = self.value as? String else {
             XCTFail("Tried to clear and enter text into a non string value")
             return
         }

         self.tap()

         let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

         self.typeText(deleteString)
         self.typeText(text)
     }
    
}//ext.XCUIElement.close

extension XCUIApplication {
    
    /*
     Function to clear text from a field if any text is found
     To call - use - app.clearText(app.elementDescription)
     */
    func clearText(_ element: XCUIElement){
        guard let stringValue = element.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }// Make sure we are actually looking at a string element
        
        //We need to check if there is anything already in the field
        if stringValue.count > 0 {
            
            //initial press to activate the "select all" option sometimes it highlights a word or letter
            element.press(forDuration: 1)
            if(menuItems["Select All"].exists){
                menuItems["Select All"].tap()
                menuItems["Cut"].tap()
            }//if.if.close
                
            // Try a press again if we didn't get it to work properly the first time.
            else{
                element.press(forDuration: 1)
                menuItems["Select All"].tap()
                menuItems["Cut"].tap()
            }//if.else.close
        }//if.close
    }//clearText.close
    
    /*
     Function to print debug tree
     To call - use - app.showDebugTree()
     */
    func showDebugTree() {
        print("\n\nTree Start\n\n" + debugDescription + "\n\nTree End\n\n")
    }//showDebugTree.close
    
    /*
     Function to see the printout of a specific type of element.
     Sometimes we don't need to see all of them.
     To call - use - app.elementTree("element")
     */
    func elementTree(_ element: String) {
        
        print("\n\n\t" + element + " Element List Start\n\n")
        
        
        switch element {
            
        case "staticTexts":
            print(staticTexts.element.debugDescription)
            
        case "buttons":
            print(buttons.element.debugDescription)
            
        case "cells":
            print(cells.element.debugDescription)
            
        case "tables":
            print(tables.element.debugDescription)
            
        case "otherElements":
            print(otherElements.element.debugDescription)
            
        default:
            print("\n\n*** Element not found: Call to elementTree - " + element + "***\n\n")
        }//switch.close
        
        print("\n\n\t" + element + " Element List End\n\n")
    }//elementTree.close
    
}//ext.XCUIApplication.close

extension appAutomation {
    /*
     Waits a specified time interval for an element to show.
     Once element is found the line will be passed.
     */
    func waitForElementToAppear(_ element: XCUIElement, _ timeout: TimeInterval) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }//waitForElementToAppear.close
    
    /*
    This ensures that the screenshot is retained
    */
   func takeScreenshot(_ app: XCUIApplication) {
       let finalScreenshot = app.screenshot()
       let attachment = XCTAttachment(screenshot: finalScreenshot);
       add(attachment);
   }//takeScreenshot.close
    
    /*
     This can be used in place of sleep() and will wait without blocking the
     thread.  Normally an expectation like this would fail, but by setting
     isInverted = true we indicate that we expect failure.  This prevents
     the test from failing when the timeout hits.
     https://developer.apple.com/documentation/xctest/xctestexpectation/2806573-inverted?language=objc
     */
    func arbitraryWait(_ timeout: TimeInterval) {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
    }//arbitraryWait.close
}//ext.UITest.close

//Main Class
class appAutomation: XCTestCase {
    
    //Don't change this for now
    override func setUp() {
        // uncomment this if the app uses WKWebView
        workaroundWKWebView()
        relaxTimeouts()
        super.setUp()
    }

    func workaroundWKWebView() {
        // This is needed for making WKWebView queries work on iOS 13.3
        let original = class_getInstanceMethod(objc_getClass("XCAXClient_iOS") as? AnyClass, Selector(("defaultParameters")))
        let replaced = class_getInstanceMethod(type(of: self), #selector(appAutomation.replaceDefaultParameters))!
        method_exchangeImplementations(original!, replaced)
    }
    
    func relaxTimeouts() {
        setInternalTimeout("_XCTSetApplicationStateTimeout", 600.0)
        setInternalTimeout("_XCTSetAXIPCTimeout", 600.0)
        setInternalTimeout("_XCTSetEventConfirmationTimeout", 600.0)
        setInternalTimeout("_XCTSetXPCRequestTimeout", 600.0)
        setInternalTimeout("_XCTSetMainThreadResponsivenessCheckTimeout", 600.0)
    }
        
    func setInternalTimeout(_ symbolName: String, _ timeout: Double) {
        let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
        typealias SetTimeoutFunc = @convention(c) (CDouble) -> Void
        
        let sym = dlsym(RTLD_DEFAULT, symbolName)
        if sym != nil {
            let setTimeoutFunc = unsafeBitCast(sym, to: SetTimeoutFunc.self)
            setTimeoutFunc(timeout)
            print("\(symbolName) set to \(timeout)\n")
        } else {
            print("Private symbol \(symbolName) not found")
        }
    }
    
    @objc func replaceDefaultParameters() -> NSDictionary {
        let dictionary: NSDictionary = [
            "maxArrayCount" : 2147483647,
            "maxChildren" : 2147483647,
            "maxDepth" : 100, // this is the important one for WKWebView on iOS 13.3
            "snapshotKeyHonorModalViews" : false,
            "traverseFromParentsToChildren": true
        ]
    
        return dictionary
    }
    
    //Don't change this for now
    override func tearDown() {
        super.tearDown()
    }//tearDown.close
    
    //Main Test Functionality
    func testExample() {
        
        
        /* Creates a listener to look for alert windows. Takes the action specified based on the alert buttons
         
            If you find that overlapping alerts are blocking the handler, try adding an arbitraryWait() before activating the listener via app.swipeUp() to allow all the alerts to surface before the handler is invoked.
        */
        _ = addUIInterruptionMonitor(withDescription: "System alert") { (alert) -> Bool in
            
            
            //you can reuse this if statement as much as you want for as many alert windows as you have.
            if alert.buttons["Always Allow"].exists {
                alert.buttons["Always Allow"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Allow While Using App"].exists {
                alert.buttons["Allow While Using App"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Allow Once"].exists {
                alert.buttons["Allow Once"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Upgrade Later"].exists {
                alert.buttons["Upgrade Later"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Continue"].exists {
                alert.buttons["Continue"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Cancel"].exists {
                alert.buttons["Cancel"].tap()
                return true
            }//listener.if.close
                
            else if alert.buttons["Not now"].exists {
                alert.buttons["Not now"].tap()
                return true
            }//listener.if.close
            
            else { return false }
        }//listener.close
        
        //specify what app is getting launched/tested
        let app = XCUIApplication(bundleIdentifier: "edu.tamu.STTRIOSApp")

        //set orientation
        XCUIDevice.shared.orientation = .portrait

        //launch the correct app

        app.launch()
 
        // Custom automation
        waitForElementToAppear(app.textFields.element(boundBy: 0), 30)
        app.textFields.element(boundBy: 0).tap()
        app.typeText("the_doctor@tamu.edu")

        waitForElementToAppear(app.secureTextFields.element(boundBy: 0), 30)
        app.secureTextFields.element(boundBy: 0).tap()
        app.typeText("MyNewPass")

        app.buttons["Login"].tap()
        
        arbitraryWait(5)
        waitForElementToAppear(app.textFields.element(boundBy: 0), 30)
        app.textFields.element(boundBy: 0).tap()
        app.typeText("chicken")
        
        // Search button on textfield
        waitForElementToAppear(app.buttons["return"], 30)
        app.buttons["return"].tap()
        
        // Clicks on first item with "Chicken"
        let firstImage = app.images.element(boundBy: 0)
        waitForElementToAppear(firstImage, 30)
        firstImage.tap()
        
        // Opens See Ingredients Page
        waitForElementToAppear(app.otherElements.buttons["See Ingredients"], 30)
        app.otherElements.buttons["See Ingredients"].tap()
        arbitraryWait(10)
        
        // Selects a few ingredients to cart
        waitForElementToAppear(app.buttons["SELECT"], 30)
        app.buttons.element(boundBy: 1).tap()
        arbitraryWait(2)
        app.buttons.element(boundBy: 2).tap()
        arbitraryWait(2)
        app.buttons.element(boundBy: 3).tap()
        arbitraryWait(5)
        
        // Selects "back" button
        app.buttons.element(boundBy: 0).tap()
        arbitraryWait(5)
        
        // Selects "menu" button
        app.buttons.element(boundBy: 0).tap()
        arbitraryWait(5)
        
        // Access contacts alert
        app.tap()
        
        // Clicks on Cart
        waitForElementToAppear(app.buttons["Cart"], 30)
        app.buttons["Cart"].tap()
        arbitraryWait(5)
        
        // alert
        app.tap()
        
        // Finds stores
        waitForElementToAppear(app.buttons["Press to find stores"], 30)
        app.buttons["Press to find stores"].firstMatch.tap()
        
        // Zip code field
        waitForElementToAppear(app.textFields.element(boundBy: 0), 30)
        app.textFields.element(boundBy: 0).tap()
        app.typeText("77840")
        
        // Searches
        app.buttons["magnifyingglass"].tap()
        
        // Selects Specific Kroger
        waitForElementToAppear(app.staticTexts["Kroger - Rock Prairie"], 30)
        app.staticTexts["Kroger - Rock Prairie"].tap()
        
        // Goes Back
        app.buttons["Back"].tap()
        
        // Clicks on all purpose flour
        //app.buttons["all purpose flour"].tap()
        app.buttons.element(boundBy: 2).tap()
        // Clicks on first ingredient
        waitForElementToAppear(firstImage, 30)
        firstImage.tap()
        
        // Goes Back
        app.buttons["Back"].tap()
        
        //FIXME
        //There appears to be a bug. When you click the "add to cart" nothing happens
        // Add to cart
        waitForElementToAppear(app.buttons["Add To Kroger Cart"], 30)
        app.buttons["Add To Kroger Cart"].tap()
        
        // We are going to create a loop that waits for the element to appear.
        //If we fail to find the element then the script will complete successfully.
        var loopVariable = 0
        while loopVariable < 10 && !app.textFields.element(boundBy: 0).exists {
            arbitraryWait(3)
            loopVariable += 1
        }//while.close
        
        //We will wrap the final actions in this if statement.
        //There is no point in attempting these actions if the bug exist.
        if app.textFields.element(boundBy: 0).exists {
            
            // Kroger username
            app.textFields.element(boundBy: 0).tap()
            app.typeText("igleciasjoseph@gmail.com")
            
            // Kroger username
            waitForElementToAppear(app.secureTextFields.element(boundBy: 0), 30)
            app.secureTextFields.element(boundBy: 0).tap()
            app.typeText("Tl66100811534!!")
            
            // Sign in
            waitForElementToAppear(app.otherElements.buttons["Sign In"], 30)
            app.otherElements.buttons["Sign In"].tap()
            
            // Authorize
            var loopVariable_Authorize = 0
            while loopVariable_Authorize < 10 && !app.buttons["Authorize"].exists {
                arbitraryWait(2)
                loopVariable_Authorize += 1
            }//while.close
            
            if app.buttons["Authorize"].exists {
                app.buttons["Authorize"].tap()
            }//if_Authorize.close
        }//if_textFields.close
        
        //Click through account to see if any info appears in artifact files.
        waitForElementToAppear(app.buttons["Search Recipes"], 30)
        app.buttons["Search Recipes"].tap()
 
        waitForElementToAppear(app.buttons["Account"], 30)
        app.buttons["Account"].tap()
        
        waitForElementToAppear(app.textFields.element(boundBy: 3), 30)
        app.textFields.element(boundBy: 3).tap()
        arbitraryWait(1)
        app.textFields.element(boundBy: 3).press(forDuration: 2)
        arbitraryWait(1)
        app.keys["delete"].tap()
        arbitraryWait(1)
        
        app.typeText("936-870-6140")
        arbitraryWait(2)
        app.buttons["Hide keyboard"].firstMatch.ifTap()
        
        waitForElementToAppear(app.buttons["SAVE"], 30)
        app.buttons["SAVE"].tap()
        
        waitForElementToAppear(app.buttons["Search Recipes"], 30)
        app.buttons["Search Recipes"].tap()
        
        waitForElementToAppear(app.buttons["Settings"], 30)
        app.buttons["Settings"].tap()
        
        waitForElementToAppear(app.buttons["Security Settings"], 30)
        app.buttons["Security Settings"].tap()
        
        waitForElementToAppear(app.buttons["Settings"], 30)
        app.buttons["Settings"].tap()
        
        waitForElementToAppear(app.buttons["Payment Settings"], 30)
        app.buttons["Payment Settings"].tap()
        
        waitForElementToAppear(app.buttons["Receipt Method"], 30)
        app.buttons["Receipt Method"].tap()
        
        waitForElementToAppear(app.buttons["Phone"], 30)
        app.buttons["Phone"].tap()
        
        waitForElementToAppear(app.buttons["Settings"], 30)
        app.buttons["Settings"].tap()
        
        waitForElementToAppear(app.buttons["Search Recipes"], 30)
        app.buttons["Search Recipes"].tap()
        
        waitForElementToAppear(app.buttons["Sign Out"], 30)
        app.buttons["Sign Out"].tap()
        
    }//testExample.close
}//class.close
