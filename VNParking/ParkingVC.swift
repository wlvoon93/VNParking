//
//  ParkingVC.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ParkingVC: UIViewController {
    class AutomaticHeightTableView: UITableView {
        
        override var contentSize: CGSize {
            didSet {
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    lazy var tableView: AutomaticHeightTableView = {
        let newTableView = AutomaticHeightTableView(frame: .zero)
        newTableView.separatorStyle = .none
        newTableView.estimatedRowHeight = UITableView.automaticDimension
        newTableView.rowHeight = UITableView.automaticDimension
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        newTableView.backgroundColor = .clear
        return newTableView
    }()

    public var viewModel = ParkingVM()
    private var disposeBag: DisposeBag!
    
    public init(viewModel: ParkingVM) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListeners()
        viewModel.getParkingData()
    }

    func setupView() {
        for section in ParkingSection.allCases {
            tableView.registerCellClass(section.cellType)
        }
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupListeners() {
        disposeBag = DisposeBag()
        
        viewModel.sectionedItems
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }
}

