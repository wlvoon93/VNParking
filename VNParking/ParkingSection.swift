//
//  ParkingSection.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import Foundation
import RxDataSources

public enum ParkingSection: SectionModelType {
    case small(item: SmallParkingDisplay?)
    case medium(item: MediumParkingDisplay?)
    case big(item: BigParkingDisplay?)
    case large(item: LargeParkingDisplay?)
    
    public var items: [Any] {
        switch self {
        case .small(let item):
            return item == nil ? [] : [item!]
        case .medium(let item):
            return item == nil ? [] : [item!]
        case .big(let item):
            return item == nil ? [] : [item!]
        case .large(let item):
            return item == nil ? [] : [item!]
        }
    }
    
    public init(original: ParkingSection, items: [Any]) {
        switch original {
        case .small:
            self = .small(item: items.first as? SmallParkingDisplay)
        case .medium:
            self = .medium(item: items.first as? MediumParkingDisplay)
        case .big:
            self = .big(item: items.first as? BigParkingDisplay)
        case .large:
            self = .large(item: items.first as? LargeParkingDisplay)
        }
    }
}

extension ParkingSection: TableViewDataSource {
    public typealias Section = ParkingSection
    
    public static var allCases: [ParkingSection] {
        return [
            .small(item: nil),
            .medium(item: nil),
            .big(item: nil),
            .large(item: nil)
        ]
    }
    
    public static func generateDataSource() -> RxTableViewSectionedReloadDataSource<ParkingSection> {
        return RxTableViewSectionedReloadDataSource<ParkingSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? SmallParkingDisplay {
                let newCell = tableView.dequeueCell(ParkingCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                
                cell = newCell
            } else if let viewModel = viewModel as? MediumParkingDisplay {
                let newCell = tableView.dequeueCell(ParkingCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                
                cell = newCell
            } else if let viewModel = viewModel as? BigParkingDisplay {
                let newCell = tableView.dequeueCell(ParkingCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? LargeParkingDisplay {
                let newCell = tableView.dequeueCell(ParkingCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            }
            
            return cell
        })
    }
    
    public var cellType: UITableViewCell.Type {
        switch self {
        case .small, .medium, .big, .large:
            return ParkingCell.self
        }
    }
}

extension ParkingSection: RelativeOrder {
    public var sectionOrder: Int {
        switch self {
        case .small:
            return 0
        case .medium:
            return 1
        case .big:
            return 2
        case .large:
            return 3
        }
    }
}
