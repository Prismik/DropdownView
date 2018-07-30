//
//  DropdownViewCell.swift
//  fca-dropdown
//
//  Created by Francis Beauchamp on 2018-07-26.
//  Copyright © 2018 Francis Beauchamp. All rights reserved.
//

import UIKit

public protocol DropdownViewCellData {
    func text() -> String?
    func image() -> UIImage?
    func selectable() -> Bool
}

public class DropdownViewCell: UIButton {
    public var textColor: UIColor = UIColor.gray {
        didSet {
            setTitleColor(textColor, for: UIControlState.normal)
        }
    }
    
    public var textFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            titleLabel?.font = textFont
        }
    }
    
    public var imageTintColor: UIColor = UIColor.gray {
        didSet {
            imageView?.tintColor = imageTintColor
        }
    }
    
    public var separatorColor: UIColor = UIColor.gray {
        didSet {
            separator.backgroundColor = separatorColor
        }
    }
    
    public var separatorSideMargins: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var contentSideMargins: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var minimumVerticalMargins: CGFloat = 15 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var minimumHeight: CGFloat = 50 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let separator = UIView()
    private var hasSeparator: Bool = true
    
    private let textLeftMargin: CGFloat = 10
    
    public let isSelectable: Bool
    
    public init(text: String? = nil, image: UIImage? = nil, selectable: Bool) {
        self.isSelectable = selectable
        super.init(frame: CGRect.zero)
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        setTitle(text, for: UIControlState.normal)
        setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        addSubview(separator)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let computedSize: CGSize = titleLabel?.frame.size ?? CGSize.zero
        return CGSize(width: size.width, height: max(computedSize.height + 2 * minimumVerticalMargins, minimumHeight))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageMargins: CGFloat = currentImage == nil ? 0 : contentSideMargins
        contentEdgeInsets = UIEdgeInsets(top: 0, left: imageMargins, bottom: 0, right: contentSideMargins)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: contentSideMargins, bottom: 0, right: 0)
        
        if hasSeparator {
            separator.frame = CGRect(x: separatorSideMargins, y: frame.height - 1,
                                     width: frame.width - 2 * separatorSideMargins, height: 1)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeBorder() {
        separator.removeFromSuperview()
        hasSeparator = false
    }
}
