//
//  Screen2ViewController.swift
//  Lab3
//
//  Created by Matthew Ovie Enamuotor on 23/11/2023.
//

import UIKit

class Screen2ViewController: UIViewController{
   
    
    //getting access to table view
    @IBOutlet weak var tableView: UITableView!
    
    //array passed from previous screen
    var searchDetails: [SearchDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
    
    
    @IBAction func onDeleteTap(_ sender: UIButton) {
        showAlert()
    }
    
    //on click of return home button
    @IBAction func OnReturnHomeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    private func showAlert() {
       
        
        let alert = UIAlertController(title: "Delete favorites", message: "Are you sure you want to delete all locations?", preferredStyle: .alert)
           
           let okButton = UIAlertAction(title: "OK", style: .default) { [weak self] action in
               
               // Clear the searchDetails array
               self?.searchDetails.removeAll()
               
               // Reload the table view to reflect the changes
               self?.tableView.reloadData()
           }
           
           let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
           alert.addAction(okButton)
           alert.addAction(cancelButton)
           
           present(alert, animated: true)
    }
    
}


extension Screen2ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        let searchDetail = searchDetails[indexPath.row]
        
        content.text = searchDetail.name
        content.secondaryText = "\(searchDetail.celsuis)°C, \(searchDetail.Fahrenheit)°F"
        
        // Assuming you have a method to get UIImage from icon code
        let image = getImageForWeatherCode(searchDetail.iconCode)
        content.image = image
        
        cell.contentConfiguration = content
        return cell
    }
    
   
    private func getImageForWeatherCode(_ weatherCode: Int) -> UIImage {
        
            let symbolName: String
            
            //configiuration with preferred styles
            let config: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [
                .systemOrange, .systemYellow, .black
            ])

                    
                    switch weatherCode {
                    case 0000:
                        symbolName = "questionmark.circle.fill"
                    case 1000:
                        symbolName = "sun.max.fill"
                    case 1003:
                           symbolName = "cloud.sun.fill"
                    case 1006:
                        symbolName = "cloud.fill"
                    case 1009:
                        symbolName = "smoke.fill"
                    case 1030:
                        symbolName = "cloud.fog.fill"
                    case 1063, 1066, 1069, 1072, 1087:
                        symbolName = "cloud.drizzle.fill"
                    case 1114, 1117, 1135, 1147:
                        symbolName = "cloud.fog.fill"
                    case 1150, 1153, 1168, 1171:
                        symbolName = "cloud.drizzle.fill"
                    case 1180, 1183, 1186, 1189, 1192, 1195:
                        symbolName = "cloud.heavyrain.fill"
                    case 1198, 1201, 1204, 1207:
                        symbolName = "cloud.sleet.fill"
                    case 1210, 1213, 1216, 1219, 1222, 1225:
                        symbolName = "cloud.snow.fill"
                    case 1237:
                        symbolName = "thermometer.snowflake"
                    case 1240, 1243, 1246:
                        symbolName = "cloud.sun.rain.fill"
                    case 1249, 1252, 1255, 1258:
                        symbolName = "cloud.sleet.fill"
                    case 1261, 1264:
                        symbolName = "cloud.snow.fill"
                    case 1273, 1276, 1279:
                        symbolName = "cloud.bolt.fill"
                    case 1282:
                        symbolName = "cloud.snow.fill"
                        
                    default:
                        symbolName = "questionmark.circle.fill"
                    }
                    
            
            // Return the styled image with the preferred configuration
            return UIImage(systemName: symbolName, withConfiguration: config) ?? UIImage()
        
    }

}


