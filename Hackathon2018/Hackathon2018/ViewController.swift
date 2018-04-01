//
//  ViewController.swift
//  Hackathon2018
//
//  Created by Manav Maroli on 3/31/18.
//  Copyright © 2018 Manav Maroli. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Mark: Properties
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var numPeopleLabel: UILabel!
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    let session = URLSession.shared
    
    var googleAPIKey = "Api Key"
    var googleURL : URL {
        return URL(string : "https://vision.googleapis.com/v1/images:annotate?key=(googleAPIKey)")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        numberTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Actions
    @IBAction func openCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated : true, completion: nil)
            //imagePickerController(imagePicker, didFinishPickingMediaWithInfo: [String : AnyObject])
        }
        else {
            print("Couldn't open camera")
        }
        
    }
    
   // image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("Canceled")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        print("Good")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicked.contentMode = .scaleAspectFit
            imagePicked.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
//    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let int_num = Int(numberTextField.text!) {
            sharedData.numberOfPeople = int_num
        }
        print(sharedData.numberOfPeople)
    }
    
    @IBAction func saveImageButton(_ sender: UIButton) {
        let img = UIImageJPEGRepresentation(imagePicked.image!, 1.0)
        let resized = resizeImage(image: imagePicked.image!, targetSize: CGSize(width: 500, height: 500))
        let alert = UIAlertView(title: "Wow", message: "Image Saved and Ready!", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
        let image = UIImage(data: img!)
        let img_64 = base64EncodeImg(resized)
        alamoRequest(with: img_64)
        
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func base64EncodeImg(_ image : UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        
        return imageData!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
//    func createRequest(with imageBase64: String) {
//
//        var request = URLRequest(url : googleURL)
//
//        request.httpMethod = "Post"
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
//
//        let jsonRequest = [
//            "requests": [
//                "image": [
//                    "content": imageBase64
//                ],
//                "features": [
//                    [
//                        "type": "DOCUMENT_TEXT_DETECTION",
//                    ]
//                ]
//            ]
//        ]
//
//        let jsonObject = JSON( JSON : jsonRequest)
//
//        guard let data = try? jsonObject.rawData() else {
//            return
//        }
//
//        request.httpBody = data
//
//        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
//
//    }
//
//    
//    func runRequestOnBackgroundThread(_ request: URLRequest) {
//        let task : URLSessionDataTask = session.dataTask(with: request) { (data,response,error) in guard let data = data, error == nil else {
//                print(error?.localizedDescription ?? "")
//                return
//            }
//            print(data)
//        }
//        task.resume()
//    }
    
    func alamoRequest(with imageBase64: String) {
//        let array = ["type": "DOCUMENT_TEXT_DETECTION"]
        
//        let jsonRequest = [
//            "requests": [
//                "image": [
//                    "content": imageBase64
//                ],
//                "features": [
//                    ["type": "DOCUMENT_TEXT_DETECTION"]
//                ]
//            ]
//        ]
    
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyADHzSNG4f__zxduaG2nDhMSoX08B5K1Yc")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let values = [
            "requests": [
                ["image": ["content": imageBase64],
                 "features": [["type": "DOCUMENT_TEXT_DETECTION"]]
                ]
                
            ]
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request)
//        Alamofire.request(request, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                print("Response JSON: \(response.result.value)")
        }
//https://vision.googleapis.com/v1/images:annotate?key=AIzaSyADHzSNG4f__zxduaG2nDhMSoX08B5K1Yc"
    }
    
    
    
    
    
    
    
    
    
    
}

