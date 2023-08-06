//
//  VNParkingTests.swift
//  VNParkingTests
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import XCTest
@testable import VNParking

class ParkingVM {
    var smallParkingDisplay: SmallParkingDisplay
    var mediumParkingDisplay: MediumParkingDisplay
    var bigParkingDisplay: BigParkingDisplay
    var largeParkingDisplay: LargeParkingDisplay
    var displays: [ParkingDisplayable] {
        return [smallParkingDisplay, mediumParkingDisplay, bigParkingDisplay, largeParkingDisplay]
    }
    
    init(smallParkingDisplay: SmallParkingDisplay, mediumParkingDisplay: MediumParkingDisplay, bigParkingDisplay: BigParkingDisplay, largeParkingDisplay: LargeParkingDisplay) {
        self.smallParkingDisplay = smallParkingDisplay
        self.mediumParkingDisplay = mediumParkingDisplay
        self.bigParkingDisplay = bigParkingDisplay
        self.largeParkingDisplay = largeParkingDisplay
    }
    
    func getParkingDisplay(carParkData: ParkingResponse.ParkingItem.CarparkData) -> ParkingDisplayable {
        
        let totalLots: Int = Int(carParkData.carpark_info.first?.total_lots ?? "") ?? 0
        if totalLots < 100 {
            return smallParkingDisplay
        } else if totalLots >= 100 && totalLots < 300 {
            return mediumParkingDisplay
        } else if totalLots >= 300 && totalLots < 400 {
            return bigParkingDisplay
        } else {
            return largeParkingDisplay
        }
    }
    
    func updateParkingDisplay(update display: ParkingDisplayable, with carParkData: ParkingResponse.ParkingItem.CarparkData) {
        
        let dataLotsAvailable = Int(carParkData.carpark_info.first?.lots_available ?? "") ?? 0
        var display = display
        
        if display.highestLotIds.isEmpty {
            display.highestLotIds.append(carParkData.carpark_number)
            display.highestAvailableLotAmount = dataLotsAvailable
        } else if let amount = display.highestAvailableLotAmount,
                  dataLotsAvailable < amount,
                  display.lowestAvailableLotAmount == nil {
            display.lowestLotIds.append(carParkData.carpark_number)
            display.lowestAvailableLotAmount = dataLotsAvailable
        } else if let amount = display.highestAvailableLotAmount,
                  dataLotsAvailable > amount,
                  display.lowestAvailableLotAmount == nil {
            display.lowestLotIds = display.highestLotIds
            display.lowestAvailableLotAmount = display.highestAvailableLotAmount
            
            display.highestLotIds = [carParkData.carpark_number]
            display.highestAvailableLotAmount = dataLotsAvailable
            
            
        }
    }
}

final class VNParkingTests: XCTestCase {

    func testDecodeJSON() {
        let response = Parking.getParkingResponse()
        
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.carpark_data.count, 6)
        let lotDetails: ParkingResponse.ParkingItem.CarparkData.CarParkInfo? = response.items.first?.carpark_data.first?.carpark_info.first
        XCTAssertNotNil(lotDetails)
        XCTAssertEqual(lotDetails?.total_lots, "105")
        XCTAssertEqual(lotDetails?.lot_type, "C")
        XCTAssertEqual(lotDetails?.lots_available, "0")
    }

    func testDecodeJSONFromFile() {
        guard let response = Parking.getParkingResponseFromJSON() else {
            return XCTFail("response is nil")
        }
        
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.carpark_data.count, 1939)
        let lotDetails: ParkingResponse.ParkingItem.CarparkData.CarParkInfo? = response.items.first?.carpark_data.first?.carpark_info.first
        XCTAssertNotNil(lotDetails)
        XCTAssertEqual(lotDetails?.total_lots, "105")
        XCTAssertEqual(lotDetails?.lot_type, "C")
        XCTAssertEqual(lotDetails?.lots_available, "0")
    }
    
    func test_getSmallParkingDisplay() {
        let sut = makeSUT()
        let parkingDisplay = sut.getParkingDisplay(carParkData: .init(carpark_info: [.init(total_lots: "99", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345"))
        XCTAssertNotNil(parkingDisplay as? SmallParkingDisplay)
    }
    
    func test_getSmallParkingDisplay_whenTotalLotExceed_returnMediumInstead() {
        let sut = makeSUT()
        let parkingDisplay = sut.getParkingDisplay(carParkData: .init(carpark_info: [.init(total_lots: "100", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345"))
        XCTAssertNil(parkingDisplay as? SmallParkingDisplay)
        XCTAssertNotNil(parkingDisplay as? MediumParkingDisplay)
    }
    
    func test_getMediumParkingDisplay() {
        let sut = makeSUT()
        let parkingDisplay = sut.getParkingDisplay(carParkData: .init(carpark_info: [.init(total_lots: "150", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345"))
        XCTAssertNotNil(parkingDisplay as? MediumParkingDisplay)
    }
    
    func test_getBigParkingDisplay() {
        let sut = makeSUT()
        let parkingDisplay = sut.getParkingDisplay(carParkData: .init(carpark_info: [.init(total_lots: "350", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345"))
        XCTAssertNotNil(parkingDisplay as? BigParkingDisplay)
    }
    
    func test_getLargeParkingDisplay() {
        let sut = makeSUT()
        let parkingDisplay = sut.getParkingDisplay(carParkData: .init(carpark_info: [.init(total_lots: "400", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345"))
        XCTAssertNotNil(parkingDisplay as? LargeParkingDisplay)
    }
    
    func testInitialState_whenHaveFirstData_InsertData() {
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        let parkingDisplay = sut.getParkingDisplay(carParkData: data)
        
        // get parking display
        sut.updateParkingDisplay(update: parkingDisplay, with: data)
        
        XCTAssertEqual(parkingDisplay.highestAvailableLotAmount, 9)
        XCTAssertEqual(parkingDisplay.highestLotIds, ["ABC"])
    }
    
    func testInitialState_whenHaveFirstData_atDifferentCarparkSize_InsertData() {
        // small carpark
        let smallData = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        let parking = sut.getParkingDisplay(carParkData: smallData)
        sut.updateParkingDisplay(update: parking, with: smallData)
        
        // medium carpark
        let mediumData = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "120", lot_type: "C", lots_available: "17")], carpark_number: "DEF", update_datetime: "12345")
        let parking2 = sut.getParkingDisplay(carParkData: mediumData)
        sut.updateParkingDisplay(update: parking2, with: mediumData)
        
        XCTAssertEqual(sut.smallParkingDisplay.highestAvailableLotAmount, 9)
        XCTAssertEqual(sut.smallParkingDisplay.highestLotIds, ["ABC"])
        
        XCTAssertEqual(sut.mediumParkingDisplay.highestAvailableLotAmount, 17)
        XCTAssertEqual(sut.mediumParkingDisplay.highestLotIds, ["DEF"])
    }
    
    // different carpark sizes
    func test_whenHaveFirstDataAndNoLowest_andDataIsLower_insertIntoLowest() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        let parking = sut.getParkingDisplay(carParkData: data)
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        XCTAssertEqual(sut.smallParkingDisplay.highestAvailableLotAmount, 9)
        XCTAssertEqual(sut.smallParkingDisplay.highestLotIds, ["ABC"])
        
        XCTAssertEqual(sut.smallParkingDisplay.lowestAvailableLotAmount, 8)
        XCTAssertEqual(sut.smallParkingDisplay.lowestLotIds, ["DEF"])
    }
    
    // move to low
    func test_whenHaveFirstDataAndNoLowest_andDataIsHigher_moveHighDataToLow() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        let parking = sut.getParkingDisplay(carParkData: data)
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "11")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        XCTAssertEqual(sut.smallParkingDisplay.highestAvailableLotAmount, 11)
        XCTAssertEqual(sut.smallParkingDisplay.highestLotIds, ["DEF"])
        
        XCTAssertEqual(sut.smallParkingDisplay.lowestAvailableLotAmount, 9)
        XCTAssertEqual(sut.smallParkingDisplay.lowestLotIds, ["ABC"])
    }
    
    func makeSUT() -> ParkingVM {
        let small = SmallParkingDisplay(highestAvailableLotAmount: nil, highestLotIds: [], lowestAvailableLotAmount: nil, lowestLotIds: [])
        let medium = MediumParkingDisplay(highestAvailableLotAmount: nil, highestLotIds: [], lowestAvailableLotAmount: nil, lowestLotIds: [])
        let big = BigParkingDisplay(highestAvailableLotAmount: nil, highestLotIds: [], lowestAvailableLotAmount: nil, lowestLotIds: [])
        let large = LargeParkingDisplay(highestAvailableLotAmount: nil, highestLotIds: [], lowestAvailableLotAmount: nil, lowestLotIds: [])
        return ParkingVM(smallParkingDisplay: small, mediumParkingDisplay: medium, bigParkingDisplay: big, largeParkingDisplay: large)
    }
}

protocol ParkingDisplayable {
    var highestAvailableLotAmount: Int? { get set }
    var highestLotIds: [String] { get set }
    
    var lowestAvailableLotAmount: Int? { get set }
    var lowestLotIds: [String] { get set }
}

// loop the array
// small, medium, big, large
//
// highestAvailableLot, HighestLotNumbers, lowestAvailableLot, LowestLotNumbers
//
// for loop, check is small or medium, get medium display and
// compare, if higher
// update the ParkingDisplay, if same add to id
// compare, if lower
// update the ParkingDisplay, if same add to id
class SmallParkingDisplay: ParkingDisplayable {
    var highestAvailableLotAmount: Int?
    var highestLotIds: [String]
    
    var lowestAvailableLotAmount: Int?
    var lowestLotIds: [String]
    
    public init(highestAvailableLotAmount: Int?, highestLotIds: [String], lowestAvailableLotAmount: Int?, lowestLotIds: [String]) {
        self.highestAvailableLotAmount = highestAvailableLotAmount
        self.highestLotIds = highestLotIds
        self.lowestAvailableLotAmount = lowestAvailableLotAmount
        self.lowestLotIds = lowestLotIds
    }
}

class MediumParkingDisplay: ParkingDisplayable {
    var highestAvailableLotAmount: Int?
    var highestLotIds: [String]
    
    var lowestAvailableLotAmount: Int?
    var lowestLotIds: [String]
    
    public init(highestAvailableLotAmount: Int?, highestLotIds: [String], lowestAvailableLotAmount: Int?, lowestLotIds: [String]) {
        self.highestAvailableLotAmount = highestAvailableLotAmount
        self.highestLotIds = highestLotIds
        self.lowestAvailableLotAmount = lowestAvailableLotAmount
        self.lowestLotIds = lowestLotIds
    }
}

class BigParkingDisplay: ParkingDisplayable {
    var highestAvailableLotAmount: Int?
    var highestLotIds: [String]
    
    var lowestAvailableLotAmount: Int?
    var lowestLotIds: [String]
    
    public init(highestAvailableLotAmount: Int?, highestLotIds: [String], lowestAvailableLotAmount: Int?, lowestLotIds: [String]) {
        self.highestAvailableLotAmount = highestAvailableLotAmount
        self.highestLotIds = highestLotIds
        self.lowestAvailableLotAmount = lowestAvailableLotAmount
        self.lowestLotIds = lowestLotIds
    }
}

class LargeParkingDisplay: ParkingDisplayable {
    var highestAvailableLotAmount: Int?
    var highestLotIds: [String]
    
    var lowestAvailableLotAmount: Int?
    var lowestLotIds: [String]
    
    public init(highestAvailableLotAmount: Int?, highestLotIds: [String], lowestAvailableLotAmount: Int?, lowestLotIds: [String]) {
        self.highestAvailableLotAmount = highestAvailableLotAmount
        self.highestLotIds = highestLotIds
        self.lowestAvailableLotAmount = lowestAvailableLotAmount
        self.lowestLotIds = lowestLotIds
    }
}


