//
//  RefreshView.swift
//  PullRefresh
//
//  Created by K Rummler on 16/03/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

let myContext = UnsafeMutablePointer<()>()

class RefreshView: UIView {
    
    private struct Constants {
        static let Colors: Array<UIColor> = [UIColor.magentaColor(), UIColor.brownColor(), UIColor.yellowColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.orangeColor()]
        
        static let DefaultImageOffset = CGFloat(8)
    }
    
    var isAnimating:Bool { return refreshControl?.refreshing ?? false }

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageOffset: NSLayoutConstraint!
    @IBOutlet weak var letter1: UILabel!
    @IBOutlet weak var letter2: UILabel!
    @IBOutlet weak var letter3: UILabel!
    @IBOutlet weak var letter4: UILabel!
    @IBOutlet weak var letter5: UILabel!
    @IBOutlet weak var letter6: UILabel!
    @IBOutlet weak var letter7: UILabel!
    
    private var labelsArray:[UILabel] { return [letter1, letter2, letter3, letter4, letter5, letter6, letter7] }
    private var refreshControl:UIRefreshControl? { return self.superview as? UIRefreshControl }
    private var currentColorIndex = 0
    private var currentLabelIndex = 0
    private var maxHeight:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        
        if let newSuperview = newSuperview as? UIRefreshControl {
            newSuperview.addTarget(self, action: Selector("refreshChanged"), forControlEvents: .ValueChanged)
            maxHeight = newSuperview.frame.height
        }
    }

    func refreshChanged() {
        
        if refreshControl?.refreshing ?? false {
            
            animateRefreshStep1()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentHeight = superview?.frame.height ?? 0
        let offset = (-(maxHeight - currentHeight) * 4) + Constants.DefaultImageOffset
        imageOffset.constant = offset
    }
    
    private func startAnimation() {
        
        animateRefreshStep1()
    }
    
    private func resetAnimation() {
        
        imageOffset.constant = Constants.DefaultImageOffset
    }
    
    private func animateRefreshStep1() {
        
        if !isAnimating {
            resetAnimation()
            return
        }
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            let currentIndex = self.currentLabelIndex % self.labelsArray.count
            self.labelsArray[currentIndex].transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
            self.labelsArray[currentIndex].textColor = self.getNextColor()
            
            }, completion: { (finished) -> Void in
                
                UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    let currentIndex = self.currentLabelIndex % self.labelsArray.count
                    self.labelsArray[currentIndex].transform = CGAffineTransformIdentity
                    self.labelsArray[currentIndex].textColor = UIColor.blackColor()
                    
                    }, completion: { (finished) -> Void in
                        ++self.currentLabelIndex
                        
                        if self.currentLabelIndex < self.labelsArray.count {
                            self.animateRefreshStep1()
                        }
                        else {
                            self.animateRefreshStep2()
                        }
                })
        })
    }
    
    private func animateRefreshStep2() {
        
        UIView.animateWithDuration(0.35, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            self.labelsArray.forEach({$0.transform = CGAffineTransformMakeScale(1.5, 1.5) })
            
            }, completion: { (finished) -> Void in
                UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    
                    self.labelsArray.forEach({$0.transform = CGAffineTransformIdentity })
                    
                    }, completion: { (finished) -> Void in
                        if self.isAnimating {
                            self.currentLabelIndex = 0
                            self.animateRefreshStep1()
                        }
                        else {
                            self.currentLabelIndex = 0
                            self.labelsArray.forEach({
                                $0.textColor = UIColor.blackColor()
                                $0.transform = CGAffineTransformIdentity
                            })
                        }
                })
        })
    }
    
    private func getNextColor() -> UIColor {
        return Constants.Colors[currentColorIndex++ % Constants.Colors.count]
    }
}
