//
//  GroupCell.swift
//  inTarget
//
//  Created by Desta on 27.04.2021.
//

import UIKit

protocol GroupCellDelegate: AnyObject {
    func didTapOpenGroupButton(groupID : String)
}

class GroupCell: UICollectionViewCell {
    private var groupID : String = ""
    
    weak var delegate: GroupCellDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamPro", size: 16)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamPro", size: 14)
        label.textColor = .separator
        label.textAlignment = .left
        return label
    }()
    
    private lazy var underTasksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamPro", size: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private lazy var lightUnderTasksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamPro", size: 14)
        label.textColor = .separator
        label.textAlignment = .right
        return label
    }()
    
    private lazy var textContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    lazy var openButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .accent
        return button
    }()
    
    
    private func setup() {
        [titleLabel, yearLabel, underTasksLabel, lightUnderTasksLabel].forEach {
            textContainer.addSubview($0)
        }
        [imageView, textContainer, openButton].forEach {
            contentView.addSubview($0)
        }
        
        backgroundColor = .lightAccent
        layer.cornerRadius = 18
        layer.masksToBounds = false
        
        openButton.addTarget(self, action: #selector(didTapOpenButton), for: .touchUpInside)
    }
    
    func configure(with group: Group) {
        titleLabel.text = group.title
        groupID = group.randomName
        
        let label: String = "целей"
        let labelUnderTasks = label.changeLabel(count: group.underTasks.count, label: label)
        underTasksLabel.text = String(group.underTasks.count) + " " + labelUnderTasks
        
        var completedTasks = 0
        let underTasks = group.underTasks
        for underTask in underTasks {
            if underTask.isCompleted == true {
                completedTasks += 1
            }
            
            lightUnderTasksLabel.text = "Осталось " + String(group.underTasks.count - completedTasks)
        }
        
        let oldDAteFormatter = DateFormatter()
        oldDAteFormatter.dateFormat = "dd MM yyyy"
        guard let oldDate = oldDAteFormatter.date(from: group.date) else {
            return
        }
        let newDAteFormatter = DateFormatter()
        newDAteFormatter.dateFormat = "dd MMMM yyyy"
        let newDate = newDAteFormatter.string(from: oldDate)
        
        yearLabel.text = newDate
        
        InjectionHelper.imageLoader.downloadGroupImage(group.image) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageView.image = image
            case .failure:
                return
            }
        }
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.pin
            .left(10)
            .height(45)
            .width(45)
            .vCenter()
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        
        textContainer.pin
            .right(10)
            .right(of: imageView)
            .marginLeft(10)
        
        underTasksLabel.pin
            .right()
            .height(16)
            .sizeToFit()
        
        lightUnderTasksLabel.pin
            .below(of: underTasksLabel)
            .right()
            .marginTop(6)
            .height(15)
            .sizeToFit()
        
        titleLabel.pin
            .left(of: underTasksLabel)
            .left()
            .height(16)
            .sizeToFit()
        
        yearLabel.pin
            .below(of: titleLabel)
            .left(of: lightUnderTasksLabel)
            .left()
            .marginTop(6)
            .height(15)
            .sizeToFit()
        
        textContainer.pin
            .wrapContent()
            .vCenter()
        
        openButton.pin
            .horizontally()
            .vertically()
    }
    
    @objc
    func didTapOpenButton() {
        guard !groupID.isEmpty else {
            return
        }
        delegate?.didTapOpenGroupButton(groupID: groupID)
    }
}
