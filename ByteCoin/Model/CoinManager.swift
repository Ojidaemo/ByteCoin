//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Vitali Martsinovich on 2023-02-15.
//

import Foundation

protocol CoinManagerDelegate {
    
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
    
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "74411D93-EDA4-4BC1-9695-13FE7DD34F8C"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    func getCoinPrice(for currency: String) {
        //1. Create a URL
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString) {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinRate = self.parseJSON(safeData) {
                        let rateString = String(format: "%.2f", bitcoinRate)
                        self.delegate?.didUpdatePrice(price: rateString, currency: currency)
                    }
                }
            }
                //4. Start the task
                task.resume()
            }
        }
        
        func parseJSON(_ data: Data) -> Double? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CoinData.self, from: data)
                let rate = decodedData.rate
                return rate
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    }
