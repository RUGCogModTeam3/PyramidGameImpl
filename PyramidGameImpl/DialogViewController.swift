//
//  DialogViewController.swift
//  PyramidGameImpl
//
//  Created by Michael LeKander on 3/11/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController {
    @IBOutlet weak var textView: UILabel! {
        didSet {
            textView.text = text
        }
    }
    
    var text:String = "" {
        didSet {
            textView?.text = text
        }
    }

    // This is taken from the Stanford lectures, but it doesn't seem to work...
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                var size = textView.sizeThatFits(presentingViewController!.view.bounds.size)
                size.width += 24
                size.height += 16
                return size
            }
            return super.preferredContentSize
        }
        set { super.preferredContentSize = newValue }
    }

}
