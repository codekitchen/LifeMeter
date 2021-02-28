//
//  StatusItem.swift
//  LifeMeter
//
//  Created by Brian Palmer on 11/22/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import Foundation
import Cocoa

let ICON_WIDTH = 24.0
let ICON_HEIGHT = 16.0

class StatusItem : NSObject {
    let item: NSStatusItem
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timeLeftMenuItem: NSMenuItem!

    override init() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
    }

    override func awakeFromNib() {
        item.menu = statusMenu
    }

    deinit {
        NSStatusBar.system.removeStatusItem(item)
    }

    func update(timeLeft: TimeLeft, showPercentage: Bool) {
        timeLeftMenuItem.title = timeLeft.formatTimeLeft()
        let button = item.button!

        if showPercentage {
            let titleText = "\(Int(timeLeft.pctLeft * 100))%"
            let font = NSFont.systemFont(ofSize: 12.5)
            button.attributedTitle = NSAttributedString(string: titleText, attributes: [NSAttributedString.Key.font: font])
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
