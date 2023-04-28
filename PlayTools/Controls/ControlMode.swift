//
//  ControlMode.swift
//  PlayTools
//

import Foundation

let mode = ControlMode.mode

public class ControlMode {

    static public let mode = ControlMode()
    public var visible: Bool = true
    public var keyboardMapped = true

    public static func trySwap() -> Bool {
        if PlayInput.shouldLockCursor {
            mode.show(!mode.visible)
            return true
        }
        mode.show(true)
        return false
    }

    func show(_ show: Bool) {
        if !editor.editorMode {
            if show {
                if !visible {
                    if screen.fullscreen {
                        screen.switchDock(true)
                    }
                    AKInterface.shared!.unhideCursor()
//                    PlayInput.shared.invalidate()
                }
            } else {
                if visible {
                    AKInterface.shared!.hideCursor()
                    if screen.fullscreen {
                        screen.switchDock(false)
                    }
//                    PlayInput.shared.setup()
                }
            }
            Toucher.writeLog(logMessage: "cursor show switched to \(show)")
            visible = show
        }
    }
}
