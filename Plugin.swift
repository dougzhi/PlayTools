//
//  Plugin.swift
//  PlayTools
//
//  Created by Isaac Marovitz on 13/09/2022.
//

import Foundation

@objc(Plugin)
public protocol Plugin: NSObjectProtocol {
    init()

    var screenCount: Int { get }
    var mousePoint: CGPoint { get }
    var windowFrame: CGRect { get }
    var mainScreenFrame: CGRect { get }
    var isMainScreenEqualToFirst: Bool { get }
    var isFullscreen: Bool { get }
    var cmdPressed: Bool { get }

    func setCursor()
    func hideCursor()
    func warpCursor()
    func unhideCursor()
    func terminateApplication()
    func setupKeyboard(keyboard: @escaping(UInt16, Bool, Bool) -> Bool,
                       swapMode: @escaping() -> Bool)
    func setupMouseMoved(mouseMoved: @escaping(CGFloat, CGFloat) -> Bool)
    func setupMouseEntered(_ onMoved: @escaping() -> Bool)
    func setupMouseExited(_ onMoved: @escaping() -> Bool)
    func setupMouseButton(left: Bool, right: Bool, _ dontIgnore: @escaping(Bool) -> Bool)
    func setupScrollWheel(_ onMoved: @escaping(CGFloat, CGFloat) -> Bool)
    func urlForApplicationWithBundleIdentifier(_ value: String) -> URL?
    func setMenuBarVisible(_ value: Bool)
}
