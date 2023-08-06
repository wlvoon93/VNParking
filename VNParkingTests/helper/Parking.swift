//
//  Parking.swift
//  VNParkingTests
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import Foundation
import VNParking

class Parking {
    static func getParkingResponse() -> ParkingResponse {
        let response = """
        {
          "items": [
            {
              "timestamp": "2023-08-06T09:23:27+08:00",
              "carpark_data": [
                   {
                     "carpark_info": [
                       {
                         "total_lots": "105",
                         "lot_type": "C",
                         "lots_available": "0"
                       }
                     ],
                     "carpark_number": "HE12",
                     "update_datetime": "2023-08-06T09:22:58"
                   },
                   {
                     "carpark_info": [
                       {
                         "total_lots": "583",
                         "lot_type": "C",
                         "lots_available": "488"
                       }
                     ],
                     "carpark_number": "HLM",
                     "update_datetime": "2023-08-06T07:01:02"
                   },
                   {
                     "carpark_info": [
                       {
                         "total_lots": "329",
                         "lot_type": "C",
                         "lots_available": "95"
                       }
                     ],
                     "carpark_number": "RHM",
                     "update_datetime": "2023-08-06T09:22:59"
                   },
                   {
                     "carpark_info": [
                       {
                         "total_lots": "97",
                         "lot_type": "C",
                         "lots_available": "87"
                       }
                     ],
                     "carpark_number": "BM29",
                     "update_datetime": "2023-08-06T06:01:17"
                   },
                   {
                     "carpark_info": [
                       {
                         "total_lots": "96",
                         "lot_type": "C",
                         "lots_available": "29"
                       }
                     ],
                     "carpark_number": "Q81",
                     "update_datetime": "2023-08-06T09:23:00"
                   },
                   {
                     "carpark_info": [
                       {
                         "total_lots": "176",
                         "lot_type": "C",
                         "lots_available": "14"
                       }
                     ],
                     "carpark_number": "C20",
                     "update_datetime": "2023-08-06T09:22:52"
                   }
               ]
             }
            ]
        }
                

        """
        
        let jsonData = response.data(using: .utf8)!
        let decoder = JSONDecoder()
        let serverResponse = try! decoder.decode(ParkingResponse.self, from: jsonData)
        
        return serverResponse
    }
    
    static func getParkingResponseFromJSON() -> ParkingResponse? {
        
        if let pathString = Bundle(for: Parking.self).path(forResource: "Parking", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: pathString), options: .mappedIfSafe)
                  let decoder = JSONDecoder()
                  let serverResponse = try! decoder.decode(ParkingResponse.self, from: data)
                  return serverResponse
              } catch {
                   // handle error
                  return nil
              }
        }
        
        return nil
    }
    
    func getSmallParking() {
        
    }
}
