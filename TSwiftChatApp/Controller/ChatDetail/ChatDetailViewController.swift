//
//  ChatDetailViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 10/10/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import RealmSwift

class ChatDetailViewController: MessagesViewController {
    
    let realm = try! Realm()
    let micButton = InputBarButtonItem()
    
    private var chatRoomId: String
    private var memberChatIds : [String]
    private var chatName : String
    private var chatAvatar : String
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    var mkMessages : [MKMessage] = []
    var allLocalMessages : Results<LocalMessage>!
    var notificationToken : NotificationToken?
    
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
        setupNavigationbar()
        navigationItem.largeTitleDisplayMode = .never
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurationMessageCollectionView()
        configurationInputBar()
        updateMicButtonStatus(isShow: true)
        loadMessages()
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
        messageInputBar.padding = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus",withConfiguration: UIImage.SymbolConfiguration(pointSize: 23))
        attachButton.setSize(CGSize(width: 23, height:23), animated: false)
        attachButton.onTouchUpInside { item in
            print("attach button pressed")
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false, animations: nil)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        micButton.image = UIImage(systemName: "mic.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 26))
        micButton.setSize(CGSize(width: 26, height: 26), animated: false)
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false, animations: nil)
        
    }
    
    func updateMicButtonStatus(isShow : Bool){
        if isShow {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
        }
        else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            
        }
    }
    
    //MARK: - Load chat messages
    private func loadMessages(){
        let query = NSPredicate(format: "chatRoomId = %@", chatRoomId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(query).sorted(byKeyPath: "sentDate", ascending: true)
        notificationToken = allLocalMessages.observe({ (changes : RealmCollectionChange) in
            switch changes {
                case .initial(_):
                    self.insertMessages()
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                case .update(_, _, let insertions, _):
                    for index in insertions{
                        self.insertMessage(message: self.allLocalMessages[index])
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                    }
                case .error(let error):
                    print("Error when changing chat message \(error.localizedDescription)")
            }
        })
    }
    
    
    //MARK: - Action
    func sendMessage(text: String?, photo: UIImage?, video: String?, location: String?, audio: String?, audioDuration: Float = 0.0){
        OutComingMessage.sendMessageTo(chatRoomId: chatRoomId, text: text, photo: photo, video: video, location: location, audio: audio, audioDuration: audioDuration)
    }
    
    private func insertMessages(){
        for message in allLocalMessages{
            insertMessage(message: message)
        }
    }
    
    private func insertMessage(message : LocalMessage){
        let incoming = InComingMessage(messageViewController: self)
        mkMessages.append(incoming.convertMessage(message: message)!)
    }
}
