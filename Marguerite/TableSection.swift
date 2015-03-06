//
//  TableSection.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/4/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class TableSection: NSObject {
    let header: String?
    
    init(header: String?) {
        super.init()
        self.header = header
    }
    
    override init() {
        super.init()
    }
    
}
