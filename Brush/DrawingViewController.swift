//
//  DrawingViewController
//  Brush
//
//  Created by Ken Siu on 4/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit
import CoreData

class DrawingViewController: UIViewController, GalleryViewControllerDelegate, ColorPickerViewDelegate {
    
    // TODO: implement cameraTapped
    // TODO: add a clearAll button
    // TODO: if saving to photo library, permission must be asked explicitly beforehand
    // if the users say no, we should ask them to go to settings

    @IBOutlet weak var drawingImageView: UIImageView!
    
    var horizontalToolBar: UIView!
    var isHorizontalToolBarUp = true
    
    var isAllowDrawing = true
    var isUnsaved = false
    
    // horizontal toolBar
    var brushButtonView: UIView!
    var eraserButtonView: UIView!
    var redoButtonView: UIView!
    var undoButtonView: UIView!
    var colorPickerButtonView: UIView!
    var moreButtonView: UIView!
    var downButton: UIButton!
    var noOfHorizontalButtons = 0
    
    // verticle toolBar
    var verticleToolBar: UIView!
    var isShowVerticleToolBar = false {
        didSet {
            if isShowVerticleToolBar {
                showVerticleToolBar()
            } else {
                hideVerticleToolBar()
            }
        }
    }
    
    var isRubberMode: Bool = false {
        didSet {
            if isRubberMode {
                eraserButtonView.layer.borderColor = ColorScheme.Orange.cgColor
                eraserButtonView.layer.borderWidth = 3
                
                brushButtonView.layer.borderColor = UIColor.clear.cgColor
            } else {
                eraserButtonView.layer.borderColor = UIColor.clear.cgColor
                
                brushButtonView.layer.borderColor = ColorScheme.Orange.cgColor
                brushButtonView.layer.borderWidth = 3
            }
        }
    }
    
    var colorPickerButton: UIButton!
    
    private var currentColor: UIColor = ColorScheme.Red
    
    private var currentBrushSize: CGFloat = 1.0
    private var firstPoint = CGPoint(x: 0, y: 0)
    private var secondPoint = CGPoint(x: 0, y: 0)
    
    private var undoImages = [UIImage?]()
    private var redoImages = [UIImage?]()
    
    var currentMasterPiece: Masterpiece? {
        didSet {
            if let masterpiece = currentMasterPiece {
                self.drawingImageView.image = UIImage(data: (masterpiece.image as! Data))
            }
            
            self.isUnsaved = false
            undoImages.removeAll()
            redoImages.removeAll()
        }
    }
    
    var masterpieceFromGallery: Masterpiece?
    var isSelectedMasterpieceFromGallery = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingImageView.backgroundColor = ColorScheme.PaleYellow
        initializeImageContextBGColor()
        
        setupHorizontalToolBar()
        setupVerticalToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideHorizontalToolBar(animated: false)
        showHorizontalToolBar()
        
        if isShowVerticleToolBar {
            hideVerticleToolBar(animated: false)
            showVerticleToolBar()
        }
        
        isAllowDrawing = true
        
        if isSelectedMasterpieceFromGallery {
            selectedAMasterpieceFromGallery()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        hideHorizontalToolBar()
        
        if isShowVerticleToolBar {
            hideVerticleToolBar()
        }
        
        isAllowDrawing = false
        isSelectedMasterpieceFromGallery = false
    }
    
    func hideHorizontalToolBar(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.7, animations: {
                self.horizontalToolBar.center.x -= self.view.bounds.width
            })
        } else {
            horizontalToolBar.center.x -= self.view.bounds.width
        }
    }
    
    func showHorizontalToolBar(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.7) {
                self.horizontalToolBar.center.x = self.view.center.x
            }
        } else {
            self.horizontalToolBar.center.x = self.view.center.x
        }
    }
    
    func moveHorizontalToolBar() {
        isHorizontalToolBarUp = !isHorizontalToolBarUp
        if isHorizontalToolBarUp {
            moveHorizontalToolBarUp()
        } else {
            moveHorizontalToolBarDown()
        }
    }
    
    func moveHorizontalToolBarDown() {
        UIView.animate(withDuration: 0.5, animations: {
            self.horizontalToolBar.center.y = self.view.bounds.height - 40
            self.downButton.setImage(UIImage(named: "up-arrow"), for: .normal)
        })
    }
    
    func moveHorizontalToolBarUp() {
        UIView.animate(withDuration: 0.5, animations: {
            self.horizontalToolBar.frame.origin.y = 20
            self.downButton.setImage(UIImage(named: "down-arrow"), for: .normal)
        })
    }
    
    func setupHorizontalToolBar() {
        // 414 for iPhone 7 Plus
        // 375 for iPhone 7
        // 320 for iPhone SE
        var offset: CGFloat = 0
        if UIScreen.main.bounds.width >= 330 {
            offset = 4
        }
        if UIScreen.main.bounds.width >= 400 {
            offset = 10
        }
        
        
        let space: CGFloat = 10
        let buttonWidth: CGFloat = 22 + offset
        let btContainerViewWidth = buttonWidth + 10
        let horizontalToolBarHeight: CGFloat = btContainerViewWidth + 2 * 6
        
        let coordY = (horizontalToolBarHeight - btContainerViewWidth) / 2
        var coordX: CGFloat = space
        
        brushButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let brushButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        brushButton.setImage(UIImage(named: "paint-brush"), for: .normal)
        brushButton.addTarget(self, action: #selector(DrawingViewController.brushTapped), for: .touchUpInside)
        brushButtonView.addSubview(brushButton)
        brushButtonView.backgroundColor = UIColor.white
        brushButtonView.layer.cornerRadius = btContainerViewWidth / 2
        brushButtonView.layer.borderWidth = 3
        brushButtonView.layer.borderColor = ColorScheme.Orange.cgColor
        noOfHorizontalButtons += 1
        coordX += btContainerViewWidth + space
        
        eraserButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let eraserButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        eraserButton.setImage(UIImage(named: "eraser"), for: .normal)
        eraserButton.addTarget(self, action: #selector(DrawingViewController.rubberTapped), for: .touchUpInside)
        eraserButtonView.addSubview(eraserButton)
        eraserButtonView.backgroundColor = UIColor.white
        eraserButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfHorizontalButtons += 1
        coordX += btContainerViewWidth + space
        
        redoButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let redoButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        redoButton.setImage(UIImage(named: "redo"), for: .normal)
        redoButton.addTarget(self, action: #selector(DrawingViewController.redoTapped), for: .touchUpInside)
        redoButtonView.addSubview(redoButton)
        redoButtonView.backgroundColor = UIColor.white
        redoButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfHorizontalButtons += 1
        coordX += btContainerViewWidth + space
        
        undoButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let undoButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        undoButton.setImage(UIImage(named: "undo"), for: .normal)
        undoButton.addTarget(self, action: #selector(DrawingViewController.undoTapped), for: .touchUpInside)
        undoButtonView.addSubview(undoButton)
        undoButtonView.backgroundColor = UIColor.white
        undoButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfHorizontalButtons += 1
        coordX += btContainerViewWidth + space
        
        colorPickerButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        colorPickerButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        colorPickerButton.addTarget(self, action: #selector(DrawingViewController.colorPickerTapped), for: .touchUpInside)
        colorPickerButton.backgroundColor = currentColor
        colorPickerButton.layer.cornerRadius = buttonWidth / 2
        colorPickerButtonView.backgroundColor = UIColor.white
        colorPickerButtonView.addSubview(colorPickerButton)
        colorPickerButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfHorizontalButtons += 1
        coordX += btContainerViewWidth + space
        
        moreButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let moreButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        moreButton.setImage(UIImage(named: "more"), for: .normal)
        moreButton.addTarget(self, action: #selector(DrawingViewController.moreTapped), for: .touchUpInside)
        moreButtonView.addSubview(moreButton)
        moreButtonView.backgroundColor = UIColor.white
        moreButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfHorizontalButtons += 1
        coordX += btContainerViewWidth + space
        
        let ftBtsView = UIView(frame: CGRect(x: 0, y: 0, width: btContainerViewWidth * CGFloat(noOfHorizontalButtons) + CGFloat(noOfHorizontalButtons + 1) * space, height: horizontalToolBarHeight))
        
        ftBtsView.addSubview(brushButtonView)
        ftBtsView.addSubview(eraserButtonView)
        ftBtsView.addSubview(redoButtonView)
        ftBtsView.addSubview(undoButtonView)
        ftBtsView.addSubview(colorPickerButtonView)
        ftBtsView.addSubview(moreButtonView)
        
        ftBtsView.backgroundColor = ColorScheme.Yellow
        ftBtsView.layer.cornerRadius = horizontalToolBarHeight / 2
        
        let nonFtBtWidth = buttonWidth - 5
        let nonFtBtsViewWidth = nonFtBtWidth + 10
        let nonFtBtsHorizontalToolBarHeight = nonFtBtsViewWidth + 10
        var nonFtCoodX = coordX + space
        let nonFtCoodY = (nonFtBtsHorizontalToolBarHeight - nonFtBtsViewWidth) / 2
        
        let downButtonView = UIView(frame: CGRect(x: nonFtCoodX, y: nonFtCoodY, width: nonFtBtsViewWidth, height: nonFtBtsViewWidth))
        downButton = UIButton(frame: CGRect(x: (nonFtBtsViewWidth - nonFtBtWidth) / 2.0, y: (nonFtBtsViewWidth - nonFtBtWidth) / 2.0, width: nonFtBtWidth, height: nonFtBtWidth))
        downButton.setImage(UIImage(named: "down-arrow"), for: .normal)
        downButton.addTarget(self, action: #selector(DrawingViewController.moveHorizontalToolBar), for: .touchUpInside)
        downButtonView.addSubview(downButton)
        downButtonView.backgroundColor = UIColor.white
        downButtonView.layer.cornerRadius = nonFtBtsViewWidth / 2
        downButtonView.center = CGPoint(x: nonFtBtsHorizontalToolBarHeight / 2, y: nonFtBtsHorizontalToolBarHeight / 2)
        noOfHorizontalButtons += 1
        
        let nonFtBtsView = UIView(frame: CGRect(x: nonFtCoodX, y: (horizontalToolBarHeight - nonFtBtsHorizontalToolBarHeight) / 2, width: nonFtBtsHorizontalToolBarHeight, height: nonFtBtsHorizontalToolBarHeight))
        nonFtBtsView.addSubview(downButtonView)
        nonFtBtsView.backgroundColor = ColorScheme.Yellow
        nonFtBtsView.layer.cornerRadius = nonFtBtsHorizontalToolBarHeight / 2
        
        nonFtCoodX += nonFtBtsViewWidth + space
        
        
        horizontalToolBar = UIView(frame: CGRect(x: 0, y: 20, width: btContainerViewWidth * CGFloat(noOfHorizontalButtons) + CGFloat(noOfHorizontalButtons + 1) * space, height: horizontalToolBarHeight))
        
        horizontalToolBar.addSubview(ftBtsView)
        horizontalToolBar.addSubview(nonFtBtsView)
        
        horizontalToolBar.center.x = self.view.center.x
        self.view.addSubview(horizontalToolBar)
        
    }
    
    func setupVerticalToolBar() {
        // 414 for iPhone 7 Plus
        // 375 for iPhone 7
        // 320 for iPhone SE
        var offset: CGFloat = 0
        if UIScreen.main.bounds.width >= 330 {
            offset = 4
        }
        if UIScreen.main.bounds.width >= 400 {
            offset = 10
        }
        
        let space: CGFloat = 10
        var noOfItems = 0
        let buttonWidth: CGFloat = 22 + offset
        let btViewWidth = buttonWidth + 10
        let verticleToolBarWidth = btViewWidth + 2 * 6
        
        var coordY = space
        let coordX: CGFloat = (verticleToolBarWidth - btViewWidth) / 2
        
        let addNewButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        addNewButton.setImage(UIImage(named: "plus"), for: .normal)
        addNewButton.addTarget(self, action: #selector(DrawingViewController.addNewTapped), for: .touchUpInside)
        addNewButton.center = CGPoint(x: btViewWidth / 2, y: btViewWidth / 2)
        let addNewBtView = UIView(frame: CGRect(x: coordX, y: coordY, width: btViewWidth, height: btViewWidth))
        addNewBtView.layer.cornerRadius = btViewWidth / 2
        addNewBtView.backgroundColor = UIColor.white
        addNewBtView.addSubview(addNewButton)
        
        noOfItems += 1
        coordY += btViewWidth + space
        
        let cameraButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(DrawingViewController.cameraTapped), for: .touchUpInside)
        cameraButton.center = CGPoint(x: btViewWidth / 2, y: btViewWidth / 2)
        let cameraBtView = UIView(frame: CGRect(x: coordX, y: coordY, width: btViewWidth, height: btViewWidth))
        cameraBtView.layer.cornerRadius = btViewWidth / 2
        cameraBtView.backgroundColor = UIColor.white
        cameraBtView.addSubview(cameraButton)
        
        noOfItems += 1
        coordY += btViewWidth + space
        
        let saveButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        saveButton.setImage(UIImage(named: "save"), for: .normal)
        saveButton.addTarget(self, action: #selector(DrawingViewController.saveTapped), for: .touchUpInside)
        saveButton.center = CGPoint(x: btViewWidth / 2, y: btViewWidth / 2)
        let saveBtView = UIView(frame: CGRect(x: coordX, y: coordY, width: btViewWidth, height: btViewWidth))
        saveBtView.layer.cornerRadius = btViewWidth / 2
        saveBtView.backgroundColor = UIColor.white
        saveBtView.addSubview(saveButton)
        
        noOfItems += 1
        coordY += btViewWidth + space
        
        let shareButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.addTarget(self, action: #selector(DrawingViewController.shareTapped), for: .touchUpInside)
        shareButton.center = CGPoint(x: btViewWidth / 2, y: btViewWidth / 2)
        let shareBtView = UIView(frame: CGRect(x: coordX, y: coordY, width: btViewWidth, height: btViewWidth))
        shareBtView.layer.cornerRadius = btViewWidth / 2
        shareBtView.backgroundColor = UIColor.white
        shareBtView.addSubview(shareButton)
        
        noOfItems += 1
        coordY += btViewWidth + space
        
        let galleryButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        galleryButton.setImage(UIImage(named: "list"), for: .normal)
        galleryButton.addTarget(self, action: #selector(DrawingViewController.galleryTapped), for: .touchUpInside)
        galleryButton.center = CGPoint(x: btViewWidth / 2, y: btViewWidth / 2)
        let galleryBtView = UIView(frame: CGRect(x: coordX, y: coordY, width: btViewWidth, height: btViewWidth))
        galleryBtView.layer.cornerRadius = btViewWidth / 2
        galleryBtView.backgroundColor = UIColor.white
        galleryBtView.addSubview(galleryButton)
        
        noOfItems += 1
        coordY += btViewWidth + space
        
        let ftBtsView = UIView(frame: CGRect(x: 0, y: 0, width: verticleToolBarWidth, height: btViewWidth * CGFloat(noOfItems) + CGFloat(noOfItems + 1) * space))
        ftBtsView.backgroundColor = ColorScheme.Yellow
        ftBtsView.layer.cornerRadius = verticleToolBarWidth / 2.0
        
        ftBtsView.addSubview(addNewBtView)
        ftBtsView.addSubview(cameraBtView)
        ftBtsView.addSubview(saveBtView)
        ftBtsView.addSubview(shareBtView)
        ftBtsView.addSubview(galleryBtView)
        
        coordY += space
        
        let nonFtBtWidth = buttonWidth - 5
        let nonFtBtViewWidth = nonFtBtWidth + 10
        let nonFtVerticleToolBarWidth = nonFtBtViewWidth + 2 * 6
        
        let hideToolBarBt = UIButton(frame: CGRect(x: 0, y: 0, width: nonFtBtWidth, height: nonFtBtWidth))
        hideToolBarBt.setImage(UIImage(named: "cross"), for: .normal)
        hideToolBarBt.addTarget(self, action: #selector(DrawingViewController.verticalToolBarCloseButtonTapped), for: .touchUpInside)
        hideToolBarBt.center = CGPoint(x: nonFtBtViewWidth / 2, y: nonFtBtViewWidth / 2)
        let hideToolBarBtView = UIView(frame: CGRect(x: 0, y: 0, width: nonFtBtViewWidth, height: nonFtBtViewWidth))
        hideToolBarBtView.layer.cornerRadius = nonFtBtViewWidth / 2
        hideToolBarBtView.backgroundColor = UIColor.white
        hideToolBarBtView.addSubview(hideToolBarBt)
        hideToolBarBtView.center = CGPoint(x: nonFtVerticleToolBarWidth / 2, y: nonFtVerticleToolBarWidth / 2)
        
        let nonftBtsView = UIView(frame: CGRect(x: 0, y: coordY, width: nonFtVerticleToolBarWidth, height: nonFtVerticleToolBarWidth))
        nonftBtsView.backgroundColor = ColorScheme.Yellow
        nonftBtsView.layer.cornerRadius = nonFtVerticleToolBarWidth / 2.0
        nonftBtsView.center.x = verticleToolBarWidth / 2
        nonftBtsView.addSubview(hideToolBarBtView)
        
        noOfItems += 1
        coordY += btViewWidth + space
        
        verticleToolBar = UIView(frame: CGRect(x: 200, y: -200, width: verticleToolBarWidth, height: btViewWidth * CGFloat(noOfItems) + CGFloat(noOfItems + 1) * space))
        verticleToolBar.layer.cornerRadius = verticleToolBarWidth / 2.0
        verticleToolBar.frame.origin.x = self.view.bounds.width + verticleToolBar.bounds.width
        verticleToolBar.center.y = self.view.center.y
    
        verticleToolBar.addSubview(ftBtsView)
        verticleToolBar.addSubview(nonftBtsView)
        
        self.view.addSubview(verticleToolBar)
        
    }
    
    func showVerticleToolBar(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.7, animations: {
                self.verticleToolBar.frame.origin.x = self.view.bounds.width - self.verticleToolBar.bounds.width - 20
            })
        } else {
            self.verticleToolBar.frame.origin.x = self.view.bounds.width - self.verticleToolBar.bounds.width - 20
        }
    }
    
    func hideVerticleToolBar(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.7) {
                self.verticleToolBar.frame.origin.x = self.view.bounds.width + self.verticleToolBar.bounds.width
            }
        } else {
            self.verticleToolBar.frame.origin.x = self.view.bounds.width + self.verticleToolBar.bounds.width
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryViewController" {
            let galleryVC = segue.destination as! GalleryViewController
            galleryVC.delegate = self
        }
                
        if segue.identifier == "ColorPickerViewController" {
            let colorPickerVC = segue.destination as! ColorPickerViewController
            colorPickerVC.delegate = self
            colorPickerVC.colorSelected = currentColor
            colorPickerVC.thicknessSelected = currentBrushSize
        }
    }
    
    // MARK: ColorPickerViewDelegate
    func selected(color: UIColor, thickness: CGFloat) {
        colorPickerButton.backgroundColor = color
        currentColor = color
        currentBrushSize = thickness
    }
    
    // MARK: GalleryViewControllerDelegate
    func selectedAMasterpiece(galleryVC: GalleryViewController, masterpiece: Masterpiece) {
        masterpieceFromGallery = masterpiece
        isSelectedMasterpieceFromGallery = true
    }
    
    func deletedAMasterpiece(galleryVC: GalleryViewController, objectId: NSManagedObjectID) {
        if let masterpiece = currentMasterPiece {
            if masterpiece.objectID == objectId {
                currentMasterPiece = nil
                drawingImageView.image = nil
                //self.title = ""
                initializeImageContextBGColor()
            }
        }
    }
    
    // MARK: touches method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isIgnoreTouches(touches, with: event) {
            return
        }
        
        if redoImages.count > 0 {
            undoImages.append(drawingImageView.image)
            for image in redoImages {
                undoImages.append(image)
            }
            redoImages.removeAll()
        }
        
        undoImages.append(drawingImageView.image)
        
        if let touch = touches.first {
            firstPoint = touch.location(in: drawingImageView)
            
            draw(first: firstPoint, second: firstPoint)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isIgnoreTouches(touches, with: event) {
            return
        }
        
        if let touch = touches.first {
            secondPoint = touch.location(in: drawingImageView)
            draw(first: firstPoint, second: secondPoint)
            firstPoint = secondPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isIgnoreTouches(touches, with: event) {
            return
        }
        
        if let touch = touches.first {
            secondPoint = touch.location(in: drawingImageView)
            draw(first: firstPoint, second: secondPoint)
            firstPoint = secondPoint
        }
    }
    
    // MARK: views that ignore touches
    func isIgnoreTouches(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        if let touch = touches.first {
            let hToolBarPt = touch.location(in: horizontalToolBar)
            let isWithinHToolBar = horizontalToolBar.point(inside: hToolBarPt, with: event)
            
            let vToolBarPt = touch.location(in: verticleToolBar)
            let isWithinVToolBar = verticleToolBar.point(inside: vToolBarPt, with: event)
            
            return (isWithinHToolBar || isWithinVToolBar)
        }
        
        return false
    }
    
    // MARK: Customized Methods
    func moreTapped() {
        isShowVerticleToolBar = true
    }
    
    func saveMasterPiece() {
        if drawingImageView.image == nil {
            Utilities.sharedInstance.popAlertView(parentVC: self, title: "Empty Masterpiece", message: "It is not allowed to save an empty masterpiece")
            return
        } else {
            // initialize the bg color of the image before saving
            self.drawingImageView.backgroundColor = ColorScheme.PaleYellow
        }
        
        if currentMasterPiece == nil {
            let alertC = UIAlertController(title: "New Masterpiece", message: "Please enter a name", preferredStyle: .alert)
            
            let oKAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                let textField = alertC.textFields?[0]
                self.currentMasterPiece = CoreDataHelper.sharedInstance.createAMasterpiece(image: self.drawingImageView.image!, name: (textField?.text)!)
            })
            alertC.addAction(oKAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
                // do nothing
            })
            alertC.addAction(cancelAction)
            
            alertC.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "name"
            })
            
            present(alertC, animated: true, completion: nil)
        } else {
            let alertC = UIAlertController(title: "Update a masterpiece", message: "Please confirm the name", preferredStyle: .alert)
            
            let oKAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                let textField = alertC.textFields?[0]
                self.currentMasterPiece = CoreDataHelper.sharedInstance.updateAMasterpiece(masterpiece: self.currentMasterPiece!, newImage: self.drawingImageView.image!, newName:  (textField?.text)!)
                //self.title = self.currentMasterPiece?.name
            })
            alertC.addAction(oKAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
                // do nothing
            })
            alertC.addAction(cancelAction)
            
            alertC.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "name"
                textField.text = self.currentMasterPiece?.name
            })
            
            present(alertC, animated: true, completion: nil)
        }

    }
    
    func shareMasterPiece() {
        // if the masterpiece is not saved yet, warn the user
        if let masterpiece = currentMasterPiece {
            if isUnsaved {
                Utilities.sharedInstance.popAlertView(parentVC: self, title: "Unsaved Masterpiece", message: "You need to save the masterpiece before sharing it.")
                return
            }
            
            let activityController = UIActivityViewController(activityItems: [masterpiece.image!], applicationActivities: nil)
            // TODO: if saving to photo library, permission must be asked explicitly beforehand
            // if the users say no, we should ask them to change to settings
            
            // for iPad devices
            activityController.popoverPresentationController?.sourceView = self.view
            activityController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width: 1, height: 200))
            present(activityController, animated: true, completion: nil)
        } else {
            Utilities.sharedInstance.popAlertView(parentVC: self, title: "Empty Masterpiece", message: "You need to save the masterpiece before sharing it.")
        }
    }
    
    func addNewMasterpiece() {
        self.drawingImageView.image = nil
        self.currentMasterPiece = nil
        initializeImageContextBGColor()
    }
    
    func draw(first: CGPoint, second: CGPoint) {
        if isAllowDrawing {
            drawALine(first: first, second: second)
            isUnsaved = true
        }
    }
    
    func drawALine(first: CGPoint, second: CGPoint) {
        
        UIGraphicsBeginImageContext(drawingImageView.bounds.size)
        
        let context = UIGraphicsGetCurrentContext()
        drawingImageView.draw(CGRect(origin: CGPoint(x: 0, y: 0), size: drawingImageView.bounds.size))
        
        if isRubberMode {
            context?.setBlendMode(.clear)
        }
        
        context?.setStrokeColor(currentColor.cgColor)
        context?.setLineWidth(currentBrushSize)
        context?.setLineCap(.round)
        context?.move(to: first)
        context?.addLine(to: second)
        context?.strokePath()
        drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
    }
    
    func initializeImageContextBGColor() {
        UIGraphicsBeginImageContext(drawingImageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(ColorScheme.PaleYellow.cgColor)
        context?.fill(CGRect(origin: CGPoint(x: 0, y: 0), size: drawingImageView.bounds.size))
        drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func colorPickerTapped() {
        performSegue(withIdentifier: "ColorPickerViewController", sender: nil)
    }
    
    func undoTapped() {
        if let last = undoImages.last {
            redoImages.append(drawingImageView.image)
            drawingImageView.image = last
            undoImages.removeLast()
        }
    }
    
    func redoTapped() {
        if let last = redoImages.last {
            undoImages.append(drawingImageView.image)
            drawingImageView.image = last
            redoImages.removeLast()
        }
    }
    
    func addNewTapped() {
        if isUnsaved {
            let alertVC = UIAlertController(title: "Your current masterpiece is not saved", message: "you still want to create a new one?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                self.addNewMasterpiece()
            })
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            alertVC.addAction(yesAction)
            alertVC.addAction(noAction)
            
            present(alertVC, animated: true, completion: nil)
        } else {
            addNewMasterpiece()
        }
    }
    
    func cameraTapped() {
        
        let alertVC = UIAlertController(title: "Coming Soon", message: "Import photos feature is coming soon", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func saveTapped() {
        saveMasterPiece()
    }
    
    func shareTapped() {
        shareMasterPiece()
    }
    
    func galleryTapped() {
        performSegue(withIdentifier: "GalleryViewController", sender: nil)
    }
    
    func verticalToolBarCloseButtonTapped() {
        isShowVerticleToolBar = false
    }
    
    func rubberTapped() {
        isRubberMode = true
    }
    
    func brushTapped() {
        isRubberMode = false
    }
    
    func selectedAMasterpieceFromGallery() {
        if isUnsaved {
            let alertVC = UIAlertController(title: "Your current masterpiece is not saved", message: "you still want to switch to another masterpiece", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                self.currentMasterPiece = self.masterpieceFromGallery
            })
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            alertVC.addAction(yesAction)
            alertVC.addAction(noAction)
            
            present(alertVC, animated: true, completion: nil)
        } else {
            self.currentMasterPiece = self.masterpieceFromGallery
        }
    }

}

