//
//  WeatherViewController.swift
//  Weather_App
//
//  Created by administrator on 1/10/22.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var watherIcon: UIImageView!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    var weather: Weather?
    var hourArray : [Current]?
    var dailyArray : [Daily]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        
        dailyCollectionView.dataSource = self
        dailyCollectionView.delegate = self
        
        getWatherData()
        changeViewsRaduis()
    }
    
    func changeViewsRaduis(){
        mainView.layer.cornerRadius=15
        mainView.clipsToBounds=true
        
        mainStack.layer.cornerRadius=10
        mainStack.clipsToBounds=true
        
        hourlyCollectionView.layer.cornerRadius=10
        hourlyCollectionView.clipsToBounds=true
        
        dailyCollectionView.layer.cornerRadius=10
        dailyCollectionView.clipsToBounds=true
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.frame = view.bounds
//        view.addSubview(blurView)
        
    }
    
    
    func getWatherData()  {
        
        API.getAllWeatherData(completionHandler: {
            // see: Swift closure expression syntax
            data, response, error in
            print("in here get")
            
            // see: Swift nil coalescing operator (double questionmark)
            print(data ?? "no data get") // the "no data" is a default value to use if data is nil
            
            guard let myData = data else { return }
            do {
                
                let decoder = JSONDecoder()
                let jsonResult = try decoder.decode(Weather.self, from: myData)
               // print(jsonResult)
                
                DispatchQueue.main.async {
                    
                    self.weather = jsonResult
                    
                    self.temperatureLabel.text =  "\(Int(jsonResult.current.temp))°"
                    self.weatherDescription.text = jsonResult.current.weather[0].weatherDescription
                    
                    guard let sunset =  jsonResult.current.sunset else {return}
                    self.sunsetLabel.text = self.timeFormatter( Time: sunset)
                    
                    guard let sunrise =  jsonResult.current.sunrise else {return}
                    self.sunriseLabel.text = self.timeFormatter( Time: sunrise)
                    
                    self.humidityLabel.text = "\( jsonResult.current.humidity)%"
                    
                    self.pressureLabel.text = "\(jsonResult.current.pressure)"
                    
                    self.currentDateLabel.text = self.dateFormatter(Date: jsonResult.current.dt)
                    print(self.dateFormatter(Date: jsonResult.current.dt))
                    
                    self.watherIcon.downloaded(from: "http://openweathermap.org/img/wn/\(jsonResult.current.weather[0].icon)@2x.png")
                    
                    self.hourArray = (self.weather?.hourly)!
                    self.dailyArray = (self.weather?.daily)!
                    
                    self.hourlyCollectionView.reloadData()
                    self.dailyCollectionView.reloadData()
                    
                }
            }
            catch {
                print(error)
            }
        })
      
    }
    func timeFormatter(Time seconds: Int) -> String{
        let  formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
       let date = Date(timeIntervalSince1970: Double(seconds))
        
        let timeString = formatter.string(from: date)
        return timeString
    }
    func dateFormatter(Date seconds: Int) -> String{
        let  formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
       let date = Date(timeIntervalSince1970: Double(seconds))
        
        let dateString = formatter.string(from: date)
        return dateString
    }
       
    func getDayName(date:Int)->String{
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEEE"
        
           let  formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .none
          let convertedDate = Date(timeIntervalSince1970: Double(date))
           
           let dayInWeek = dateFormatter.string(from: convertedDate)
           return dayInWeek
       }
}
    extension WeatherViewController: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView ==  hourlyCollectionView{
                guard let hourArray = hourArray else { return 0 }
                return hourArray.count}
            else {
                  guard let dailyArray = dailyArray else { return 0 }
                  return dailyArray.count
                }
        }
        
        
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            
            
            if collectionView ==  hourlyCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourlyCollectionViewCell
                guard let hourArray =  hourArray else { return cell }
                
                cell.hourLabel.text = timeFormatter(Time: hourArray[indexPath.item].dt)
                cell.tempLabel.text = "\(String(describing: hourArray[indexPath.item].temp))"
                
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCollectionViewCell
                
                guard let dailyArray =  dailyArray else { return cell }
              
                cell.dayLabel.text = getDayName(date: dailyArray[indexPath.item].dt)
                cell.descriptionLabel.text = dailyArray[indexPath.row].weather[0].weatherDescription
             
                cell.weatherIcon.downloaded(from: "http://openweathermap.org/img/wn/\( dailyArray[indexPath.row].weather[0].icon)@2x.png")
                
                cell.minTemp.text = "\(dailyArray[indexPath.row].temp.min)"
                cell.maxTemp.text = "\(dailyArray[indexPath.row].temp.max)"

                return cell
                
                
            }
        }
    }


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


