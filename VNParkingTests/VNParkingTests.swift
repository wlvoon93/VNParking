//
//  VNParkingTests.swift
//  VNParkingTests
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import XCTest
@testable import VNParking

final class VNParkingTests: XCTestCase {
    
    typealias CarparkInfo = ParkingResponse.ParkingItem.CarparkData.CarParkInfo

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
        guard let parkingDisplay = sut.getParkingDisplay(carParkData: data) else { XCTFail("parkingDisplay cannot be nil")
            return
        }
        
        // get parking display
        sut.updateParkingDisplay(update: parkingDisplay, with: data)
        
        XCTAssertEqual(parkingDisplay.highestAvailableLotAmount.value, 9)
        XCTAssertEqual(parkingDisplay.highestLotIds.value, ["ABC"])
    }
    
    func testInitialState_whenHaveFirstData_atDifferentCarparkSize_InsertData() {
        // small carpark
        let smallData = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: smallData) else { XCTFail("parkingDisplay cannot be nil")
            return
        }
        sut.updateParkingDisplay(update: parking, with: smallData)
        
        // medium carpark
        let mediumData = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "120", lot_type: "C", lots_available: "17")], carpark_number: "DEF", update_datetime: "12345")
        guard let parking2 = sut.getParkingDisplay(carParkData: mediumData) else {
            return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking2, with: mediumData)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC"])
        
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestAvailableLotAmount.value, 17)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestLotIds.value, ["DEF"])
    }
    
    func test_whenHaveFirstDataAndNoLowest_andDataIsLower_insertIntoLowest() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 8)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["DEF"])
    }
    
    func test_whenHaveFirstDataAndNoLowest_andDataIsHigher_moveHighDataToLow() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "11")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 11)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["DEF"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["ABC"])
    }
    
    func test_whenHaveFirstDataAndHaveLowest_andDataIsLower_replaceLowest() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        // update 3
        let data3 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "6")], carpark_number: "FFG", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data3)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 6)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["FFG"])
    }
    
    func test_whenHaveFirstDataAndHaveLowest_andDataIsHigher_replaceHighest() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        // update 3
        let data3 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "11")], carpark_number: "FFG", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data3)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 11)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["FFG"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 8)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["DEF"])
    }
    
    func test_whenHaveFirstDataAndHaveLowest_andDataIsEqualHighest_appendIdToHighest() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        // update 3
        let data3 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "FFG", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data3)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC", "FFG"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 8)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["DEF"])
    }
    
    func test_whenHaveFirstDataAndHaveLowest_andDataIsGreaterThanLowestButLessThanHighest_noChange() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "99")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 99)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC"])
        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        // update 3
        let data3 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "FFG", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data3)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 99)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 8)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["DEF"])
    }
    
    func test_whenHaveFirstDataAndHaveLowest_andDataIsEqualLowest_appendIdToLowest() {
        // update 1
        let data = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "9")], carpark_number: "ABC", update_datetime: "12345")
        let sut = makeSUT()
        guard let parking = sut.getParkingDisplay(carParkData: data) else { return XCTFail("parkingDisplay cannot be nil")
        }
        sut.updateParkingDisplay(update: parking, with: data)

        
        // update 2
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "DEF", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data2)
        
        // update 3
        let data3 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "50", lot_type: "C", lots_available: "8")], carpark_number: "FFG", update_datetime: "12345")

        sut.updateParkingDisplay(update: parking, with: data3)
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.smallParkingDisplay.value?.highestLotIds.value, ["ABC"])
        
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestAvailableLotAmount.value, 8)
        XCTAssertEqual(sut.smallParkingDisplay.value?.lowestLotIds.value, ["DEF", "FFG"])
    }
    
    func test_whenResetParkingDisplay_clearAllParkingDisplay() {
        let sut = makeSUT()
        sut.mediumParkingDisplay.value?.highestAvailableLotAmount.accept(197)
        sut.mediumParkingDisplay.value?.highestLotIds.accept(["VB02"])
        sut.mediumParkingDisplay.value?.lowestAvailableLotAmount.accept(10)
        sut.mediumParkingDisplay.value?.lowestLotIds.accept(["VBB02"])
        
        sut.largeParkingDisplay.value?.highestAvailableLotAmount.accept(200)
        sut.largeParkingDisplay.value?.highestLotIds.accept(["VC02"])
        sut.largeParkingDisplay.value?.lowestAvailableLotAmount.accept(100)
        sut.largeParkingDisplay.value?.lowestLotIds.accept(["VCB02"])
        
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestAvailableLotAmount.value, 197)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestLotIds.value, ["VB02"])
        XCTAssertEqual(sut.mediumParkingDisplay.value?.lowestAvailableLotAmount.value, 10)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.lowestLotIds.value, ["VBB02"])
        
        XCTAssertEqual(sut.largeParkingDisplay.value?.highestAvailableLotAmount.value, 200)
        XCTAssertEqual(sut.largeParkingDisplay.value?.highestLotIds.value, ["VC02"])
        XCTAssertEqual(sut.largeParkingDisplay.value?.lowestAvailableLotAmount.value, 100)
        XCTAssertEqual(sut.largeParkingDisplay.value?.lowestLotIds.value, ["VCB02"])
        
        sut.resetParkingDisplay()
        
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestAvailableLotAmount.value, nil)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestLotIds.value, [])
        XCTAssertEqual(sut.mediumParkingDisplay.value?.lowestAvailableLotAmount.value, nil)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.lowestLotIds.value, [])
        
        XCTAssertEqual(sut.largeParkingDisplay.value?.highestAvailableLotAmount.value, nil)
        XCTAssertEqual(sut.largeParkingDisplay.value?.highestLotIds.value, [])
        XCTAssertEqual(sut.largeParkingDisplay.value?.lowestAvailableLotAmount.value, nil)
        XCTAssertEqual(sut.largeParkingDisplay.value?.lowestLotIds.value, [])
    }
    
    func test_integration_whenHaveMediumOneHighestTwoLowest_showMediumOneHighestTwoLowest() {
        let carparkInfo1: [CarparkInfo] = [.init(total_lots: "130", lot_type: "C", lots_available: "197"),
                                           .init(total_lots: "110", lot_type: "B", lots_available: "100")]
        let data1 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: carparkInfo1, carpark_number: "VB02", update_datetime: "12345")
        let carparkInfo2: [CarparkInfo] = [.init(total_lots: "130", lot_type: "C", lots_available: "0"),
                                           .init(total_lots: "110", lot_type: "B", lots_available: "9")]
        let data2 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: carparkInfo2, carpark_number: "XE01", update_datetime: "12345")
        let carparkInfo3: [CarparkInfo] = [.init(total_lots: "130", lot_type: "C", lots_available: "6"),
                                           .init(total_lots: "110", lot_type: "B", lots_available: "3")]
        let data3 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: carparkInfo3, carpark_number: "LP01", update_datetime: "12345")
        let data4 = ParkingResponse.ParkingItem.CarparkData.init(carpark_info: [.init(total_lots: "310", lot_type: "C", lots_available: "0")], carpark_number: "FFG", update_datetime: "12345")
        let parkingItem = ParkingResponse.ParkingItem.init(timestamp: "2023-08-06T09:23:27+08:00", carpark_data: [data1, data2, data3, data4])
        let parkingResponse = ParkingResponse.init(items: [parkingItem])
        let sut = makeSUT()
        sut.updateParkingWithResponse(response: parkingResponse)
        
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestAvailableLotAmount.value, 297)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.highestLotIds.value, ["VB02"])
        XCTAssertEqual(sut.mediumParkingDisplay.value?.lowestAvailableLotAmount.value, 9)
        XCTAssertEqual(sut.mediumParkingDisplay.value?.lowestLotIds.value, ["XE01", "LP01"])
    }
    
    func makeSUT() -> ParkingVM {
        let parkingVM = ParkingVM()
        return parkingVM
    }
}




