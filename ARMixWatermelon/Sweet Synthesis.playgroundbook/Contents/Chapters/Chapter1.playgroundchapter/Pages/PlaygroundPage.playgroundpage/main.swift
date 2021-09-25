//#-hidden-code
import UIKit
import SceneKit
import ARKit
import AVFoundation
import PlaygroundSupport
import BookCore
//#-end-hidden-code

/*:
 # Welcome to Sweet Synthesis!
 
 ## Magic dessert merger, the gameplay is simple but fun to stop!
 ✨Please experience the game in full screen✨
 
 Sweet Synthesis is a small game similar to "2048" and "Tetris". Two smaller desserts can be combined into larger desserts, and finally reach the shape of big PIZZA🍕
 
 Now you can hold the iPad and put our 🧺 into real life.
 Then slide down to place the desserts.
 Slide left and right on the screen to change the position of the dessert.
 */

difficultyLevel = /*#-editable-code*/7/*#-end-editable-code*/

//#-hidden-code
PlaygroundPage.current.liveView = instantiateLiveView()
//#-end-hidden-code

/*:
 You can switch the difficulty by changing the number
 The bigger the number, the more difficult it is
 Please enter an integer between 3 and 7✨
 */
