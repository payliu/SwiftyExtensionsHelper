//
//  UISplitViewController+ToggleMasterView.swift
//  SwiftyExtensionsHelper
//
//  Created by Pay Liu on 2017-07-17.
//  Copyright © 2017 多多資訊有限公司. All rights reserved.
//

import Foundation

extension UISplitViewController {

    public func toggleMasterView() {

        let button = self.displayModeButtonItem;

        UIApplication.shared.sendAction(button.action!,
            to: button.target,
            from: nil,
            for: nil)

    }
}
