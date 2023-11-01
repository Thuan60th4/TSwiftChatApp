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
    var timer = Timer()
    let micButton = InputBarButtonItem()
    let typingLabel = UILabel()
    
    private var chatRoomId: String
    private var memberChatIds : [String]
    private var chatName : String
    private var chatAvatar : String
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    var mkMessages : [MKMessage] = []
    var allLocalMessages : Results<LocalMessage>!
    var notificationToken : NotificationToken?
    
    let refreshController = UIRefreshControl()
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
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
        configurationMessageCollectionView()
        configurationInputBar()
        updateMicButtonStatus(isShow: true)
        loadMessages()
        listenerTypingStatus()
        FirebaseChatListeners.shared.listenForNewMessage(chatRoomId: chatRoomId, lastMessageDate: lastMessageDate())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationbar()
    }
    
    //MARK: - Set up navigation bar
    private func setupNavigationbar(){
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backBtnPress))
        
        let chatTitle = UILabel()
        chatTitle.text = chatName
        chatTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        typingLabel.font = UIFont.systemFont(ofSize: 12)
        typingLabel.textColor = UIColor(named: "mainColor")
        typingLabel.text = ""
        
        let vStack = UIStackView(arrangedSubviews: [chatTitle,typingLabel])
        vStack.axis = .vertical
        vStack.alignment = .center
        navigationItem.titleView = vStack
        
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
        messagesCollectionView.refreshControl = refreshController
        messagesCollectionView.showsVerticalScrollIndicator = false
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
        messageInputBar.setStackViewItems([ isShow ? micButton : messageInputBar.sendButton], forStack: .right, animated: false)
    }
    
    //MARK: - Load chat messages
    private func loadMessages(){
        let query = NSPredicate(format: "chatRoomId = %@", chatRoomId)
        let queryForCurrentUser = NSPredicate(format: "memberLocalId = %@", User.currentId
        )
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [query,queryForCurrentUser])
        allLocalMessages = realm.objects(LocalMessage.self).filter(compoundPredicate).sorted(byKeyPath: "sentDate", ascending: true)
        
        if allLocalMessages.isEmpty{
            Task{
                await FirebaseChatListeners.shared.loadOldChat(chatRoomId: self.chatRoomId)
            }
        }
        notificationToken = allLocalMessages.observe({ (changes : RealmCollectionChange) in
            switch changes {
                case .initial(_):
                    self.insertMessages()
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                case .update(_, _, let insertions, _):
                    for index in insertions{
                        self.insertMessage(localMessage: self.allLocalMessages[index])
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                    }
                case .error(let error):
                    print("Error when changing chat message \(error.localizedDescription)")
            }
        })
    }
    
    
    //MARK: - Action
    
    //Typing status
    func typingMessageStatusUpdate(){
        FirebaseTypingListeners.shared.updateTyingStatus(typing: true, chatRoomId: chatRoomId)
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            FirebaseTypingListeners.shared.updateTyingStatus(typing: false, chatRoomId: self.chatRoomId)
        }
    }
    
    func listenerTypingStatus(){
        FirebaseTypingListeners.shared.createTypingObserver(chatRoomId: chatRoomId) { isTyping in
            self.typingLabel.text = isTyping ? "Typing..." : ""
        }
    }
    
    //Send message
    func sendMessage(text: String?, photo: UIImage?, video: String?, location: String?, audio: String?, audioDuration: Float = 0.0){
        OutComingMessage.sendMessageTo(chatRoomId: chatRoomId, text: text, photo: photo, video: video, location: location, audio: audio, audioDuration: audioDuration)
        startChat(message: text ?? "test", memberIds: memberChatIds)
    }
    
    //insert message to array
    private func insertMessages(){
        maxMessageNumber = allLocalMessages.count - displayingMessageCount
        minMessageNumber = maxMessageNumber - 12
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber{
            insertMessage(localMessage: allLocalMessages[i])
        }
    }
    
    private func insertMessage(localMessage : LocalMessage){
        let incoming = InComingMessage(messageViewController: self)
        mkMessages.append(incoming.convertMessage(message: localMessage)!)
        displayingMessageCount += 1
    }
    
    //load more
    private func insertOlderMessage(localMessage : LocalMessage){
        let incoming = InComingMessage(messageViewController: self)
        mkMessages.insert(incoming.convertMessage(message: localMessage)!, at: 0)
        displayingMessageCount += 1
    }
    
    private func loadMoreMessage(){
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - 12
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            insertOlderMessage(localMessage: allLocalMessages[i])
        }
    }
    
    //back action
    @objc func backBtnPress(){
        navigationController?.popViewController(animated: true)
        DispatchQueue.global().async {
            FirebaseRefFor(collection: .Chat).document(self.chatRoomId).setData(["isRead" : [User.currentId : true]], merge: true)
            FirebaseTypingListeners.shared.removeTypingObserver()
            FirebaseChatListeners.shared.newMessageListenter?.remove()
        }
    }
    
    //MARK: - UIScrollView Delegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if allLocalMessages.count > displayingMessageCount{
                loadMoreMessage()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
    
    //MARK: - Utils
    private func lastMessageDate() -> TimeInterval{
        let lastMessageDate = allLocalMessages.last?.sentDate ?? Date().timeIntervalSince1970
        return lastMessageDate + 1
    }
}
