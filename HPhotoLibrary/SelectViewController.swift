//
//  SelectViewController.swift
//  HPhotoLibrary
//
//  Created by wuqiuhao on 2016/7/20.
//  Copyright © 2016年 Hale. All rights reserved.
//

import UIKit
import Photos

private let headViewHeight: CGFloat = 180
private let cellRowHeight: CGFloat = 60
private let tableViewHeight: CGFloat = cellRowHeight * 3 + headViewHeight

class SelectViewController: UIViewController {
    
    var delegate: HPhotoLibraryDelegate!
    
    var headImages = [UIImage]()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.tableFooterView = UIView()
        tableView.scrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSomePhoto()
        self.view.addSubview(tableView)
    }
    
    deinit {
        print("SelectViewController deinit")
    }
}

// MARK: - UITableViewDataSource
extension SelectViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "reuseIdentify")
        var label: UILabel!
        if indexPath.row != 0 {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 60))
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor(red: 0 / 255.0, green: 138 / 255.0, blue: 242 / 255.0, alpha: 1.0)
            cell.addSubview(label)
        }
        switch indexPath.row {
        case 0:
            // 添加滚动视图
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 180))
            scrollView.contentInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
            scrollView.showsHorizontalScrollIndicator = false
            for image in headImages {
                let imgView = UIImageView()
                imgView.image = image
                let imgWidth = scrollView.bounds.height * image.size.width / image.size.height
                imgView.layer.borderWidth = 2.5
                imgView.layer.borderColor = UIColor.whiteColor().CGColor
                imgView.frame = CGRect(x: scrollView.contentSize.width, y: 0, width: imgWidth, height: scrollView.bounds.height - 5)
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width + imgWidth, height: scrollView.bounds.height - 5)
                scrollView.addSubview(imgView)
            }
            cell.contentView.addSubview(scrollView)
            cell.selectionStyle = .None
            break
        case 1:
            label.text = "照片图库"
        case 2:
            label.text = "拍照"
        case 3:
            label.text = "取消"
        default:
            break
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SelectViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 1: // 照片图库
            openPhotoLibrary(.PhotoLibrary)
        case 2: // 照相机
            openPhotoLibrary(.Camera)
        case 3: // 取消
            delegate.didDismissViewController()
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return headViewHeight
        }
        return cellRowHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SelectViewController: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            let presentViewController = CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
            presentViewController.prestentDelegate = delegate
            return presentViewController
        }
        return nil
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return CustomPresentationAnimationController(presenting: true)
        } else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return CustomPresentationAnimationController(presenting: false)
        } else {
            return nil
        }
    }
}


// MARK: - private method
extension SelectViewController {
    /**
     打开照片图库
     */
    func openPhotoLibrary(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        if sourceType == .Camera {
            // 相机获取
            guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
                //TODO:
                print("设备不支持相机！")
                return
            }
        }
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /**
     从相册中抓取部分图片
     */
    func fetchSomePhoto() {
        // 获取相册 —— 相机胶卷
        let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumUserLibrary, options: nil).firstObject
        
            if fetchResult is PHAssetCollection {
                let assetCollection = fetchResult as! PHAssetCollection
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 10
                let photoResults = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
                let options = PHImageRequestOptions()
                options.synchronous = true
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
                options.resizeMode = PHImageRequestOptionsResizeMode.Exact
                for i in 0..<photoResults.count {
                    let asset = photoResults[i] as! PHAsset
                    let screenScale = UIScreen.mainScreen().scale
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(width: headViewHeight * screenScale * CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight) , height: headViewHeight * screenScale), contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: { (result, info) in
                        // 只要清晰图
                        if let degradedKey = info![PHImageResultIsDegradedKey] where !degradedKey.boolValue! && info![PHImageErrorKey] == nil && info![PHImageCancelledKey] == nil {
                            self.headImages.append(result!)
                        }
                    })
                }
            } else {
                assert(false, "Fetch collection not PHCollection: \(fetchResult)")
            }
        }
}

extension SelectViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    /**
     成功获取图片信息
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        delegate.didFinishPickingImages([image])
    }
    
    /**
     取消获取图片
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        delegate.didDismissViewController()
    }
}

protocol HPhotoLibraryDelegate {
    func didFinishPickingImages(images: [UIImage])
    func didDismissViewController()
}

class CustomPresentationController: UIPresentationController {
    
    var prestentDelegate: HPhotoLibraryDelegate!
    lazy var shadeView :UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0.0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        
        guard
            let containerView = containerView,
            let presentedView = presentedView()
            else {
                return
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shadeViewDidTaped))
        shadeView.userInteractionEnabled = true
        shadeView.addGestureRecognizer(tapGesture)
        shadeView.frame = containerView.bounds
        containerView.addSubview(shadeView)
        containerView.addSubview(presentedView)
        
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.shadeView.alpha = 1.0
                }, completion:nil)
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool)  {
        if !completed {
            shadeView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin()  {
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.shadeView.alpha  = 0.0
                }, completion:nil)
        }
        
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            shadeView.removeFromSuperview()
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - tableViewHeight, width: UIScreen.mainScreen().bounds.width, height: tableViewHeight)
    }
    
    
    func shadeViewDidTaped() {
        prestentDelegate.didDismissViewController()
    }
}

class CustomPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presenting: Bool
    let duration: NSTimeInterval = 0.25
    
    init(presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentationWithTransitionContext(transitionContext)
        }
        else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        toViewController?.view.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height, width: UIScreen.mainScreen().bounds.width, height: tableViewHeight)
        let containerView = transitionContext.containerView()
        containerView?.addSubview(toViewController!.view)
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            toViewController?.view.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - tableViewHeight, width: UIScreen.mainScreen().bounds.width, height: tableViewHeight)
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
    func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            fromViewController!.view.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height, width: UIScreen.mainScreen().bounds.width, height: tableViewHeight)
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}