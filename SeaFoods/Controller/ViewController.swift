//
//  ViewController.swift
//  SeaFoods
//
//  Created by Madhu on 21/06/20.
//  Copyright © 2020 Madhu. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var imageView: UIImageView!
    
    var classificationResults : [VNClassificationObservation] = []
    let imagePicker           = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
    
    func detect(image: CIImage)
    {
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model)
            else
        {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model)
        { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else
            {
                fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            print(results)
            if topResult.identifier.contains("lab coat")
            {
                DispatchQueue.main.async
                    {
                        self.navigationItem.title = "Its A Madhu!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.navigationItem.title = "It's Not A Madhu Image!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage
        {
            
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciImage = CIImage(image: image)
                else
            {
                fatalError("couldn't convert uiimage to CIImage")
            }
            detect(image: ciImage)
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
}

