//
//  ViewController.swift
//  fca-dropdown-sample
//
//  Created by Francis Beauchamp on 2018-07-26.
//  Copyright © 2018 Francis Beauchamp. All rights reserved.
//

import UIKit
import DropdownView

class DropdownViewCellDataItem: DropdownViewCellData {
    private let itemText: String?
    private let itemImage: UIImage?
    private var isSelectable: Bool
    
    init(text: String?, image: UIImage?, selectable: Bool) {
        self.itemText = text
        self.itemImage = image
        self.isSelectable = selectable
    }
    
    func text() -> String? {
        return itemText
    }
    
    func image() -> UIImage? {
        return itemImage
    }
    
    func selectable() -> Bool {
        return isSelectable
    }
}

class ViewController: UIViewController {
    private let data: [DropdownViewCellData]

    private var mainView: SampleView {
        return view as! SampleView
    }

    init() {
        data = [
            DropdownViewCellDataItem(text: "Title A", image: nil, selectable: true),
            DropdownViewCellDataItem(text: "Another title", image: nil, selectable: true),
            DropdownViewCellDataItem(text: "Last item title", image: nil, selectable: true)
        ]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = SampleView()
        view.backgroundColor = UIColor.blue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainView.configure(data: data)
    }
}
