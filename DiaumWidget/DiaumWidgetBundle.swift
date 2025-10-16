//
//  DiaumWidgetBundle.swift
//  DiaumWidget
//
//  Created by Ali Waseem on 2025-03-11.
//

import SwiftUI
import WidgetKit

@main
struct DiaumWidgetBundle: WidgetBundle {
  var body: some Widget {
    ProfileControlWidget()
    DiaumWidgetLiveActivity()
  }
}
