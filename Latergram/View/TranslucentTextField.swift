//
//  TranslucentTextField.swift
//  Latergram
//
//  Created by Domingo José Moronta on 4/16/16.
//  Copyright © 2016 Domingo José Moronta. All rights reserved.
//

import UIKit

class TranslucentTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        placeholderText = ""
        super.init(coder: aDecoder)
        tintColor = UIColor.whiteColor()
        layer.cornerRadius = 3
        
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 16, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 16, 0)
    }
    
    var placeholderText: String {
        didSet {
            attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        }
    }
}
