//
//  SectionSetter.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//
import Foundation
import RxCocoa
import RxDataSources

public extension UITableView {
    func registerCellClass <CellClass: UITableViewCell> (_ cellClass: CellClass.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueCell<CellClass: UITableViewCell>(_ cellClass: CellClass.Type, at indexPath: IndexPath) -> CellClass {
        return dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as! CellClass
    }
}

public protocol RelativeOrder {
    var sectionOrder: Int { get }
}

public protocol TableViewDataSource: CaseIterable {
    associatedtype Section where Section: SectionModelType, Section == Self
    var cellType: UITableViewCell.Type { get }
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<Section>
}

public protocol SectionSetter: AnyObject {
    associatedtype Section: SectionModelType & RelativeOrder
    var sectionedItems: BehaviorRelay<[Section]> { get }
    var sectionCache: [Int: Section] { get set}
        
    func setSection(_ section: Section)
}

public protocol SectionSetterPlus {
    associatedtype Section: SectionModelType & RelativeOrder
    var dataSource: RxTableViewSectionedReloadDataSource<Section> { get }
}

public extension SectionSetter {
    func setSection(_ section: Section) {
        sectionCache[section.sectionOrder] = section
        
        let sortedSection = sectionCache.sorted(by: { $0.0 < $1.0 }).map { $0.1 }
        sectionedItems.accept(sortedSection)
    }
}

public protocol TableViewSectionSetter: AnyObject {
    associatedtype Section: SectionModelType & RelativeOrder
    var dataSource: RxTableViewSectionedReloadDataSource<Section> { get }
}

public protocol CollectionViewSectionSetter: AnyObject {
    associatedtype Section: SectionModelType & RelativeOrder
    var dataSource: RxCollectionViewSectionedReloadDataSource<Section> { get }
}

public enum SectionMismatchError: Error {
    case missingSelf
}
