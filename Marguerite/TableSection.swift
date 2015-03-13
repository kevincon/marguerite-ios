//
//  TableSection.swift
//  A convenience class for representing sections of a UITableView.
//
//  Created by Kevin Conley on 3/4/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class TableSection: NSObject {
    let header: String?
    let indexHeader: String?
    
    init(header: String?, indexHeader: String?) {
        super.init()
        self.header = header
        self.indexHeader = indexHeader
    }
    
    override init() {
        super.init()
    }
}
