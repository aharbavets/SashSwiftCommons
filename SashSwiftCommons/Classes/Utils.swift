//
// Created by Alexander Gorbovets on 03.03.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation
import UIKit
import LayerKit
import MediaPlayer
import ImageIO
import Photos
import AssetsLibrary

class Utils {

    static func spacer() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    }

    static func alert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    static func confirmation(title title: String, message: String, destructiveButtonTitle: String, controller: UIViewController, onConfirm: (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: destructiveButtonTitle, style: .Destructive, handler: onConfirm))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            controller.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    // todo rename to reportError
    static func showError(error: ErrorType?, _ message: String) {
        NSLog("Error: \(message), \(error)")
        var msg = message
        #if DEBUG
            if let error = error {
                msg += ": \(error)"
            }
        #else
            msg += ". Something went wrong. Please, try later when internet connection will be available or contact developer"
        #endif
        
        Utils.alert(msg)
    }

    static func normalRandom() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }

    static func randomFromList<T>(list: [T]) -> T? {
        if list.count == 0 {
            return nil
        }
        let index = arc4random_uniform(UInt32(list.count))
        return list[Int(index)]
    }

    static func twoLetterAbbreviation(value: String) -> String {
        let parts = value.characters.split{$0 == " "}.map{String($0)}
        let words: [String]
        switch parts.count {
            case 0: words = []
            case 1: words = Array(parts[0...0])
            default: words = Array(parts[0...1])
        }
        return words
            .filter{ return $0.characters.count > 0 }
            .map{ return String($0.characters[$0.startIndex]).uppercaseString }
            .joinWithSeparator("")
    }

    static func loadViewFromNib(nibName: String, owner: AnyObject) -> UIView {
        let views = NSBundle.mainBundle().loadNibNamed(nibName, owner: owner, options: nil)
        return views[0] as! UIView
    }

    static func randomThreadColorIndex() -> Int {
        return Int(arc4random_uniform(UInt32(Colors.threadColors.count)))
    }

    static func formatHoursMinutesSeconds(s: Double, showCentiSeconds: Bool = false, leadingMinuteZero: Bool = true) -> String {
        var secondsF = s
        let negative = secondsF < 0
        secondsF = abs(secondsF)
        let secondsI = Int(floor(secondsF))
        let hours = secondsI / 3600
        let minutes = secondsI % 3600 / 60
        let seconds = secondsI % 3600 % 60
        var parts = [
            String(format: leadingMinuteZero ? "%02d" : "%d", minutes),
            String(format: "%02d", seconds),
        ]
        if hours > 0 {
            parts.insert(String(format: "%02d", hours), atIndex: 0)
        }
        var result = parts.joinWithSeparator(":")
        if showCentiSeconds {
            let centiseconds = Int((secondsF - Double(secondsI)) * 100)
            result += "." + String(format: "%02d", centiseconds)
        }
        if negative {
            result = "-\(result)"
        }
        return result
    }

    static func systemFontWithMonospacedNumbers(size: CGFloat) -> UIFont {
        let features = [
            [
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ]
        ]

        let fontDescriptor = UIFont.systemFontOfSize(size).fontDescriptor().fontDescriptorByAddingAttributes(
            [UIFontDescriptorFeatureSettingsAttribute: features]
        )

        return UIFont(descriptor: fontDescriptor, size: size)
    }

    static func calculateHeightForDimensions(size: CGSize, screenWidth: CGFloat) -> CGFloat {
        return screenWidth * (size.height / size.width)
    }

    static func verticalLine(x x: CGFloat, y1: CGFloat, y2: CGFloat, thickness: CGFloat) -> CGRect {
        return CGRect(x: x - thickness / 2.0, y: y1, width: thickness, height: y2 - y1)
    }
    
    static func horizontalLine(x1 x1: CGFloat, x2: CGFloat, y: CGFloat, thickness: CGFloat) -> CGRect {
        return CGRect(x: x1, y: y - thickness / 2.0, width: x2 - x1, height: thickness)
    }

    static func rectangle(centerX centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: centerX - width / 2.0, y: centerY - height / 2.0, width: width, height: height)
    }

    static let hundredPercents = 100

    static func audioPowerToDecibels(value: Float) -> Float {
        return 20 * log10(value);
    }

    static func convertDecibellsToPercents(decibels: Float) -> Float {
        var result: Float
        let minDecibels: Float = -80.0
        if decibels < minDecibels {
            result = 0.0
        } else if decibels >= 0.0 {
            result = 1.0
        } else {
            result = (decibels - minDecibels) / abs(minDecibels)
        }
        result = result * Float(Utils.hundredPercents) // convert into percents
        if result.isNaN {
            result = 0
        }
        return result
    }
    
    static func getDocsDir() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return dirPaths[0]
    }

    static let tmpFilePrefix = "tmp."
    
    static func generateTemporaryFilePathWithExtension(ext: String, removeAfterSeconds: UInt64 = 0) -> NSURL {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let uuid = NSUUID().UUIDString
        let name = "\(tmpFilePrefix)\(uuid).\(ext)"
        let result = NSURL(fileURLWithPath: Utils.getDocsDir()).URLByAppendingPathComponent(name)
        NSLog("Temporary file name: \(result.absoluteString)")

        if removeAfterSeconds > 0 {
            Utils.delayBy(Double(removeAfterSeconds)) {
                let manager = NSFileManager.defaultManager()
                if manager.fileExistsAtPath(result.absoluteString) {
                    try! manager.removeItemAtPath(result.absoluteString)
                }
            }
        }

        return result
    }
    
    static func cleanupTemporaryFiles() {
        let manager = NSFileManager.defaultManager()
        let docsDir = Utils.getDocsDir()
        let paths = (try? manager.contentsOfDirectoryAtPath(docsDir)) ?? [String]()
        paths.filter{
            fileName in
            let prefixRegex = NSRegularExpression.escapedPatternForString(tmpFilePrefix)
            guard let regex = try? NSRegularExpression(pattern: "^" + prefixRegex, options: []) else {
                return false
            }
            let matches = regex.matchesInString(fileName, options: [], range: NSMakeRange(0, fileName.characters.count))
            return matches.count > 0
        }
        .forEach {
            name in
            guard let path = NSURL(fileURLWithPath: docsDir).URLByAppendingPathComponent(name).path else {
                return
            }
            if manager.fileExistsAtPath(path) {
                NSLog("Removing temporary file \(path)")
                try! manager.removeItemAtPath(path)
            }
        }
    }

    static func arrayFromData(data: NSData) -> [UInt8] {
        let count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        data.getBytes(&array, length: count * sizeof(UInt8))
        return array
    }

    static func isImageType(type: String) -> Bool {
        return Set("image/jpeg", "image/jpg", "image/png", "image/gif", "image/bmp").contains(type)
    }

    static func forceOrientation(orientation: UIInterfaceOrientation) {
        UIDevice.currentDevice().setValue(orientation.rawValue, forKey: "orientation")
    }

    static let appDisplayName: String = {
        let bundle = NSBundle.mainBundle()
        guard let info = bundle.infoDictionary else {
            return ""
        }
        guard let name = info[String(kCFBundleNameKey)] as? String else {
            return ""
        }
        return name
    }()

    static func alaAssetUrlForPHAsset(asset: PHAsset) -> NSURL! {
        let identifier = asset.localIdentifier
        let components = identifier.componentsSeparatedByString("/")
        let shortId = components.count > 0 ? components[0] : identifier
        var ext: String
        switch asset.mediaType { // todo use also mediaSubTypes to detect extension
            case .Image: ext = "JPG"
            case .Video: ext = "MPG"
            default: ext = "tmp"
        }
        return NSURL(string: "assets-library://asset/asset.\(ext)?id=\(shortId)&ext=\(ext)")
    }
    
    static func delayBy(delayInSeconds: Double, block: dispatch_block_t) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), block)
    }

    static func getVideoLengthInSecondsByUrl1(url: NSURL) -> Float64 {
        let playerItem = AVPlayerItem(URL: url)
        let duration = playerItem.duration
        return CMTimeGetSeconds(duration)
    }

    static func getVideoLengthInSecondsByUrl2(url: NSURL) -> Double {
        let sourceAsset = AVURLAsset(URL: url, options: nil)
        return CMTimeGetSeconds(sourceAsset.duration)
    }

    /// this method has effect when called in viewDidLoad and viewWillAppear (but if called before super.viewWillAppear() )
    /// in viewDidAppear and viewWillAppear it has no effect
    static func setTransitionsToColor(controller: UIViewController, colorCallback: () -> UIColor?) {
        controller.transitionCoordinator()?.animateAlongsideTransition(
            {
                context in
                if let color = colorCallback() {
                    controller.navigationController?.navigationBar.barTintColor = color
                }
            },
            completion: nil
        )
    }

}
