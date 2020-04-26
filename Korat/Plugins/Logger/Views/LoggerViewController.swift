//
//  LoggerViewController.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2019/12/28.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import AppKit
import Combine

struct LoggerTableColumnIdentifier {
    static let type = NSUserInterfaceItemIdentifier(rawValue: "type")
    static let date = NSUserInterfaceItemIdentifier(rawValue: "date")
    static let message = NSUserInterfaceItemIdentifier(rawValue: "message")
    
    static let allCases: [NSUserInterfaceItemIdentifier]  = [
        LoggerTableColumnIdentifier.type,
        LoggerTableColumnIdentifier.date,
        LoggerTableColumnIdentifier.message
    ]
}

final class LoggerViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    private let presenter: LoggerPresentable
    
    private var messages: [LogMessage] = []
    
    private var cancellable: Set<AnyCancellable> = Set()
    
    init(presenter: LoggerPresentable) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setColumnWidth()
        
        presenter.messages.sink { [weak self] (messages) in
            self?.messages = messages
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &cancellable)
    }
    
    private func setColumnWidth() {
        let width = view.bounds.width
        let typeColumn = tableView.tableColumn(withIdentifier: LoggerTableColumnIdentifier.type)
        typeColumn?.width = width * 0.1
        
        let dateColumn = tableView.tableColumn(withIdentifier: LoggerTableColumnIdentifier.date)
        dateColumn?.width = width * 0.3
        
        let messageColumn = tableView.tableColumn(withIdentifier: LoggerTableColumnIdentifier.message)
        messageColumn?.width = width * 0.6
    }
    
    deinit {
        log.debug("\(String(describing: type(of: self))) deinit")
    }
}

extension LoggerViewController: NSTableViewDelegate {
    
}

extension LoggerViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let message = messages[row]
        switch tableColumn?.identifier {
        case LoggerTableColumnIdentifier.type:
            view.textField?.stringValue = message.level.description
        case LoggerTableColumnIdentifier.date:
            view.textField?.stringValue = "\(message.date)"
        case LoggerTableColumnIdentifier.message:
            view.textField?.stringValue = message.message
        default:
            return view
        }
        
        return view
    }
}

extension LogMessage.Level: CustomStringConvertible {
    var description: String {
        switch self {
        case .trace:
            return "Trace"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .critical:
            return "Critical"
        }
    }
}
