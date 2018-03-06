//
//  imageViewController.swift
//  chatApp
//  This class is used to display image
//  Created by Ashutosh Kumar sai on 18/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class imageViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var imageDetails: UILabel!
    
    var detailOfImage = String()
    var selectModeOfImageSelection = 0
    var byteToImageValue = String()
    
    //We use viewDidLoad in order to display image
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        imageDetails.text = detailOfImage
        
        if(selectModeOfImageSelection == 1){
            selectedImage.image = #imageLiteral(resourceName: "imageAshish")
        } else {
            let data = Data(base64Encoded: byteToImageValue)
            selectedImage.image = UIImage(data: data! )

        }
        
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
