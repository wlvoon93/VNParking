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
    
    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        return label
    }()
    
    private let highestAvailableLotAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let highestLotNumbersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let lowestAvailableLotAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let lowestLotNumbersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        
        return view
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
        
        if vm as? SmallParkingDisplay != nil {
            titleLabel.text = "SMALL"
        } else if vm as? MediumParkingDisplay != nil {
            titleLabel.text = "MEDIUM"
        } else if vm as? BigParkingDisplay != nil {
            titleLabel.text = "BIG"
        } else {
            titleLabel.text = "LARGE"
        }
    }
    
    // MARK: - Private API -
    private func setupSubviews() {
        
        selectionStyle = .none
        backgroundColor = .white
        containerView.backgroundColor = .white
        
        contentView.addSubview(containerView)
        contentView.addSubview(separatorView)
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(highestAvailableLotAmountLabel)
        containerStackView.addArrangedSubview(highestLotNumbersLabel)
        containerStackView.addArrangedSubview(lowestAvailableLotAmountLabel)
        containerStackView.addArrangedSubview(lowestLotNumbersLabel)
        
        containerStackView.setCustomSpacing(10, after: highestLotNumbersLabel)
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: -24),
            
            containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupListeners() {
        disposeBag = DisposeBag()
        
        viewModel?.highestAvailableLotAmount.subscribe(onNext: { [weak self] value in
            guard let strongSelf = self, let value else { return }
            
            strongSelf.highestAvailableLotAmountLabel.text = "HIGHEST (\(value) lots available)"
        }).disposed(by: disposeBag)
        
        viewModel?.highestLotIds.subscribe(onNext: { [weak self] value in
            guard let strongSelf = self else { return }
            
            var ids = ""
            for (index, id) in value.enumerated() {
                ids += id
                if index != value.count - 1 {
                    ids += ", "
                }
            }
            
            strongSelf.highestLotNumbersLabel.text = ids
        }).disposed(by: disposeBag)
        
        viewModel?.lowestAvailableLotAmount.subscribe(onNext: { [weak self] value in
            guard let strongSelf = self, let value else { return }
            
            strongSelf.lowestAvailableLotAmountLabel.text = "LOWEST (\(value) lots available)"
        }).disposed(by: disposeBag)
        
        viewModel?.lowestLotIds.subscribe(onNext: { [weak self] value in
            guard let strongSelf = self else { return }
            
            var ids = ""
            for (index, id) in value.enumerated() {
                ids += id
                if index != value.count - 1 {
                    ids += ", "
                }
            }
            
            strongSelf.lowestLotNumbersLabel.text = ids
        }).disposed(by: disposeBag)
    }
}
