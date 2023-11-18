//
//  ViewController.swift
//  Lab3
//
//  Created by Matthew Ovie Enamuotor on 17/11/2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    private var isCelsius: Bool = true
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        displayImage(weatherCode: 0000)
        searchTextField.delegate = self
        locationManager.delegate = self
    }
    
    
    //onclick of temperature toggle switch
    @IBAction func onTempToggleTapped(_ sender: UISwitch) {
        isCelsius = sender.isOn
    }
    
    
    //onclick of the return button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: searchTextField.text)
        print(textField.text ?? "")
        return true
    }
    
    //display imge function with parameters
    private func displayImage(weatherCode: Int) {
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemOrange, .systemYellow, .black
        ])
        weatherConditionImage.preferredSymbolConfiguration = config
        
        var symbolName: String
                
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
                
        
        weatherConditionImage.image = UIImage(systemName: symbolName)
    }
    
    //onclick of search icon
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    //onclick of location icon
    @IBAction func onLocationTapped(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    //load weather function
    private func loadWeather(search: String?) {
        
        guard let search = search else {
            return
        }
        
        //get url
        guard let url = getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
        //create url session
        let session = URLSession.shared
        
        //create task for session
        let dataTask = session.dataTask(with: url) { [self] data, response, error in
            //network call finished
            
            
            guard error == nil else {
                print("received error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                    return
                }
            
            //parse the data
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    
                    self.locationLabel.text = "\(weatherResponse.location.name),  \(weatherResponse.location.region), \(weatherResponse.location.country)."
                    
                    self.weatherConditionLabel.text = "\(weatherResponse.current.condition.text)"
                    
                    //check temperature measurement (celsius or fahrenheit)
                    if self.isCelsius {
                      self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
                      } else {
                      self.temperatureLabel.text = "\(weatherResponse.current.temp_f)F"
                      }

                    //change image based on code
                    self.displayImage(weatherCode: weatherResponse.current.condition.code)
                    
                }
            }
                
            }
            
            //start the task
            dataTask.resume()
        }
    
    
        
        private func getURL(query: String) -> URL? {
            let baseUrl = "https://api.weatherapi.com/v1/"
            let currentEndpoint = "current.json"
            let apiKey = "d292794e2ffa49528d110148231811"
            guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return URL(string: url)
        }
        
        
    private func parseJson(data: Data) -> WeatherResponse? {
        
        //decode the data
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
            
        } catch {
            print("Error decoding")
        }
        
        return weather
    }
    }
    
struct WeatherResponse: Decodable{
    let location: Location
    let current: Weather
}

struct Location: Decodable{
    let name: String
    let region: String
    let country: String
}

struct Weather: Decodable{
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("we got a location")
        
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            //get latitude and longitude from location object
            let latAndLon: String =  "\(latitude),\(longitude)"
            
            //load the weather
            loadWeather(search: latAndLon)
            
        }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


class MyLocationDelegate: NSObject, CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            
            print("lat: \(latitude), long: \(longitude)")
        }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
