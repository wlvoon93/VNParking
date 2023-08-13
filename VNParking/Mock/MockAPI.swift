//
//  MockAPI.swift
//  VNParking
//
//  Created by Voon Wei Liang on 12/08/2023.
//

import Foundation

class MockAPI {
    static let fileObj = MockAPI()
    var count = 1
    private init() {
      
    }
    
    public func getParkingAPI(success: (ParkingResponse?) -> Void) {
        var response: ParkingResponse?
        if count % 2 == 0 {
            response = getResponseFromFile(filename: "Response1")
        } else {
            response = getResponseFromFile(filename: "Response2")
        }
        
        success(response)
        count += 1
    }
    
    private func getResponseFromFile(filename: String) -> ParkingResponse? {
        if let pathString = Bundle(for: MockAPI.self).path(forResource: filename, ofType: "json") {
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
}
