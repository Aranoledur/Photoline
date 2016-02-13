//
//  SmoothedBIView.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 06.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

struct UndoQueue<Element> {
    var items = [Element]()
    mutating func push(item: Element) {
        items.append(item)
        if items.count > 4 {
            items.removeFirst()
        }
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    var topItem: Element? {
        return items.isEmpty ? nil : items[items.count - 1]
    }
}

class SmoothedBIView: UIView {
    let path: UIBezierPath! = UIBezierPath()
    var incrementalImage: UIImage? {
        didSet {
        }
    }
    var pts: [CGPoint] = [CGPoint](count: 5, repeatedValue: CGPoint())
    var ctr: Int = 0
    var currentColor: UIColor = UIColor.blackColor()
    var isDot: Bool = true
    var lineWidth: CGFloat = 2.0 {
        didSet {
            path?.lineWidth = lineWidth
        }
    }
    var imageStack = UndoQueue<UIImage?>()
    
    func setIncrementalIMage(image: UIImage?) {
        imageStack.push(incrementalImage)
        incrementalImage = image
    }
    
    func clearDrawing() {
        setIncrementalIMage(nil)
        self.setNeedsDisplay()
    }
    
    private func selfInit() {
        path.lineWidth = lineWidth
        self.multipleTouchEnabled = false
        self.userInteractionEnabled = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selfInit()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        incrementalImage?.drawInRect(rect)
        currentColor.setStroke()
        if currentColor == UIColor.clearColor() {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), .Clear)
        }
        path.stroke()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            ctr = 0
            pts[0] = touch.locationInView(self)
            isDot = true
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            isDot = false
            let p = touch.locationInView(self)
            ctr++
            pts[ctr] = p
            if(ctr == 4) {
                pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
                path.moveToPoint(pts[0])
                
                path.addCurveToPoint(pts[3], controlPoint1: pts[1], controlPoint2: pts[2]) // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]

                self.setNeedsDisplay()
                // replace points and get ready to handle the next segment
                pts[0] = pts[3];
                pts[1] = pts[4];
                ctr = 1;
            }

        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let pathCopy = path.copy() as! UIBezierPath
        let colorCopy = currentColor.copy() as! UIColor
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.drawBitmap(pathCopy, color: colorCopy, isDot: self.isDot)

            dispatch_async(dispatch_get_main_queue()) {
                self.setNeedsDisplay()
            }
        }
        path.removeAllPoints()
        ctr = 0
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let _ = touches {
            self.touchesEnded(touches!, withEvent: event)
        }
    }
    
    func drawBitmap(actualPath: UIBezierPath, color: UIColor, isDot: Bool) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if (incrementalImage == nil) // first time; paint background white
        {
            let rectPath = UIBezierPath(rect: self.bounds)
            UIColor.clearColor().setFill()
            rectPath.fill()
        }
        
        self.incrementalImage?.drawInRect(self.bounds)
        if currentColor == UIColor.clearColor() {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), .Clear)
        }

        if !isDot {
            color.setStroke()
            actualPath.stroke()
        } else {
            let p = pts[0]
            let kRadius: CGFloat = actualPath.lineWidth
            let rect = CGRectMake(p.x - kRadius, p.y - kRadius, 2 * kRadius, 2 * kRadius)
            let dotPath = UIBezierPath(ovalInRect: rect)
            color.setFill()
            dotPath.fill()
        }
        setIncrementalIMage(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()
    }
    
    func undo() {
        if imageStack.topItem != nil {
            incrementalImage = imageStack.pop()
            setNeedsDisplay()
        }
    }
}
