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
    
    // TODO: warn the user if there are unsave changes when the user does something else like
    //       sharing or choosing another masterpiece
    // TODO: implement cameraTapped

    @IBOutlet weak var drawingImageView: UIImageView!
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var colorPickerBarButton: UIBarButtonItem!
    @IBOutlet weak var undoBarButton: UIBarButtonItem!
    @IBOutlet weak var redoBarButton: UIBarButtonItem!
    @IBOutlet weak var rubberBarButton: UIBarButtonItem!
    @IBOutlet weak var brushBarButton: UIBarButtonItem!
    
    var brushButtonView: UIView!
    var eraserButtonView: UIView!
    var redoButtonView: UIView!
    var undoButtonView: UIView!
    var colorPickerButtonView: UIView!
    
    var verticleToolBar: UIView!
    var verticleToolBarOverlayView: UIView!
    
    var horizontalToolBar: UIView!
    
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
                //self.title = masterpiece.name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingImageView.backgroundColor = ColorScheme.PaleYellow
        initializeImageContextBGColor()
        
        setupHorizontalToolBar()
        setupVerticalToolBar()
    }
    
    func setupHorizontalToolBar() {
        
//        setupColorPickerButton()
//        setupUndoPickerButton()
//        setupRedoButton()
//        setupRubberButton()
//        setupMoreButton()
//        setupBrushButton()
        
        let space: CGFloat = 10
        var noOfItems = 0
        let buttonWidth: CGFloat = 26
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
        noOfItems += 1
        coordX += btContainerViewWidth + space
        
        eraserButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let eraserButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        eraserButton.setImage(UIImage(named: "eraser"), for: .normal)
        eraserButton.addTarget(self, action: #selector(DrawingViewController.rubberTapped), for: .touchUpInside)
        eraserButtonView.addSubview(eraserButton)
        eraserButtonView.backgroundColor = UIColor.white
        eraserButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfItems += 1
        coordX += btContainerViewWidth + space
        
        redoButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let redoButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        redoButton.setImage(UIImage(named: "redo"), for: .normal)
        redoButton.addTarget(self, action: #selector(DrawingViewController.redoTapped), for: .touchUpInside)
        redoButtonView.addSubview(redoButton)
        redoButtonView.backgroundColor = UIColor.white
        redoButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfItems += 1
        coordX += btContainerViewWidth + space
        
        undoButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let undoButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        undoButton.setImage(UIImage(named: "undo"), for: .normal)
        undoButton.addTarget(self, action: #selector(DrawingViewController.undoTapped), for: .touchUpInside)
        undoButtonView.addSubview(undoButton)
        undoButtonView.backgroundColor = UIColor.white
        undoButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfItems += 1
        coordX += btContainerViewWidth + space
        
        colorPickerButtonView = UIView(frame: CGRect(x: coordX, y: coordY, width: btContainerViewWidth, height: btContainerViewWidth))
        let colorPickerButton = UIButton(frame: CGRect(x: (btContainerViewWidth - buttonWidth) / 2.0, y: (btContainerViewWidth - buttonWidth) / 2.0, width: buttonWidth, height: buttonWidth))
        colorPickerButton.addTarget(self, action: #selector(DrawingViewController.colorPickerTapped), for: .touchUpInside)
        colorPickerButton.backgroundColor = currentColor
        colorPickerButton.layer.cornerRadius = buttonWidth / 2
        colorPickerButtonView.backgroundColor = UIColor.white
        colorPickerButtonView.addSubview(colorPickerButton)
        colorPickerButtonView.layer.cornerRadius = btContainerViewWidth / 2
        noOfItems += 1
        coordX += btContainerViewWidth + space
        
    
        horizontalToolBar = UIView(frame: CGRect(x: 0, y: 20, width: btContainerViewWidth * CGFloat(noOfItems) + CGFloat(noOfItems + 1) * space, height: horizontalToolBarHeight))
        
        horizontalToolBar.addSubview(brushButtonView)
        horizontalToolBar.addSubview(eraserButtonView)
        horizontalToolBar.addSubview(redoButtonView)
        horizontalToolBar.addSubview(undoButtonView)
        horizontalToolBar.addSubview(colorPickerButtonView)
        
        horizontalToolBar.backgroundColor = ColorScheme.Yellow
        horizontalToolBar.center.x = self.view.center.x
        horizontalToolBar.layer.cornerRadius = horizontalToolBarHeight / 2
        self.view.addSubview(horizontalToolBar)
    }
    
    func setupVerticalToolBar() {
        let space: CGFloat = 15.0
        var noOfItems = 0
        let verticleToolBarWidth: CGFloat = 40
        let buttonWidth: CGFloat = 30
        
        var coordY = space
        let coordX: CGFloat = (verticleToolBarWidth - buttonWidth) / 2
        
        let addNewButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        addNewButton.setImage(UIImage(named: "plus"), for: .normal)
        addNewButton.addTarget(self, action: #selector(DrawingViewController.addNewTapped), for: .touchUpInside)
        
        noOfItems += 1
        coordY += buttonWidth + space
        
        let cameraButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(DrawingViewController.cameraTapped), for: .touchUpInside)
        
        noOfItems += 1
        coordY += buttonWidth + space
        
        let saveButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        saveButton.setImage(UIImage(named: "save"), for: .normal)
        saveButton.addTarget(self, action: #selector(DrawingViewController.saveTapped), for: .touchUpInside)
        
        noOfItems += 1
        coordY += buttonWidth + space
        
        let shareButton = UIButton(frame: CGRect(x: coordX, y: coordY, width: buttonWidth, height: buttonWidth))
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.addTarget(self, action: #selector(DrawingViewController.shareTapped), for: .touchUpInside)
        
        noOfItems += 1
        coordY += buttonWidth + space
        
        verticleToolBar = UIView(frame: CGRect(x: 200, y: -200, width: verticleToolBarWidth, height: buttonWidth * CGFloat(noOfItems) + CGFloat(noOfItems + 1) * space))
        verticleToolBar.backgroundColor = ColorScheme.Yellow
        verticleToolBar.layer.cornerRadius = verticleToolBarWidth / 2.0
        
        verticleToolBar.addSubview(addNewButton)
        verticleToolBar.addSubview(cameraButton)
        verticleToolBar.addSubview(saveButton)
        verticleToolBar.addSubview(shareButton)
        
        
        verticleToolBarOverlayView = UIView(frame: self.view.frame)
        
        let shadowView = UIView(frame: self.view.frame)
        shadowView.backgroundColor = ColorScheme.PaleYellow
        
        verticleToolBarOverlayView.addSubview(shadowView)
        verticleToolBarOverlayView.isHidden = true
        verticleToolBarOverlayView.alpha = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DrawingViewController.hideverticleToolBar))
        verticleToolBarOverlayView.addGestureRecognizer(tap)
        
        
        self.view.addSubview(verticleToolBarOverlayView)
        self.view.addSubview(verticleToolBar)
        
    }
    
    func showverticleToolBar() {
        self.verticleToolBarOverlayView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.verticleToolBar.frame.origin.y = 64 + 10
            self.verticleToolBarOverlayView.alpha = 0.7
        })
    }
    
    func hideverticleToolBar() {
        UIView.animate(withDuration: 0.5, animations: { 
            self.verticleToolBar.frame.origin.y = -200
            self.verticleToolBarOverlayView.alpha = 0
        }) { (finished) in
            self.verticleToolBarOverlayView.isHidden = true
        }
    }
    
    func setupBrushButton() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let brushButton = UIButton(frame: CGRect(x: 7, y: 7, width: 26, height: 26))
        brushButton.addTarget(self, action: #selector(DrawingViewController.brushTapped), for: .touchUpInside)
        brushButton.setImage(UIImage(named: "paint-brush"), for: .normal)
        containerView.addSubview(brushButton)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderColor = ColorScheme.Orange.cgColor
        containerView.layer.borderWidth = 3
        
        brushBarButton.customView = containerView
    }
    
    func setupColorPickerButton() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorPickerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorPickerButton.backgroundColor = currentColor
        colorPickerButton.layer.cornerRadius = 20
        colorPickerButton.layer.borderColor = ColorScheme.Orange.cgColor
        colorPickerButton.layer.borderWidth = 3
        colorPickerButton.addTarget(self, action: #selector(DrawingViewController.colorPickerTapped), for: .touchUpInside)
        containerView.addSubview(colorPickerButton)
        colorPickerBarButton.customView = containerView
    }
    
    func setupUndoPickerButton() {
        let undoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        undoButton.addTarget(self, action: #selector(DrawingViewController.undoTapped), for: .touchUpInside)
        undoButton.setImage(UIImage(named: "undo"), for: .normal)
        undoBarButton.customView = undoButton
    }
    
    func setupRedoButton() {
        let redoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        redoButton.addTarget(self, action: #selector(DrawingViewController.redoTapped), for: .touchUpInside)
        redoButton.setImage(UIImage(named: "redo"), for: .normal)
        redoBarButton.customView = redoButton
    }
    
    func setupRubberButton() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let rubberButton = UIButton(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        rubberButton.addTarget(self, action: #selector(DrawingViewController.rubberTapped), for: .touchUpInside)
        rubberButton.setImage(UIImage(named: "eraser"), for: .normal)
        containerView.addSubview(rubberButton)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.layer.borderWidth = 3
        
        rubberBarButton.customView = containerView
    }
    
    func setupMoreButton() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let moreButton = UIButton(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        moreButton.addTarget(self, action: #selector(DrawingViewController.moreTapped), for: .touchUpInside)
        moreButton.setImage(UIImage(named: "more"), for: .normal)
        containerView.addSubview(moreButton)
        containerView.layer.cornerRadius = 20
        
        moreBarButton.customView = containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let masterpiece = currentMasterPiece {
            //self.title = masterpiece.name
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
        self.currentMasterPiece = masterpiece
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
            drawALine(first: firstPoint, second: firstPoint)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            secondPoint = touch.location(in: drawingImageView)
            drawALine(first: firstPoint, second: secondPoint)
            firstPoint = secondPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            secondPoint = touch.location(in: drawingImageView)
            drawALine(first: firstPoint, second: secondPoint)
            firstPoint = secondPoint
        }
    }
    
    // MARK: Customized Methods
    func moreTapped() {
        showverticleToolBar()
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
                //self.title = self.currentMasterPiece?.name
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
                CoreDataHelper.sharedInstance.updateAMasterpiece(masterpiece: self.currentMasterPiece!, newImage: self.drawingImageView.image!, newName:  (textField?.text)!)
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
            let activityController = UIActivityViewController(activityItems: [masterpiece.image!], applicationActivities: nil)
            // TODO: if saving to photo library, permission must be asked explicitly beforehand
            // if the users say no, we should ask them to change to settings
            
            // for iPad devices
            activityController.popoverPresentationController?.barButtonItem = moreBarButton
            present(activityController, animated: true, completion: nil)
        } else {
            Utilities.sharedInstance.popAlertView(parentVC: self, title: "Empty Masterpiece", message: "You need to save the masterpiece before sharing it.")
        }
    }
    
    func addNewMasterpiece() {
        //self.title = ""
        self.drawingImageView.image = nil
        self.currentMasterPiece = nil
        initializeImageContextBGColor()
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
        hideverticleToolBar()
        addNewMasterpiece()
    }
    
    func cameraTapped() {
        hideverticleToolBar()
        
        let alertVC = UIAlertController(title: "Coming Soon", message: "Import photos feature is coming soon", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func saveTapped() {
        hideverticleToolBar()
        saveMasterPiece()
    }
    
    func shareTapped() {
        hideverticleToolBar()
        shareMasterPiece()
    }
    
    func rubberTapped() {
        isRubberMode = true
    }
    
    func brushTapped() {
        isRubberMode = false
    }
    
}

