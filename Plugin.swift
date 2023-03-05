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

    func hideCursor()
    func unhideCursor()
    func setCursor()
    func terminateApplication()
    func eliminateRedundantKeyPressEvents(_ dontIgnore: @escaping() -> Bool)
    func setupMouseButton(_ _up: Int, _ _down: Int, _ dontIgnore: @escaping(Int, Bool, Bool) -> Bool)
    func setupScrollWheel(_ onMoved: @escaping(CGFloat, CGFloat, UInt) -> Bool)
    func setupMouseDwon(_ onMoved: @escaping() -> Bool)
    func setupMouseUp(_ onMoved: @escaping() -> Bool)
    func setupMouseEntered(_ onMoved: @escaping() -> Bool)
    func setupMouseExited(_ onMoved: @escaping() -> Bool)
    func urlForApplicationWithBundleIdentifier(_ value: String) -> URL?
    func setMenuBarVisible(_ value: Bool)
}
