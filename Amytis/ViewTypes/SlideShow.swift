//
//  SlideShow.swift
//  Pods
//
//  Created by Yazdan on 4/20/17.
//
//

import UIKit

public class SlideShow: TableView {
    
    public var slideCount = 0 {didSet{self.staticCount = slideCount}}
    var time: Double = 5
    var nowSlide = 1 {
        didSet {
            self._nowSlide = nowSlide - 1
        }
    }
    
    convenience init( _ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(parent, rect, object, slider: true)
        self._config(parent, object)
    }
    
    func _config(_ parent: AmytisView, _ object: XML) {
        object.double(listParams.time) {time in self.time = time}
        sliding()
    }
    
    public func slide(_ slide: @escaping ((AmytisView, Int) -> Void)) {
        self.__cell = {_slide, index in slide(_slide, index.row)}
    }
    
    public func slideIdForItem(_ action: @escaping ((Int) -> String)) {
        self.cellIdForIndex = {index in return action(index.row)}
    }
    public func slideForItem(_ action: @escaping ((Int) -> (String, ((AmytisView) -> Void)))) {
        self.cellIdForIndex2 = {index in return action(index.row)}
    }
    
    func sliding() {
        self.runWD(time) {
            self.next()
            self.sliding()
        }
    }
    
    public func next() {
        if slideCount > 1 {
            if nowSlide < slideCount {
                nowSlide += 1
            } else {
                nowSlide = 1
            }
        }
    }
    
    public func previous() {
        if slideCount > 1 {
            if nowSlide > 1 {
                nowSlide -= 1
            } else {
                nowSlide = slideCount
            }
        }
    }
    
}

