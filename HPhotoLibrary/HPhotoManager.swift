//
//  HPhotoManager.swift
//  HPhotoLibrary
//
//  Created by wuqiuhao on 2016/7/28.
//  Copyright © 2016年 Hale. All rights reserved.
//

import Foundation
import Photos

class HPhotoManager: PHImageManager {
    static let sharedInstance = PHImageManager.defaultManager()
    private override init() {}
}
