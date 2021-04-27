//
//  TargetsController.swift
//  inTarget
//
//  Created by Георгий on 06.04.2021.
//

import UIKit
import PinLayout

final class TargetsController: UIViewController {
    private let headLabel = UILabel()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(TaskCell.self, forCellWithReuseIdentifier: "TaskCell")
        cv.register(NewTaskCell.self, forCellWithReuseIdentifier: "NewTaskCell")
        return cv
    }()
    
    private let database = DatabaseModel()
    
    var data: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        reloadTasks()
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(headLabel)
        
        headLabel.text = "Цели"
        headLabel.textColor = .black
        headLabel.font = UIFont(name: "GothamPro", size: 34)
        
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headLabel.pin
            .top(view.pin.safeArea.top + 30)
            .left(view.pin.safeArea.left + 30)
            .sizeToFit()
        
        collectionView.pin
            .below(of: headLabel)
            .marginTop(30)
            .horizontally()
            .height(220)
    }
    
    @objc
    func didTapAddButton() {
        tabBarController?.selectedIndex = 1
    }
    
    @objc
    func didTapOpenButton(taskID : String) {
        (self.tabBarController as? MainTabBarController)?.openGoal(with: taskID)
    }
    
    public func reloadTasks() {
        database.getTasks { result in
            switch result {
            case .success(let tasks):
                self.data = tasks
                self.collectionView.reloadData()
            case .failure:
                return
            }
        }
    }
}

extension TargetsController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.1, height: 177)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == data.count {
            guard let newTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTaskCell", for: indexPath) as? NewTaskCell else {
                return UICollectionViewCell()
            }
            
            newTaskCell.delegate = self
            return newTaskCell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UICollectionViewCell()
        }
    
        let task = data[indexPath.row]
        cell.configure(with: task)
        cell.delegate = self
        
        return cell
    }

}

extension TargetsController: TaskCellDelegate, NewTaskCellDelegate {
    func didTapOpenTaskButton(taskID : String) {
        didTapOpenButton(taskID: taskID)
    }
    
    func didTapActionButton() {
        didTapAddButton()
    }
}
