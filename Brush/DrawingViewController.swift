//
//  DrawingViewController
//  Brush
//
//  Created by Ken Siu on 4/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {

    @IBOutlet weak var drawingImageView: UIImageView!
    @IBOutlet weak var topStackView: UIStackView!
    
    private var currentColor: UIColor = ColorScheme.Black
    private var currentBrushSize: CGFloat = 10.0
    private var firstPoint = CGPoint(x: 0, y: 0)
    private var secondPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: touches method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("began")
        UIView.animate(withDuration: 0.5) {
            self.topStackView.layer.opacity = 0.0
        }
        
        if let touch = touches.first {
            firstPoint = touch.location(in: drawingImageView)
            drawALine(first: firstPoint, second: firstPoint)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("moved")
        if let touch = touches.first {
            secondPoint = touch.location(in: drawingImageView)
            drawALine(first: firstPoint, second: secondPoint)
            firstPoint = secondPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("end")
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
        let alertController = UIAlertController(title: "Save or Share", message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {(alert :UIAlertAction!) in
            self.saveMasterPiece()
        })
        alertController.addAction(saveAction)
        
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: {(alert :UIAlertAction!) in
            self.shareMasterPiece()
        })
        alertController.addAction(shareAction)
            
        // these two settings are for iPad devices
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = ((sender.value(forKey: "view") as? UIView)?.frame)!
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveMasterPiece() {
        print("save button tapped")
    }
    
    func shareMasterPiece() {
        // if saving to photo library, permission must be asked explicitly beforehand
        print("share button tapped")
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
    
    func setStrokeColor(color: UIColor) {
        currentColor = color
    }
    
    
    
}

