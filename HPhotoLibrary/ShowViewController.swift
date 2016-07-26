//
//  ShowViewController.swift
//  HPhotoLibrary
//
//  Created by wuqiuhao on 2016/7/20.
//  Copyright © 2016年 Hale. All rights reserved.
//

import UIKit

class ShowViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var selectBtn: UIButton!
    
    @IBAction func selectBtnClicked() {
        let selectViewController = SelectViewController()
        selectViewController.delegate = self
        self.presentViewController(selectViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.contentInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
    }
    
    deinit {
        print("deinit")
    }
}

extension ShowViewController: HPhotoLibraryDelegate {
    func didDismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didFinishPickingImages(images: [UIImage]) {
        for image in images {
            let imgView = UIImageView()
            imgView.image = image
            let imgWidth = scrollView.bounds.height * image.size.width / image.size.height
            imgView.layer.borderWidth = 2.5
            imgView.layer.borderColor = UIColor.whiteColor().CGColor
            imgView.frame = CGRect(x: scrollView.contentSize.width, y: 0, width: imgWidth, height: scrollView.bounds.height - 5)
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width + imgWidth, height: scrollView.bounds.height - 5)
            scrollView.addSubview(imgView)
            scrollView.scrollRectToVisible(imgView.frame, animated: true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

