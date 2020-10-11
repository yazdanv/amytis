//
//  JSCodes.swift
//  Amytis
//
//  Created by Yazdan Vakili on 5/17/18.
//  Copyright © 2018 Yazdan. All rights reserved.
//

import Foundation

var mainJsCode = """
    var open = function(name, params, st) {
        if (name && params && st) {
            self.jsOpen(name, params, st)
        } else if (name && params) {
            self.jsOpen(name, params, "Main")
        } else if (name) {
            self.jsOpen(name, {}, "Main")
        }
    }

    function openUrl(url) {
        self.openUrl(url)
    }

    function get(url, params) {
        if (params !== undefined) {
            request.JsRequest(url, "get", params)
        } else {
            request.JsRequest(url, "get", {})
        }
    }
    function post(url, params) {
        if (params !== undefined) {
            request.JsRequest(url, "post", params)
        } else {
            request.JsRequest(url, "post", {})
        }
    }

    function log(obj) {timerJS.log(obj)}


    function toast(message, completion, params) {
        if (message, completion, params) {
            self.jsToast(message, completion, params)
        } else if (message, completion) {
            self.jsToast(message, completion, {})
        } else if (message) {
            self.jsToast(message, function () {}, {})
        }
    }
    function choices(message, actions, params) {
        if (message, actions, params) {
            self.jsChoices(message, actions, params)
        } else if (message, actions) {
            self.jsChoices(message, actions, {})
        } else if (message) {
            self.jsChoices(message, {"ok": function () {}}, {})
        }
    }

    String.prototype.format = function () {
        a = this;
        for (k in arguments) {
            a = a.replace("{" + k + "}", arguments[k])
        }
        return a;
    }
"""
