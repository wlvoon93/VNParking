//
//  ParkingVM.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public protocol ParkingVMTypes: SectionSetter, TableViewSectionSetter where Section == ParkingSection {

}

public class ParkingVM: ParkingVMTypes {
    
    public var dataSource: RxTableViewSectionedReloadDataSource<Section> = Section.generateDataSource()
    public var sectionedItems: BehaviorRelay<[ParkingSection]> = BehaviorRelay(value: [])
    public var sectionCache = [Int: ParkingSection]()
    var count = 0
    
    var smallParkingDisplay = BehaviorRelay<SmallParkingDisplay?>(value: SmallParkingDisplay())
    var mediumParkingDisplay = BehaviorRelay<MediumParkingDisplay?>(value: MediumParkingDisplay())
    var bigParkingDisplay = BehaviorRelay<BigParkingDisplay?>(value: BigParkingDisplay())
    var largeParkingDisplay = BehaviorRelay<LargeParkingDisplay?>(value: LargeParkingDisplay())
    var displays: [(any ParkingDisplayable)?] {
        return [smallParkingDisplay.value, mediumParkingDisplay.value, bigParkingDisplay.value, largeParkingDisplay.value]
    }
    
    func getParkingDisplay(carParkData: ParkingResponse.ParkingItem.CarparkData) -> ParkingDisplayable? {
        
        let totalLots: Int = Int(carParkData.carpark_info.first?.total_lots ?? "") ?? 0
        if totalLots < 100 {
            return smallParkingDisplay.value
        } else if totalLots >= 100 && totalLots < 300 {
            return mediumParkingDisplay.value
        } else if totalLots >= 300 && totalLots < 400 {
            return bigParkingDisplay.value
        } else {
            return largeParkingDisplay.value
        }
    }
    
    func updateParkingDisplay(update display: ParkingDisplayable, with carParkData: ParkingResponse.ParkingItem.CarparkData) {
        
        let dataLotsAvailable = Int(carParkData.carpark_info.first?.lots_available ?? "") ?? 0
        let display = display
        count += 1
        print("\(count) highest highestAvailableLotAmount \(dataLotsAvailable) lot number \(carParkData.carpark_number)")
        
        if display.highestLotIds.value.isEmpty {
            var ids = display.highestLotIds.value
            ids.append(carParkData.carpark_number)
            display.highestLotIds.accept(ids)
            display.highestAvailableLotAmount.accept(dataLotsAvailable)
        } else if let amount = display.highestAvailableLotAmount.value,
                  dataLotsAvailable < amount,
                  display.lowestAvailableLotAmount.value == nil {
            display.lowestLotIds.accept([carParkData.carpark_number])
            display.lowestAvailableLotAmount.accept(dataLotsAvailable)
        } else if let amount = display.highestAvailableLotAmount.value,
                  dataLotsAvailable > amount,
                  display.lowestAvailableLotAmount.value == nil {
            display.lowestLotIds.accept(display.highestLotIds.value)
            display.lowestAvailableLotAmount.accept(display.highestAvailableLotAmount.value)
            
            display.highestLotIds.accept([carParkData.carpark_number])
            display.highestAvailableLotAmount.accept(dataLotsAvailable)
        } else if let amount = display.highestAvailableLotAmount.value,
                  dataLotsAvailable > amount {
            display.highestLotIds.accept([carParkData.carpark_number])
            display.highestAvailableLotAmount.accept(dataLotsAvailable)
        } else if let amount = display.highestAvailableLotAmount.value,
                 dataLotsAvailable == amount {
            var ids = display.highestLotIds.value
            ids.append(carParkData.carpark_number)
            display.highestLotIds.accept(ids)
        } else if let amount = display.lowestAvailableLotAmount.value,
                 dataLotsAvailable > amount {
            display.lowestLotIds.accept([carParkData.carpark_number])
            display.lowestAvailableLotAmount.accept(dataLotsAvailable)
        } else if let amount = display.lowestAvailableLotAmount.value,
                dataLotsAvailable < amount {
            display.lowestLotIds.accept([carParkData.carpark_number])
            display.lowestAvailableLotAmount.accept(dataLotsAvailable)
        } else if let amount = display.lowestAvailableLotAmount.value,
                dataLotsAvailable == amount {
            var ids = display.lowestLotIds.value
            ids.append(carParkData.carpark_number)
            display.lowestLotIds.accept(ids)
        }
    }
    
    func getParkingData() {
        // fetch the data, decode, update vm(rx)
        MockAPI.fileObj.getParkingAPI { response in
            if let response {
                updateParkingWithResponse(response: response)
                setSection(.small(item: smallParkingDisplay.value))
                setSection(.medium(item: mediumParkingDisplay.value))
                setSection(.big(item: bigParkingDisplay.value))
                setSection(.large(item: largeParkingDisplay.value))
            }
        }
    }
    
    func updateParkingWithResponse(response: ParkingResponse) {
        // cant update immediately as it will show gibberish
        // after done then update the real rx? use combine latest
        _ = response.items.first?.carpark_data.map { carparkData in
            if let parkingDisplay = getParkingDisplay(carParkData: carparkData) as? SmallParkingDisplay {
                
                updateParkingDisplay(update: parkingDisplay, with: carparkData)
            }
        }
    }
}
