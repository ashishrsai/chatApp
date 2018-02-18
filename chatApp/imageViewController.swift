//
//  imageViewController.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 18/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class imageViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var imageDetails: UILabel!
    
    var detailOfImage = String()
    var imageForSelectedImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedImage.image = imageForSelectedImage
        imageDetails.text = detailOfImage
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
