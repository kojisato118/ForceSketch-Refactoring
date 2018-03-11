//
//  SketchViewController.swift
//  ForceSketch-Refactoring
//
//  Created by 佐藤 康次 on 2018/02/22.
//  Copyright © 2018年 toosaa. All rights reserved.
//

import UIKit

class SketchViewController: UIViewController {
    @IBOutlet weak var sketchView: SketchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    // タイミングかと思ってやったけどダメ
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sketchView.startMonitoring()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
