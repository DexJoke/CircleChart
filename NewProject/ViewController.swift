//
//  ViewController.swift
//  NewProject
//
//  Created by dexjoke on 3/6/20.
//  Copyright © 2020 dexjoke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var crỉcle: CircleChart!
    var data:[CGFloat] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func randomData() -> [CGFloat] {
        var data: [CGFloat] = [];
        for _ in 1 ... 15 {
            let item = Float.random(in: 1.0 ... 5.0)
            data.append(CGFloat(item));
        }
        return data;
    }

    @IBAction func onPressBtnStart(_ sender: Any) {
        crỉcle.resetChart();
        crỉcle.addData(data: randomData());
        crỉcle.drawArcs()
        crỉcle.drawSmallData();
        crỉcle.drawCircleAlpha4();
    }
}

