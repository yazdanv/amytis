//
//  Constants.swift
//  JsonViews
//
//  Created by Yazdan on 3/16/17.
//  Copyright © 2017 Yazdan. All rights reserved.
//

typealias cp = catchPhrases
typealias tp = topParams
typealias vp = viewParams
typealias lp = textParams
typealias ip = imageParams
typealias ap = actionParams
typealias fp = functionParams

public struct catchPhrases {
    static let valueIdentifier = "@/"
    static let valueIdentifier2 = "@/"
    static let traslationIdentifier = "t://"
    static let partsDivider = " // "
    static let sizeDivider = "--"
    static let listDivider = " *** "
    static let valueDividerShow = "->"
    static let valueDivider = "="
}

public struct topParams {
    static let languages: [String: [languageCodes: String]] = [
                                                                languageKeys.imageLocation: [.english: "Image Location", .persian: "مکان تصویر"],
                                                                languageKeys.photoLibrary: [.english: "Photo Library", .persian: "کتابخانه تصاویر"],
                                                                languageKeys.camera: [.english: "Camera", .persian: "دوربین"],
                                                                languageKeys.fromLibraryOrCamera: [.english: "From Library or Camera", .persian: "از دوربین یا کتابخانه"],
                                                                languageKeys.okAlertButton: [.english: "OK", .persian: "تایید"],
                                                                languageKeys.cancelAlertButton: [.english: "Cancel", .persian: "لغو"],
                                                                languageKeys.didGetMemoryWarning: [.english: "Application has a memory issue\n This page will be terminated", .persian: "اپلیکیشن با مشکل کمبود رم مواجه شده\nاین صفحه بسته میشود"]
    ]
    static let views = ["views"]
    static let code = ["code", "script"]
    static let type = "type"
    static let yes = ["yes", "true"]
    static let no = ["no", "false"]
    static let original = ["original", "origin"]
    static let topBar = ["topBar", "tpb", "tpBar", "topB"]
    static let key = ["key"]
    struct topBarTypes {
        static let simple = ["simple"]
    }
    struct topBarVals {
        static let title = ["title", "tt", "name"]
        static let titleView = ["titleView", "tView", "titleV", "titleview"]
    }
    static let status = ["status"]
}

public struct viewParams {
    static let type = ["type"]
    static let id = "id"
    static let _id = ["id", "identifier"]
    static let popUp = "popup"
    static let classs = ["class"]
    static let alpha = ["alpha", "opacity", "op"]
    static let interaction = ["interaction", "userInteraction"]
    static let circle = ["circle"]
    static let square = ["square", "sq"]
    static let hidden = ["hidden"]
    static let padding = ["padding"]
    static let iinsets = ["imageInsets", "iinsets", "insets"]
    static let tinsets = ["textInsets", "tinsets", "insets"]
    static let slide = "slide"
    static let backgroundColor = ["backgroundColor", "bgc", "backColor"]
    static let background = ["background", "bg"]
    static let elevation = ["elevation", "shadow"]
    static let cornerRound = ["corner", "round"]
    static let position = "pos"
    static let params = ["params", "parameters"]
    static let show = ["show"]
    struct showTypes {
        static let yes = ["yes", "true"]
        static let no = ["no", "false"]
    }
    static let itemSpace = ["itemSpacing", "itemSpace"]
    static let lineSpace = ["lineSpacing", "lineSpace"]
    static let size = ["size"]
    static let origin = ["origin"]
    static let frame = ["frame"]
    static let height = ["height", "hg", "h"]
    static let width = ["width", "wh", "w"]
    static let y = "y"
    static let x = "x"
    static let heightRatio = ["hRatio", "heightRatio", "heightR"]
    static let widthRatio = ["wRatio", "widthRatio", "widthR"]
    static let iphone = ["iphone", "phone"]
    static let ipad = ["ipad", "tablet"]
    static let leftGesture = ["leftGesture", "lGesture", "leftG"]
    static let rightGesture = ["rightGesture", "rGesture", "rightG"]
    static let upGesture = ["upGesture", "uGesture", "upG"]
    static let downGesture = ["downGesture", "dGesture", "downG"]
    static let scroll = ["scroll"]
}

public struct textParams {
    static let text = ["text"]
    static let lines = ["lines"]
    static let textSize = ["ts", "textSize"]
    static let font = ["font", "fnt"]
    static let placeholder = ["placeholder"]
    static let alignment = ["alignment", "textAlignment", "t-a"]
    struct alignments {
        static let rtl = ["right", "rightToLeft", "rtl"]
        static let ltr = ["left", "leftToRight", "ltr"]
        static let justified = ["just", "justified"]
    }
    static let inputType = ["input", "keyboardType", "inputType", "kt"]
    struct inputTypes {
        static let number = ["num", "number", "numpad", "numbers"]
    }
    static let borderStyle = ["borderStyle", "bs"]
    struct borderStyles {
        static let none = ["none"]
        static let line = ["line"]
        static let bezel = ["bezel"]
        static let round = ["round", "rect"]
    }
    struct controlEvents {
        static let editingDidBegin = ["editingDidBegin", "didBegin", "begin"]
        static let editingDidEnd = ["editingDidEnd", "didEnd", "end"]
        static let editingChanged = ["editingChanged", "changed"]
        static let editingDidEndOnExit = ["editingDidEndOnExit", "didEndOnExit", "endOnExit"]
    }
    static let textColor = ["textColor", "tc", "tColor"]
    static let placeholderColor = ["placeholderColor", "pc", "pColor"]
    static let dontTranslate = ["dontTranslate", "dTranslate", "dt"]
    static let secure = ["secure"]
    static let titleColor = ["titleColor", "tColor", "titleC"]
    static let titleSize = ["titleSize", "tSize", "titleS"]
    static let maxCharacters = ["maxCharacters", "maxChars", "mChars", "maximumCharacters", "mc"]
    static let fitToContent = ["fitToContent"]
}

public struct listParams {
    static let cellHeight = ["cellHeight", "rowHeight", "rh"]
    static let cell = ["cell", "row", "item"]
    static let slide = ["slide"]
    static let time = ["time"]
    static let header = ["head", "header", "section"]
    static let rowHeight = ["rowHeight", "rh"]
    static let fromJson = ["fromJson", "json", "fromJSON"]
    static let url = ["url"]
    static let count = ["count"]
    static let method = ["method"]
    static let storage = ["storeCells", "storage"]
    static let longPressDuration = ["longPressDuration", "lpDuration"]
    static let cellBack = ["cellBackground", "rowBackground", "itemBackground", "cellBack", "rowBack", "itemBack"]
    static let demo = ["demo"]
    static let bounce = ["bounce", "bounces"]
    static let direction = ["direction", "dir"]
    public struct directions {
        static let vertical = ["vertical", "ver"]
        static let horizontal = ["horizontal", "hor"]
    }
}

public struct actionParams {
    static let value = ["val", "value"]
    static let clicked = ["clicked", "click", "action", "select", "onSelect"]
    static let job = ["job", "toDo"]
    struct clickedTypes {
        static let open = ["open"]
        static let back = ["back"]
    }
}

public struct imageParams {
    static let source = ["source"]
    static let picker = ["picker","isPicker"]
    static let contentType = ["ct", "contentType"]
    struct contentTypes {
        static let aspectFill = ["aspectFill", "aFill"]
        static let aspectFit = ["aspectFit", "aFit"]
        static let fill = ["Fill", "fill"]
    }
}

public struct mapParams {
    static let center = ["center"]
    static let latitude = ["lat", "latitude"]
    static let longitude = ["lng", "longitude"]
    static let radius = ["radius"]
    static let current = ["current"]
    static let standard = ["standard", "normal"]
    static let hybrid = ["hybrid", "hyb"]
    static let satellite = ["satellite", "sat"]
    static let terrain = ["terrain", "terr"]
    static let showsTraffic = ["showsTraffic", "traffic"]
    static let locationBtn = ["myLocationButton", "locBtn", "locationButton"]
    static let zoomLevel = ["zoomLevel", "zoomL", "zLevel"]
    static let selectable = ["selectable"]
}

public struct jsParams {
    static let title = "title"
    static let time = "time"
}

struct param {
    static let event = "event"
    static let data = "data"
    static let getXml = "get_xml"
    static let getViewImage = "getViewImage"
    static let updateImage = "updateImage"
}

public struct functionParams {
    
}
