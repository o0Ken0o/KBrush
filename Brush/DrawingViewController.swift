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

    @IBOutlet weak var drawingImageView: UIImageView!
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var colorPickerBarButton: UIBarButtonItem!
    @IBOutlet weak var undoBarButton: UIBarButtonItem!
    @IBOutlet weak var redoBarButton: UIBarButtonItem!
    @IBOutlet weak var rubberBarButton: UIBarButtonItem!
    
    
    var isRubberMode: Bool = false {
        didSet {
            if isRubberMode {
                rubberBarButton.customView?.layer.borderColor = ColorScheme.Orange.cgColor
                colorPickerButton.layer.borderColor = UIColor.clear.cgColor
            } else {
                rubberBarButton.customView?.layer.borderColor = UIColor.clear.cgColor
                colorPickerButton.layer.borderColor = ColorScheme.Orange.cgColor
            }
        }
    }
    
    var colorPickerButton: UIButton!
    
    private var currentColor: UIColor = ColorScheme.Red
    
    private var currentBrushSize: CGFloat = 1.0
    private var firstPoint = CGPoint(x: 0, y: 0)
    private var secondPoint = CGPoint(x: 0, y: 0)
    
    private var lastSeriesImages = [UIImage?]()
    
    var currentMasterPiece: Masterpiece? {
        didSet {
            if let masterpiece = currentMasterPiece {
                self.drawingImageView.image = UIImage(data: (masterpiece.image as! Data))
                self.title = masterpiece.name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingImageView.backgroundColor = ColorScheme.PaleYellow
        initializeImageContextBGColor()
        
        setupColorPickerButton()
        setupUndoPickerButton()
        setupRedoButton()
        setupRubberButton()
        setupMoreButton()
    }
    
    func setupColorPickerButton() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorPickerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorPickerButton.backgroundColor = currentColor
        colorPickerButton.layer.cornerRadius = 20
        colorPickerButton.layer.borderColor = ColorScheme.Orange.cgColor
        colorPickerButton.layer.borderWidth = 3
        colorPickerButton.addTarget(self, action: #selector(DrawingViewController.colorPickerTapped), for: .touchUpInside)
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        imageView.image = UIImage(named: "paint-brush")
        containerView.addSubview(colorPickerButton)
        containerView.addSubview(imageView)
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
            self.title = masterpiece.name
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
                self.title = ""
                initializeImageContextBGColor()
            }
        }
    }
    
    // MARK: touches method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastSeriesImages.append(drawingImageView.image)
        
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
        let alertController = UIAlertController(title: "Menu", message: "", preferredStyle: .actionSheet)
        
        let newAction = UIAlertAction(title: "New", style: .default, handler: { (alert) in
            self.addNewMasterpiece()
        })
        alertController.addAction(newAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {(alert :UIAlertAction!) in
            self.saveMasterPiece()
        })
        alertController.addAction(saveAction)
        
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: {(alert :UIAlertAction!) in
            self.shareMasterPiece()
        })
        alertController.addAction(shareAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            // do nothing
        })
        alertController.addAction(cancelAction)
        
        // these two settings are for iPad devices
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = ((moreBarButton.value(forKey: "view") as? UIView)?.frame)!
        
        present(alertController, animated: true, completion: nil)
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
                self.title = self.currentMasterPiece?.name
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
                self.title = self.currentMasterPiece?.name
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
        self.title = ""
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
        if let last = lastSeriesImages.last {
            drawingImageView.image = last
            lastSeriesImages.removeLast()
        }
    }
    
    func redoTapped() {
        print("redo")
    }
    
    func rubberTapped(_ sender: Any) {
        isRubberMode = !isRubberMode
    }
    
}

