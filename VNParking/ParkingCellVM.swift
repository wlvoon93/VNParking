//
//  ParkingCellVM.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import Foundation
import RxRelay

public protocol ParkingDisplayable {
    var isShowSeparator: BehaviorRelay<Bool> { get }
    var highestAvailableLotAmount: BehaviorRelay<Int?> { get }
    var highestLotIds: BehaviorRelay<[String]> { get }
    
    var lowestAvailableLotAmount: BehaviorRelay<Int?> { get }
    var lowestLotIds: BehaviorRelay<[String]> { get }
}

public class SmallParkingDisplay: ParkingDisplayable {
    public var isShowSeparator = BehaviorRelay<Bool>(value: true)
    
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}

public class MediumParkingDisplay: ParkingDisplayable {
    public var isShowSeparator = BehaviorRelay<Bool>(value: true)
    
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}

public class BigParkingDisplay: ParkingDisplayable {
    public var isShowSeparator = BehaviorRelay<Bool>(value: true)
    
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}

public class LargeParkingDisplay: ParkingDisplayable {
    public var isShowSeparator = BehaviorRelay<Bool>(value: true)
    
    public var highestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var highestLotIds = BehaviorRelay<[String]>(value: [])
    
    public var lowestAvailableLotAmount = BehaviorRelay<Int?>(value: nil)
    public var lowestLotIds = BehaviorRelay<[String]>(value: [])
}
