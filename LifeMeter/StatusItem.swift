//
//  StatusItem.swift
//  LifeMeter
//
//  Created by Brian Palmer on 11/22/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import Foundation
import Cocoa

class StatusItem : NSObject {
    let item: NSStatusItem
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timeLeftMenuItem: NSMenuItem!

    override init() {
        item = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        super.init()
    }

    override func awakeFromNib() {
        item.menu = statusMenu
    }

    deinit {
        NSStatusBar.system().removeStatusItem(item)
    }

    func update(timeLeft: TimeLeft, showPercentage: Bool) {
        timeLeftMenuItem.title = timeLeft.formatTimeLeft()
        let button = item.button!

        if showPercentage {
            button.title = "\(Int(timeLeft.pctLeft * 100))% "
        } else {
            button.title = ""
        }
        
        let statusIcon = drawStatusIcon(timeLeft.pctLeft)
        button.image = statusIcon
        button.imagePosition = .imageRight
    }

    private func drawStatusIcon(_ pctLeft: Double) -> NSImage {
        let statusImage = NSImage(size: NSSize(width: ICON_WIDTH, height: ICON_HEIGHT), flipped: false, drawingHandler: { rect in
            NSImage(named: "si-bg")?.draw(at: NSZeroPoint, from: NSRect(x: 0, y: 0, width: ICON_WIDTH, height: ICON_HEIGHT), operation: .sourceOver, fraction: 1.0)
            NSImage(named: "si-fill")?.draw(at: NSPoint(x: 0, y:0), from: NSRect(x: 0, y: 0, width: (pctLeft * ICON_WIDTH), height: ICON_HEIGHT), operation: .sourceOver, fraction: 1.0)
            return true
        })
        statusImage.isTemplate = true
        return statusImage
    }
}
