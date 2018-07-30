//
//  SampleView.swift
//  fca-dropdown-sample
//
//  Created by Francis Beauchamp on 2018-07-30.
//  Copyright © 2018 Francis Beauchamp. All rights reserved.
//

import UIKit
import DropdownView

class SampleView: UIView {
    private var data: [DropdownViewCellData] = []
    
    private let dropdown = DropdownView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(dropdown)
        dropdown.delegate = self
        dropdown.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(data: [DropdownViewCellData]) {
        self.data = data
        dropdown.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let dropdownSize = dropdown.sizeThatFits(CGSize(width: frame.width - 50, height: frame.height))
        dropdown.frame = CGRect(x: 25, y: 50, width: dropdownSize.width, height: dropdownSize.height)
    }
}

extension SampleView: DropdownDelegate {
    func didSelectItem(at rowIndex: Int) {
        
    }
    
    func didOpen() {
        
    }
    
    func didClose() {
        
    }
    
    func willOpen() {
        
    }
    
    func willClose() {
        
    }
}

extension SampleView: DropdownDataSource {
    func numberOfRows() -> Int {
        return data.count
    }
    
    func cellViewDataForRowIndex(_ rowIndex: Int) -> DropdownViewCellData {
        return data[rowIndex]
    }
}
