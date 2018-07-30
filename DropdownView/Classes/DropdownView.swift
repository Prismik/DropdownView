//
//  DropdownView.swift
//  fca-dropdown
//
//  Created by Francis Beauchamp on 2018-07-26.
//  Copyright © 2018 Francis Beauchamp. All rights reserved.
//

import UIKit

public protocol DropdownDataSource: class {
    func numberOfRows() -> Int
    func cellViewDataForRowIndex(_ rowIndex: Int) -> DropdownViewCellData
}

public protocol DropdownDelegate: class {
    func didSelectItem(at rowIndex: Int)
    func didOpen()
    func didClose()
    func willOpen()
    func willClose()
}

public class DropdownView: UIView {
    fileprivate enum State {
        case collapsed
        case expanded
    }
    
    private let maskLayer = CALayer()
    
    public weak var dataSource: DropdownDataSource?
    public weak var delegate: DropdownDelegate?
    
    public var collapsableButtonTextColor: UIColor = UIColor.white {
        didSet {
            collapsableButton.setTitleColor(collapsableButtonTextColor, for: UIControlState.normal)
        }
    }
    
    public var collapsableButtonImageTintColor: UIColor = UIColor.white {
        didSet {
            collapsableButton.imageView?.tintColor = collapsableButtonImageTintColor
        }
    }
    
    public var collapsableButtonBackgroundColor: UIColor = UIColor.gray {
        didSet {
            collapsableButton.backgroundColor = collapsableButtonBackgroundColor
        }
    }
    
    public var collapsableButtonFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            collapsableButton.titleLabel?.font = collapsableButtonFont
        }
    }
    
    public var collapsableButtonArrowTintColor: UIColor = UIColor.white {
        didSet {
            arrowView.backgroundColor = collapsableButtonArrowTintColor
        }
    }
    
    public var collapsableButtonSideMargins: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var cellBackgroundColor: UIColor = UIColor.white {
        didSet {
            for cell in rows {
                cell.backgroundColor = cellBackgroundColor
            }
        }
    }
    
    public var cellTextColor: UIColor = UIColor.gray {
        didSet {
            for cell in rows {
                cell.textColor = cellTextColor
            }
        }
    }
    
    public var cellTextFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            for cell in rows {
                cell.textFont = cellTextFont
            }
        }
    }
    
    public var cellSeparatorColor: UIColor = UIColor.lightGray {
        didSet {
            for cell in rows {
                cell.separatorColor = cellSeparatorColor
            }
        }
    }
    
    public var cellSeparatorSideMargins: CGFloat = 10 {
        didSet {
            for cell in rows {
                cell.separatorSideMargins = cellSeparatorSideMargins
            }
        }
    }
    
    public var cellImageTintColor: UIColor = UIColor.black {
        didSet {
            for cell in rows {
                cell.imageTintColor = cellImageTintColor
            }
        }
    }
    
    public var cellImageAlignment: UIControlContentHorizontalAlignment = .left {
        didSet {
            for cell in rows {
                cell.contentHorizontalAlignment = cellImageAlignment
            }
        }
    }
    
    public var minimumCellHeight: CGFloat = 50 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// The maximum container size for all the dropdown cells. A smaller size than the actual content will enable the scrollview's scrolling
    public var maxHeight: CGFloat = 250 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let arrowSize: CGSize = CGSize(width: 12, height: 6)
    
    public var animationDuration: TimeInterval = 0.3
    public var selectedCellBackgroundColor: UIColor = UIColor.gray
    public var selectedCellTextColor: UIColor = UIColor.white
    
    public let scrollView = UIScrollView()
    
    fileprivate var state: State = .collapsed
    fileprivate let arrowView: UIView = TriangleView()
    fileprivate let collapsableButton = UIButton()
    fileprivate var rows: [DropdownViewCell] = []
    fileprivate(set) var selectedIndex: Int = 0 {
        didSet {
            if let data = dataSource?.cellViewDataForRowIndex(selectedIndex) {
                updateCollapsableButton(text: data.text(), image: data.image())
            }
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        
        maskLayer.backgroundColor = UIColor.black.cgColor
        layer.mask = maskLayer
        
        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        collapsableButton.addSubview(arrowView)
        collapsableButton.setTitle("", for: UIControlState.normal)
        collapsableButton.setImage(nil, for: UIControlState.normal)
        arrowView.isUserInteractionEnabled = false
        collapsableButton.addTarget(self, action: #selector(DropdownView.dropdownCollapsableButtonTap), for: .touchUpInside)
        collapsableButton.titleLabel?.lineBreakMode = .byTruncatingTail
        collapsableButton.titleLabel?.numberOfLines = 2
        addSubview(collapsableButton)
        
        scrollView.layer.masksToBounds = false
        scrollView.backgroundColor = cellBackgroundColor
        
        addSubview(scrollView)
        
        applyDefaults()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyDefaults() {
        collapsableButton.setTitleColor(collapsableButtonTextColor, for: UIControlState.normal)
        collapsableButton.imageView?.tintColor = collapsableButtonImageTintColor
        collapsableButton.backgroundColor = collapsableButtonBackgroundColor
        collapsableButton.titleLabel?.font = collapsableButtonFont
        arrowView.backgroundColor = collapsableButtonArrowTintColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = CGRect(x: -10, y: 0, width: frame.width + 20, height: heightThatFits() + 10)
        layoutRows()
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = state == .collapsed ? collapsableButton.frame.height : heightThatFits()
        return CGSize(width: size.width, height: height)
    }
    
    private func heightThatFits() -> CGFloat {
        let actualHeight = collapsableButton.frame.height + rowsHeight()
        return min(actualHeight, maxHeight)
    }
    
    private func rowsHeight() -> CGFloat {
        return rows.map({ $0.sizeThatFits(frame.size).height }).reduce(0, +)
    }
    
    private func layoutRows() {
        collapsableButton.contentHorizontalAlignment = cellImageAlignment
        let imageMargins: CGFloat = collapsableButton.currentImage == nil ? 0 : collapsableButtonSideMargins
        collapsableButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: imageMargins, bottom: 0, right: 0)
        collapsableButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: collapsableButtonSideMargins / 2, bottom: 0, right: arrowSize.width + 2 * collapsableButtonSideMargins)
        let collapsableButtonHeight = collapsableButton.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height
        let actualSize = CGSize(width: bounds.width, height: max(minimumCellHeight, collapsableButtonHeight))
        collapsableButton.frame = CGRect(x: 0, y: 0, width: actualSize.width, height: actualSize.height)
        arrowView.frame = CGRect(x: collapsableButton.frame.width - arrowSize.width - collapsableButtonSideMargins,
                                 y: (collapsableButton.frame.height - arrowSize.height) / 2,
                                 width: arrowSize.width, height: arrowSize.height)
        
        let currentY: CGFloat = collapsableButton.frame.maxY
        var rowY: CGFloat = 0
        for cell in rows {
            let cellSize = cell.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
            cell.frame = CGRect(x: 0, y: rowY, width: cellSize.width, height: cellSize.height)
            rowY = cell.frame.maxY
        }
        rows.last?.removeBorder()
        
        let scrollViewMargins = UIEdgeInsets(top: (state == .collapsed) ? -rowsHeight() : currentY, left: 0, bottom: 0, right: 0)
        scrollView.frame = CGRect(x: 0, y: scrollViewMargins.top,
                                  width: collapsableButton.frame.width, height: min(rowY, maxHeight))
        scrollView.contentSize = CGSize(width: collapsableButton.frame.width, height: rowY)
        
        bringSubview(toFront: collapsableButton)
    }
    
    private func createDropdownCell(cellData: DropdownViewCellData) -> DropdownViewCell {
        let cell: DropdownViewCell = DropdownViewCell(text: cellData.text(), image: cellData.image(), selectable: cellData.selectable())
        cell.textColor = cellTextColor
        cell.textFont = cellTextFont
        cell.backgroundColor = cellBackgroundColor
        cell.separatorColor = cellSeparatorColor
        cell.separatorSideMargins = cellSeparatorSideMargins
        cell.contentHorizontalAlignment = cellImageAlignment
        cell.imageTintColor = cellImageTintColor
        cell.addTarget(self, action: #selector(DropdownView.dropdownCellTap(_:)), for: .touchUpInside)
        
        return cell
    }
    
    public func reloadData() {
        for cell in rows {
            cell.removeFromSuperview()
        }
        
        rows.removeAll()
        
        if let source = dataSource {
            let numberOfRows = source.numberOfRows()
            for i in 0..<numberOfRows {
                let rowData = source.cellViewDataForRowIndex(i)
                let rowButton: DropdownViewCell = createDropdownCell(cellData: rowData)
                scrollView.addSubview(rowButton)
                rows.append(rowButton)
            }
            
            if let firstRowData = dataSource?.cellViewDataForRowIndex(0) {
                updateCollapsableButton(text: firstRowData.text(), image: firstRowData.image())
            }
            
            layoutRows()
            setNeedsLayout()
        }
    }
    
    public func expand() {
        state = .expanded
        delegate?.willOpen()
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.frame.size = CGSize(width: self.frame.width, height: self.heightThatFits())
            self.arrowView.transform = CGAffineTransform(rotationAngle: 0)
            self.layoutRows()
        }, completion: { (_: Bool) in
            if self.state == .expanded {
                self.delegate?.didOpen()
            }
        })
    }
    
    public func collapse() {
        state = .collapsed
        delegate?.willClose()
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.frame.size = CGSize(width: self.frame.width, height: self.collapsableButton.frame.height)
            self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.scrollView.layer.shadowOpacity = 0
            self.layoutRows()
        }, completion: { (_: Bool) in
            if self.state == .collapsed {
                self.delegate?.didClose()
            }
        })
    }
    
    public func setSelectedItem(index: Int) {
        if index != selectedIndex {
            let dropdownCell = rows[index]
            dropdownCell.backgroundColor = selectedCellBackgroundColor
            dropdownCell.textColor = selectedCellTextColor
            
            let previouslySelectedCell = rows[selectedIndex]
            previouslySelectedCell.backgroundColor = cellBackgroundColor
            previouslySelectedCell.textColor = cellTextColor
            
            selectedIndex = index
        }
    }
    
    fileprivate func didSelectCell(_ dropdownCell: DropdownViewCell, at index: Int) {
        if dropdownCell.isSelectable {
            setSelectedItem(index: index)
        }
        
        delegate?.didSelectItem(at: index)
    }
    
    private func updateCollapsableButton(text: String?, image: UIImage?) {
        collapsableButton.setTitle(text, for: UIControlState.normal)
        collapsableButton.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)
    }
}

// MARK: Control events
extension DropdownView {
    private func handleTapEvent() {
        if state == .collapsed {
            expand()
        } else {
            collapse()
        }
    }
    
    @objc
    func dropdownCollapsableButtonTap() {
        handleTapEvent()
    }
    
    @objc
    func dropdownCellTap(_ dropdownCell: DropdownViewCell) {
        if let index = rows.index(of: dropdownCell) {
            didSelectCell(dropdownCell, at: index)
            handleTapEvent()
        }
    }
}

extension DropdownView {
    class TriangleView: UIView {
        override var backgroundColor: UIColor? {
            didSet {
                setNeedsDisplay()
            }
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: frame.width / 2, y: 0))
            path.addLine(to: CGPoint(x: frame.width, y: frame.height))
            path.addLine(to: CGPoint(x: 0, y: frame.height))
            path.addLine(to: CGPoint(x: frame.width / 2, y: 0))
            
            let mask = CAShapeLayer()
            mask.frame = bounds
            mask.path = path.cgPath
            
            layer.mask = mask
        }
    }
}
