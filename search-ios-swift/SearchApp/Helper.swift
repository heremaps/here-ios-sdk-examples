/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit

class Helper {

    static var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)

    static func showIndicator(onView view:UIView) {
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        view.bringSubviewToFront(indicator)
        indicator.startAnimating()
    }

    static func hideIndicator() {
        indicator.stopAnimating()
    }

    static func show(_ message: String, onView view: UIView) {
        var frame = CGRect(x: 110, y: 200, width: 220, height: 120);

        let label = UILabel(frame: frame);
        label.backgroundColor = UIColor.systemGroupedBackground
        label.textColor = UIColor.blue
        label.text = message;
        label.numberOfLines = 0;

        if let rect = label.text?.boundingRect(with: frame.size, options: [NSStringDrawingOptions.usesLineFragmentOrigin,
            NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font : label.font!], context: nil) {
            frame.size = rect.size;
            label.frame = frame;
        }

        view.addSubview(label)
        UIView.animate(withDuration: 2.0, animations: {
            label.alpha = 0
        }, completion: { finished in
                label.removeFromSuperview()
        })
    }

}
