//
//  DrawingViewController
//  Brush
//
//  Created by Ken Siu on 4/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit
import CoreData

class DrawingViewController: UIViewController, GalleryViewControllerDelegate, SettingsViewControllerDelegate, ColorPickerViewDelegate {

    @IBOutlet weak var drawingImageView: UIImageView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var brushSize: UIButton!
    @IBOutlet weak var brushSizeLabel: UILabel!
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var colorPickerBarButton: UIBarButtonItem!
    
    var colorPickerButton: UIButton!
    
    private var currentColor: UIColor = ColorScheme.Blue {
        didSet {
//            brushSize.setTitleColor(currentColor, for: .normal)
            brushSizeLabel.textColor = currentColor
        }
    }
    
    private var currentBrushSize: CGFloat = 10.0 {
        didSet {
//            brushSize.setTitle("\(Int(currentBrushSize))", for: .normal)
            brushSizeLabel.text = "\(Int(currentBrushSize))"
        }
    }
    
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
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorPickerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorPickerButton.backgroundColor = currentColor
        colorPickerButton.layer.cornerRadius = 20
        colorPickerButton.layer.borderColor = UIColor.black.cgColor
        colorPickerButton.layer.borderWidth = 3
        colorPickerButton.addTarget(self, action: #selector(DrawingViewController.colorPickerTapped), for: .touchUpInside)
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        imageView.image = UIImage(named: "paint-brush")
        containerView.addSubview(colorPickerButton)
        containerView.addSubview(imageView)
        colorPickerBarButton.customView = containerView
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
        
        if segue.identifier == "SettingsViewController" {
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.customBrushSize = currentBrushSize
            settingsVC.customColor = currentColor
            settingsVC.delegate = self
        }
        
        if segue.identifier == "ColorPickerViewController" {
            let colorPickerVC = segue.destination as! ColorPickerViewController
            colorPickerVC.delegate = self
            colorPickerVC.colorSelected = currentColor
        }
    }
    
    // MARK: SettingsViewControllerDelegate
    func changeBrushSizeOrColor(settingsVC: SettingsViewController, brushSize: CGFloat, brushColor: UIColor) {
        currentBrushSize = brushSize
        currentColor = brushColor
    }
    
    // MARK: ColorPickerViewDelegate
    func colorSelected(color: UIColor) {
        colorPickerButton.backgroundColor = color
        currentColor = color
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
        UIView.animate(withDuration: 0.5) {
            self.topStackView.layer.opacity = 0.0
        }
        
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
        
        UIView.animate(withDuration: 0.5) {
            self.topStackView.layer.opacity = 1.0
        }
    }
    
    // MARK: Customized Methods
    @IBAction func moreTapped(_ sender: UIBarButtonItem) {
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
        alertController.popoverPresentationController?.sourceRect = ((sender.value(forKey: "view") as? UIView)?.frame)!
        
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
    
    func setStrokeColor(color: UIColor) {
        currentColor = color
//        brushSize.titleLabel?.textColor = color
        brushSizeLabel.textColor = color
    }
    
    
    @IBAction func changeColorTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            setStrokeColor(color: ColorScheme.Red)
        case 1:
            setStrokeColor(color: ColorScheme.Orange)
        case 2:
            setStrokeColor(color: ColorScheme.Yellow)
        case 3:
            setStrokeColor(color: ColorScheme.Green)
        case 4:
            setStrokeColor(color: ColorScheme.Blue)
        case 5:
            setStrokeColor(color: ColorScheme.Purple)
        default:
            setStrokeColor(color: currentColor)
        }
    }
    
    @IBAction func randomColor(_ sender: UIButton) {
        let random = ColorScheme.Random
        print(random)
        setStrokeColor(color: random)
        print("currentColor:\(currentColor)")
    }
    
    @IBAction func redo(_ sender: UIButton) {
        if let last = lastSeriesImages.last {
            drawingImageView.image = last
            lastSeriesImages.removeLast()
        }
    }
    
    @IBAction func changeBrushSize(_ sender: UIButton) {
        print("changeBrushSize")
        performSegue(withIdentifier: "SettingsViewController", sender: nil)
    }
    
    func colorPickerTapped() {
        performSegue(withIdentifier: "ColorPickerViewController", sender: nil)
    }
}

