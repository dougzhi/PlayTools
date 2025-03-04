//
//  MacPlugin.swift
//  AKInterface
//
//  Created by Isaac Marovitz on 13/09/2022.
//

import AppKit
import CoreGraphics
import Foundation

class AKPlugin: NSObject, Plugin {
    required override init() {
    }

    var screenCount: Int {
        NSScreen.screens.count
    }

    var mousePoint: CGPoint {
        NSApplication.shared.windows.first?.mouseLocationOutsideOfEventStream ?? CGPoint()
    }

    var windowFrame: CGRect {
        NSApplication.shared.windows.first?.frame ?? CGRect()
    }

    var isMainScreenEqualToFirst: Bool {
        return NSScreen.main == NSScreen.screens.first
    }

    var mainScreenFrame: CGRect {
        return NSScreen.main!.frame as CGRect
    }

    var isFullscreen: Bool {
        NSApplication.shared.windows.first!.styleMask.contains(.fullScreen)
    }

    var cmdPressed: Bool = false

    func setCursor() {
        let cursor = NSCursor.current
        if cursor != .arrow {
            return
        }
        if let view = NSApplication.shared.mainWindow?.contentView {
            let mouseLocation = view.window?.mouseLocationOutsideOfEventStream ?? .zero
            let mouseInView = view.convert(mouseLocation, from: nil)
            if view.bounds.contains(mouseInView) {
                if let customImg = NSImage(named: "cur") {
                    NSCursor.init(image: customImg, hotSpot: NSPoint(x: 0, y: 0)).set()
                } else {
                    NSCursor.pointingHand.set()
                }
            } else {
                NSCursor.arrow.set()
            }
        }
    }

    func hideCursor() {
        NSCursor.hide()
        CGAssociateMouseAndMouseCursorPosition(0)
        warpCursor()
    }

    func warpCursor() {
        guard let firstScreen = NSScreen.screens.first else {return}
        let frame = windowFrame
        // Convert from NS coordinates to CG coordinates
        CGWarpMouseCursorPosition(CGPoint(x: frame.midX, y: firstScreen.frame.height - frame.midY))
    }

    func unhideCursor() {
        NSCursor.unhide()
        if let customImg = NSImage(named: "cur") {
            NSCursor.init(image: customImg, hotSpot: NSPoint(x: 0, y: 0)).set()
        } else {
            NSCursor.pointingHand.set()
        }
        CGAssociateMouseAndMouseCursorPosition(1)
    }

    func terminateApplication() {
        NSApplication.shared.terminate(self)
    }

    private var modifierFlag: UInt = 0
    func setupKeyboard(keyboard: @escaping(UInt16, Bool, Bool) -> Bool,
                       swapMode: @escaping() -> Bool) {
        func checkCmd(modifier: NSEvent.ModifierFlags) -> Bool {
            if modifier.contains(.command) {
                self.cmdPressed = true
                return true
            } else if self.cmdPressed {
                self.cmdPressed = false
            }
            return false
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in
            if checkCmd(modifier: event.modifierFlags) {
                return event
            }
            let consumed = keyboard(event.keyCode, true, event.isARepeat)
            if consumed {
                return nil
            }
            return event
        })
        NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: { event in
            if checkCmd(modifier: event.modifierFlags) {
                return event
            }
            let consumed = keyboard(event.keyCode, false, false)
            if consumed {
                return nil
            }
            return event
        })
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: { event in
            if checkCmd(modifier: event.modifierFlags) {
                return event
            }
            let pressed = self.modifierFlag < event.modifierFlags.rawValue
            let changed = self.modifierFlag ^ event.modifierFlags.rawValue
            self.modifierFlag = event.modifierFlags.rawValue
            if pressed && NSEvent.ModifierFlags(rawValue: changed).contains(.option) {
                if swapMode() {
                    return nil
                }
                return event
            }
            let consumed = keyboard(event.keyCode, pressed, false)
            if consumed {
                return nil
            }
            return event
        })
    }

    func setupMouseMoved(mouseMoved: @escaping(CGFloat, CGFloat) -> Bool) {
        let mask: NSEvent.EventTypeMask = [.leftMouseDragged, .otherMouseDragged, .rightMouseDragged]
        NSEvent.addLocalMonitorForEvents(matching: mask, handler: { event in
            let consumed = mouseMoved(event.deltaX, event.deltaY)
            if consumed {
                return nil
            }
            return event
        })
        // transpass mouse moved event when no button pressed, for traffic light button to light up
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved, handler: { event in
            _ = mouseMoved(event.deltaX, event.deltaY)
            return event
        })
    }

    func setupMouseEntered(_ onEntered: @escaping() -> Bool) {
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseEntered, handler: { event in
            let consumed = onEntered()
            if consumed {
                if let customImg = NSImage(named: "cur") {
                    NSCursor.init(image: customImg, hotSpot: NSPoint(x: 0, y: 0)).set()
                } else {
                    NSCursor.pointingHand.set()
                }
                return nil
            }
            return event
        })
    }

    func setupMouseExited(_ onExited: @escaping() -> Bool) {
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseExited, handler: { event in
            let consumed = onExited()
            if consumed {
                NSCursor.arrow.set()
                return nil
            }
            return event
        })
    }

    func setupMouseButton(left: Bool, right: Bool, _ dontIgnore: @escaping(Bool) -> Bool) {
        let downType: NSEvent.EventTypeMask = left ? .leftMouseDown : right ? .rightMouseDown : .otherMouseDown
        let upType: NSEvent.EventTypeMask = left ? .leftMouseUp : right ? .rightMouseUp : .otherMouseUp
        NSEvent.addLocalMonitorForEvents(matching: downType, handler: { event in
            // For traffic light buttons when fullscreen
            if event.window != NSApplication.shared.windows.first! {
                return event
            }
            if dontIgnore(true) {
                return event
            }
            return nil
        })
        NSEvent.addLocalMonitorForEvents(matching: upType, handler: { event in
            if dontIgnore(false) {
                return event
            }
            return nil
        })
    }

    func setupScrollWheel(_ onMoved: @escaping(CGFloat, CGFloat) -> Bool) {
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.scrollWheel, handler: { event in
            var deltaX = event.scrollingDeltaX, deltaY = event.scrollingDeltaY
            if !event.hasPreciseScrollingDeltas {
                deltaX *= 8
                deltaY *= 8
            }
            let consumed = onMoved(deltaX, deltaY)
            if consumed {
                return nil
            }
            return event
        })
    }

    func urlForApplicationWithBundleIdentifier(_ value: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: value)
    }

    func setMenuBarVisible(_ visible: Bool) {
        NSMenu.setMenuBarVisible(visible)
    }
}
