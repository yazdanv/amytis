//
//  SMSExtension+MainAmytisController.swift
//  Alamofire
//
//  Created by Yazdan on 8/15/17.
//

import MessageUI
import JavaScriptCore

@objc public protocol AmytisControllerSMSJSExport: JSExport {
    func sendSMS(_ message: String, _ recipients: [String], _ sent: JSValue?, _ canceled: JSValue?, _ failed: JSValue?)
}

extension AmytisController: MFMessageComposeViewControllerDelegate, AmytisControllerSMSJSExport {
    
    public func sendSMS(message: String, recipients: [String], sent: (() -> Void)? = nil, canceled: (() -> Void)? = nil, failed: (() -> Void)? = nil) {
        _localActions["m_sent"] = sent
        _localActions["m_canceled"] = canceled
        _localActions["m_failed"] = failed
        let messageVC = MFMessageComposeViewController()
        messageVC.body = message;
        messageVC.recipients = recipients
        messageVC.messageComposeDelegate = self;
        self.present(messageVC, animated: false, completion: nil)
    }
    
    public func sendSMS(_ message: String, _ recipients: [String], _ sent: JSValue? = nil, _ canceled: JSValue? = nil, _ failed: JSValue? = nil) {
        var _sent: (() -> Void)? = nil
        var _canceled: (() -> Void)? = nil
        var _failed: (() -> Void)? = nil
        self.sendSMS(message: message, recipients: recipients, sent: _sent, canceled: _canceled, failed: _failed)
    }
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
            case .cancelled:
                _localActions["m_canceled"]?()
            case .failed:
                _localActions["m_failed"]?()
            case .sent:
                _localActions["m_sent"]?()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
