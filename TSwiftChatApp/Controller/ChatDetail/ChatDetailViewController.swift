//
//  ChatDetailViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 10/10/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatDetailViewController: MessagesViewController {
    
    private var chatRoomId: String
    private var memberChatIds : [String]
    private var chatName : String
    private var chatAvatar : String
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let mkMessages : [MKMessage] = []
    
    //MARK: - Init
    init(chatRoomId: String,memberChatIds : [String],chatName : String,chatAvatar : String){
        self.chatRoomId = chatRoomId
        self.memberChatIds = memberChatIds
        self.chatName = chatName
        self.chatAvatar = chatAvatar
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationbar()
        configurationMessageCollectionView()
        configurationInputBar()
    }
    
    //MARK: - Set up navigation bar
    private func setupNavigationbar(){
        title = chatName
        
        let imageView = UIImageView()
        imageView.roundedImage(fromURL: URL(string : chatAvatar), placeholderImage: UIImage(named: "avatar"))
        let imageContain = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.frame = imageContain.bounds
        imageContain.addSubview(imageView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageContain)
    }
    
    //MARK: - Configuration
    private func configurationMessageCollectionView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    private func configurationInputBar(){
        messageInputBar.delegate = self
        messageInputBar.inputTextView.isImagePasteEnabled = false
        let attachButton = InputBarButtonItem()
        let micButton = InputBarButtonItem()
        
        attachButton.image = UIImage(systemName: "plus")
        attachButton.onTouchUpInside { item in
            print("attach button pressed")
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false, animations: nil)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        micButton.image = UIImage(systemName: "mic.fill")
        //        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false, animations: nil)
        //        messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
    }
    
    //MARK: - Action
    func sendMessage(text: String?, photo: UIImage?, video: String?, location: String?, audio: String?, audioDuration: Float = 0.0){
        OutgoingMessage.sendMessageTo(chatRoomId: chatRoomId, text: text, photo: photo, video: video, location: location, audio: audio, audioDuration: audioDuration)
    }
    
    
}
