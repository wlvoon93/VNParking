//
//  ParkingCellVM.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import Foundation
import RxRelay

public protocol ParkingDisplayable {
    var highestAvailableLotAmount: BehaviorRelay<Int?> { get set }
    var highestLotIds: BehaviorRelay<[String]> { get set }
    
    var lowestAvailableLotAmount: BehaviorRelay<Int?> { get set }
    var lowestLotIds: BehaviorRelay<[String]> { get set }
}

public class SmallParkingDisplay: ParkingDisplayable {
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}

public class MediumParkingDisplay: ParkingDisplayable {
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}

public class BigParkingDisplay: ParkingDisplayable {
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}

public class LargeParkingDisplay: ParkingDisplayable {
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}
