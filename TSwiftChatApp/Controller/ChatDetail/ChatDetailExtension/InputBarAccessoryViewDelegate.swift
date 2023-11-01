//
//  InputBarAccessoryViewDelegate.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 13/10/2023.
//

import Foundation
import InputBarAccessoryView

extension ChatDetailViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != ""{
            typingMessageStatusUpdate()
        }
        updateMicButtonStatus(isShow: text == "")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String{
                sendMessage(text: text, photo: nil, video: nil, location: nil, audio: nil)
            }
        }
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
    }
}
