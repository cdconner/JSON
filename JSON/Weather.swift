//
//  Weather.swift
//  JSON
//
//  Created by Christopher Conner on 8/19/18.
//  Copyright © 2018 Christopher Conner. All rights reserved.
//

import CoreLocation
import Foundation

struct Weather {
    let summary: String
    let icon: String
    let temperature: Double
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json: [String: Any]) throws {
        guard let summary = json["summary"] as? String else {
            throw SerializationError.missing("Data is missing")
        }
        
        guard let icon = json["icon"] as? String else {
            throw SerializationError.missing("Icon is missing")
        }
        
        guard let temperature = json["temperatureMax"] as? Double else {
            throw SerializationError.missing("Temp is missing")
        }
            
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        
        }
    
    static let basePath = "https://api.darksky.net/forecast/5e2bc4635c24115bb3bc59d8ef8767c3/"
    
    static func forecast (withLocation location: CLLocationCoordinate2D, completion: @escaping ([Weather]) -> Void) {
    
        let url = basePath + "\(location.latitude),\(location.longitude)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            var forecastArray: [Weather] = []
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let dailyForecasts = json["daily"] as? [String: Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String: Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint)
                                    {
                                        forecastArray.append(weatherObject)
                                    }                                }
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
        
    }
    
    }
    

