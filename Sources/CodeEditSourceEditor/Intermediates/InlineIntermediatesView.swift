//
//  InlineIntermediatesView.swift
//  CodeEditSourceEditor
//
//  Created by Ohad Frenkel on 8/25/25.
//

import AppKit
import CodeEditTextView
import CodeEditTextViewObjC

public class InlineIntermediatesView: NSView {
    
    private weak var textView: TextView?
    
    override public var isFlipped: Bool {
        true
    }

    // MARK: - Lifecycle
    public init(controller: TextViewController) {
        self.textView = controller.textView
        
        super.init(frame: .zero)
        clipsToBounds = true
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        translatesAutoresizingMaskIntoConstraints = false
        layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawLineNumbers(_ context: CGContext, dirtyRect: NSRect) {
        guard let textView = textView else { return }
        // Prepare once (outside the loop if possible)
        let base = NSImage(systemSymbolName: "inset.filled.rectangle", accessibilityDescription: nil)

        // 16pt symbol size, regular weight
        let sizeCfg = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)

        // Prefer hierarchical color (macOS 12+); fall back to tinting if needed
        let colorCfg = NSImage.SymbolConfiguration(hierarchicalColor: .secondaryLabelColor)
        var symbol = base?.withSymbolConfiguration(sizeCfg.applying(colorCfg))


        // You can also force a size explicitly if you prefer:
        // let config = NSImage.SymbolConfiguration(pointSize: font.pointSize, weight: .regular)


        context.saveGState()
        
        context.clip(to: dirtyRect)
        
        NSColor.secondaryLabelColor.set()

        // You flipped the text matrix for Core Text; images draw in view coords.
        // We'll compute a rect with respect to the view’s flipped-ness via `respectFlipped: true`.

        guard let symbol else { return }

        let coolLines = [109, 111, 130, 152, 153, 154, 156] 
        for line in textView.layoutManager.linesStartingAt(dirtyRect.minY, until: dirtyRect.maxY) {

            if !coolLines.contains((line.index + 1)) { continue }

            let yPos = line.yPos
            let xPos = dirtyRect.maxX - 30

            // 16×16 rect, centered on xPos. If yPos is a baseline, the -9 offset
            // usually centers the glyph visually—tweak if your yPos is a top/center.
            let rect = NSRect(x: xPos, y: yPos, width: 16, height: 16)

            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
            symbol.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
            NSGraphicsContext.restoreGraphicsState()
        }

        context.restoreGState()
    }

    
    override public func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        context.saveGState()
        drawLineNumbers(context, dirtyRect: dirtyRect)
        context.restoreGState()
    }
}
