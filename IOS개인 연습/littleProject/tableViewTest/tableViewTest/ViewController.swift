//
//  ViewController.swift
//  tableViewTest
//
//  Created by 전성훈 on 2023/05/13.
//

import UIKit

class ViewController: UIViewController {
    var data = ["1","2","3"]
    let sectionHeaders = ["SectionHeader1","SectionHeader2","3TestHeader"]
    var testAppend = [Date]()

    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var button = UIButton(configuration: .filled())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        view.addSubview(button)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -6).isActive = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.backgroundColor = .lightGray
        tableView.layer.cornerRadius = 8
        
        
        button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        button.setTitle("Check", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @objc func tapped() {
        testAppend.append(Date())
        
        tableView.isEditing = true

        tableView.reloadSections(IndexSet(2...2), with: .left)
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 || indexPath.section == 1 {
                data.remove(at: indexPath.row)
            } else {
                testAppend.remove(at: indexPath.row)
            }
        }

        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = testAppend[sourceIndexPath.row]
        testAppend.remove(at: sourceIndexPath.row)
        testAppend.insert(movedItem, at: destinationIndexPath.row)
        
        tableView.reloadSections(IndexSet(integer: 2), with: .left)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        } else {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modifyAction = UIContextualAction(style: .normal, title: "테스트") { action, view, completionHandler in
            print("test")
            completionHandler(true)
        }

        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] action, view, completionHandler in
            if indexPath.section == 0 || indexPath.section == 1 {
                self?.data.remove(at: indexPath.row)
            } else {
                self?.testAppend.remove(at: indexPath.row)
            }

            tableView.reloadData()
            completionHandler(true)
        }

        let configuartion = UISwipeActionsConfiguration(actions: [delete, modifyAction])
        return configuartion
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return data.count
        case 1:
            return data.count
        case 2:
            return testAppend.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = indexPath.description
        } else if indexPath.section == 1 {
            cell.textLabel?.text = data[indexPath.row]
        } else {
            let formatter = DateFormatter()
            
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            let dateString = formatter.string(from: testAppend[indexPath.row])
            
            cell.textLabel?.text = dateString
        }
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
//
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "Footer"
//    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .darkGray
        footerView.layer.cornerRadius =  8
        return footerView
    }
}


class TableViewCell: UITableViewCell {
    static let identifier = "Cell"
    
    
}
