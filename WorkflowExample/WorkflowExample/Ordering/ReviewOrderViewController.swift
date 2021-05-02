//
//  ReviewOrderViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow
import WorkflowUIKit
import UIKit

class ReviewOrderViewController: UIWorkflowItem<Order, Order?>, StoryboardLoadable {
    var order: Order?

    @IBOutlet private weak var locationNameLabel: UILabel! {
        willSet(this) {
            this.text = order?.location?.name
        }
    }

    @IBOutlet private weak var menuLabel: UILabel! {
        willSet(this) {
            this.text = order?.menuType == .catering ? "Catering Menu" : "Regular Menu"
        }
    }

    @IBOutlet private weak var orderTypeLabel: UILabel! {
        willSet(this) {
            guard let order = order else { return }
            this.text = order.orderType == .pickup ? "Pickup" : "Delivery"
        }
    }

    @IBOutlet private weak var foodChoiceLabel: UILabel! {
        willSet(this) {
            this.text = order?.shoppingCart.compactMap { $0.name }.joined(separator: ", ")
        }
    }
}

extension ReviewOrderViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        return true
    }
}
