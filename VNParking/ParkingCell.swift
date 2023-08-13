//
//  ParkingCell.swift
//  VNParking
//
//  Created by Voon Wei Liang on 06/08/2023.
//

import UIKit
import Differentiator
import RxDataSources
import RxSwift
import RxCocoa

public protocol ValueCell: AnyObject {
    associatedtype Value
    static var defaultReusableId: String { get }
    func configureWith(value: Value)
}

extension ValueCell {
    public static var defaultReusableId: String {
        return String(describing: self)
    }
}

open class BSTTableViewCell: UITableViewCell, ValueCell {
    @objc open func configureWith(value: Any) {
    }
}

final class ParkingCell: BSTTableViewCell {
    
    private var disposeBag: DisposeBag!
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let highestAvailableLotAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = "some label"
        return label
    }()
    
    internal var viewModel: ParkingDisplayable?
    
    // MARK: - Initializer and Lifecycle Methods -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupListeners()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
    }

    public override func configureWith(value: Any) {
        guard let vm = value as? ParkingDisplayable else { return }
        self.viewModel = vm
        setupListeners()
    }
    
    // MARK: - Private API -
    private func setupSubviews() {
        
        selectionStyle = .none
        backgroundColor = .clear
        containerView.backgroundColor = .white
        
        contentView.addSubview(containerView)
        containerView.addSubview(highestAvailableLotAmountLabel)
        
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            highestAvailableLotAmountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            highestAvailableLotAmountLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            highestAvailableLotAmountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    private func setupListeners() {
        disposeBag = DisposeBag()
        
        viewModel?.highestAvailableLotAmount.subscribe(onNext: { [weak self] value in
            guard let strongSelf = self, let value else { return }
            
            strongSelf.highestAvailableLotAmountLabel.text = "\(value)"
        }).disposed(by: disposeBag)
    }
}
