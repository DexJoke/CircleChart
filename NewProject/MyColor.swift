//
//  MyColor.swift
//  NewProject
//
//  Created by Tùng Anh Nguyễn on 07/12/2022.
//  Copyright © 2022 dexjoke. All rights reserved.
//

import Foundation
import UIKit

class MyColor {
    static func randomColor(total: Int) -> [UIColor] {
        return Array(0 ... total).map({ _ in
            return .random()
        })
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
