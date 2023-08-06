//
//  ParkingResponse.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import Foundation

public struct ParkingResponse: Decodable {
    let items: [ParkingItem]
    
    struct ParkingItem: Decodable {
        let timestamp: String
        let carpark_data: [CarparkData]
    }
}

extension ParkingResponse.ParkingItem {
    struct CarparkData: Decodable {
        let carpark_info: [CarParkInfo]
        let carpark_number: String
        let update_datetime: String
    }
}

extension ParkingResponse.ParkingItem.CarparkData {
    struct CarParkInfo: Decodable {
        let total_lots: String
        let lot_type: String
        let lots_available: String
    }
}
