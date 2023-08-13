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
    private class AutomaticHeightTableView: UITableView {
        
        override var contentSize: CGSize {
            didSet {
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    private lazy var tableView: AutomaticHeightTableView = {
        let newTableView = AutomaticHeightTableView(frame: .zero)
        newTableView.separatorStyle = .none
        newTableView.estimatedRowHeight = UITableView.automaticDimension
        newTableView.rowHeight = UITableView.automaticDimension
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        newTableView.backgroundColor = .white
        return newTableView
    }()
    
    weak var timer: Timer?

    public var viewModel = ParkingVM()
    private var disposeBag: DisposeBag!
    
    public init(viewModel: ParkingVM) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListeners()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    // MARK: setup
    private func setupView() {
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
        
        viewModel.smallParkingDisplay.subscribe(onNext: { [weak self] (value) in
            self?.viewModel.setSection(.small(item: value))
            
            self?.tableView.reloadSections(IndexSet([ParkingSection.Section.small(item: nil).sectionOrder]), with: .automatic)
        }).disposed(by: disposeBag)
        
        viewModel.mediumParkingDisplay.subscribe(onNext: { [weak self] (value) in
            self?.viewModel.setSection(.medium(item: value))
            self?.tableView.reloadSections(IndexSet([ParkingSection.Section.medium(item: nil).sectionOrder]), with: .automatic)
        }).disposed(by: disposeBag)
        
        viewModel.bigParkingDisplay.subscribe(onNext: { [weak self] (value) in
            self?.viewModel.setSection(.big(item: value))
            self?.tableView.reloadSections(IndexSet([ParkingSection.Section.big(item: nil).sectionOrder]), with: .automatic)
        }).disposed(by: disposeBag)
        
        viewModel.largeParkingDisplay.subscribe(onNext: { [weak self] (value) in
            self?.viewModel.setSection(.large(item: value))
            self?.tableView.reloadSections(IndexSet([ParkingSection.Section.large(item: nil).sectionOrder]), with: .automatic)
        }).disposed(by: disposeBag)
    }
    
    // MARK: methods
    private func loadData() {
        timer?.invalidate()
        viewModel.getParkingData()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.viewModel.getParkingData()
        }
    }
}

