//
//  API.swift
//  Weather_App
//
//  Created by administrator on 1/10/22.
//

import Foundation

class API{
    
    static func getAllWeatherData(completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
       
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=26.4207&lon=50.0888&appid=f2763f64328617a339894577e9107052&units=metric")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: completionHandler)
        task.resume()
        
    }
}
