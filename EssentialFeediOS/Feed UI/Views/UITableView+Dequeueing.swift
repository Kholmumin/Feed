//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Kholmumin Tursinboev on 4/1/25.
//

import UIKit

extension UITableView{
    func dequeueTableViewCell<T: UITableViewCell>() -> T{
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
