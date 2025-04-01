//
//  FocusQuestWidgetBundle.swift
//  FocusQuestWidget
//
//  Created by Christian Riccio on 01/04/25.
//

import WidgetKit
import SwiftUI

@main
struct FocusQuestWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusQuestWidget()
        FocusQuestWidgetControl()
        FocusQuestWidgetLiveActivity()
    }
}
