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
import UniformTypeIdentifiers
import CoreLocation

class ChatDetailViewController: MessagesViewController {
    
    //MARK: - Vars
    var viewHasAppeared = false
    let realm = try! Realm()
    var timer = Timer()
    var recordTimer = Timer()
    var seconds = 0
    
    var mkMessages : [MKMessage] = []
    var allLocalMessages : Results<LocalMessage>!
    var notificationToken : NotificationToken?
    
    var avatarTapGesture : UIGestureRecognizer!
    var longPressGesture : UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    private var chatRoomId: String
    private var memberChatIds : [String]?
    var chatName : String?
    var chatAvatar : String?

    var guestData: User?{
        didSet{
            chatName = guestData?.username
            chatAvatar = guestData?.avatar
        }
    }
    var channelData : Channel?{
        didSet{
            chatName = channelData?.groupName
            chatAvatar = channelData?.avatarLink
        }
    }
    var isChannel : Bool{
        return channelData != nil
    }
    
    //tại sao lại sử dụng storeProperty thay vì computedProperty vì computedProperty sẽ đc tính lại mỗi lần truy cập còn cái này thì chỉ gọi 1 lần
//    lazy private var guestChatData: guestUser? = {
//        guard let userInfo = FirebaseChatListeners.shared.listUser[guestChatId] else {return nil}
//        return guestUser(username: userInfo.username, email: userInfo.email, avatar: userInfo.avatar, description: userInfo.description)
//    }()
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    //MARK: - UI Component
    let micButton = InputBarButtonItem()
    let subcribedBtn = InputBarButtonItem()
    let typingLabel = UILabel()

    lazy var refreshController = UIRefreshControl()
    lazy var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.mediaTypes = [UTType.image.identifier,UTType.movie.identifier]
        return controller
    }()
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    lazy var audioTimerStackView:UIStackView = {
        let audioTimerView = UIStackView()
        audioTimerView.spacing = 10
        audioTimerView.alignment = .center
        audioTimerView.axis = .horizontal
        audioTimerView.heightAnchor.constraint(equalToConstant: 40.6).isActive = true
        audioTimerView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        audioTimerView.isLayoutMarginsRelativeArrangement = true
        return audioTimerView
    }()
    lazy var squareView:UIView={
        let squareView = UIView()
        squareView.backgroundColor = UIColor.red
        squareView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        squareView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        return squareView

    }()
    lazy var timerRecordLabel:UILabel = {
        let timerRecordLabel = UILabel()
        timerRecordLabel.text = "00:00"
        return timerRecordLabel
    }()

    //MARK: - Init
    init(chatRoomId: String,memberChatIds : [String]?){
        self.chatRoomId = chatRoomId
        self.memberChatIds = memberChatIds
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationMessageCollectionView()
        configureGestureRecognizer()
        configurationInputBar()
        updateMicButtonStatus(isShow: true)
        listenerTypingStatus()
        
        imagePicker.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewHasAppeared {
            setupNavigationbar()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !viewHasAppeared {
            viewHasAppeared = true
            loadMessages()
            FirebaseChatListeners.shared.listenForNewMessage(chatRoomId: chatRoomId, lastMessageDate: lastMessageDate())
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioController.stopAnyOngoingPlaying()
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
        imageView.roundedImage(fromURL: URL(string : chatAvatar ?? ""), placeholderImage: UIImage(named: "avatar"))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(avatarTapGesture)
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
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarSize(.zero)
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(.zero)
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingCellBottomLabelAlignment(LabelAlignment(
            textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingCellBottomLabelAlignment(LabelAlignment(
            textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
    }
    
    private func configurationInputBar(){
        messageInputBar.delegate = self
        if isChannel && channelData!.adminId != User.currentId {
            messageInputBar.inputTextView.isHidden = true
            subcribedBtn.title = channelData!.memberIds.contains(User.currentId) ? "Unsubcribe" : "Subcribe"
            subcribedBtn.setSize(CGSize(width: 100,height: 10), animated: false)
            subcribedBtn.onTouchUpInside { item in
                self.followAction()
            }
            messageInputBar.setLeftStackViewWidthConstant(to: view.bounds.width, animated: false, animations: nil)
            messageInputBar.setRightStackViewWidthConstant(to: 0, animated: false)
            messageInputBar.setStackViewItems([subcribedBtn], forStack: .left, animated: false)
            return
        }
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.padding = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus",withConfiguration: UIImage.SymbolConfiguration(pointSize: 23))
        attachButton.setSize(CGSize(width: 23, height:23), animated: false)
        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false, animations: nil)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        micButton.image = UIImage(systemName: "mic.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 26))
        micButton.setSize(CGSize(width: 26, height: 26), animated: false)
        micButton.addGestureRecognizer(longPressGesture)
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false, animations: nil)
    }
    
    func updateMicButtonStatus(isShow : Bool){
        messageInputBar.setStackViewItems([ isShow ? micButton : messageInputBar.sendButton], forStack: .right, animated: false)
    }
    
    func configureGestureRecognizer(){
        avatarTapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToViewDetail))
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.3
        longPressGesture.delaysTouchesBegan = true
    }

    @objc func recordAudio(){
        switch longPressGesture.state {
            case .began:
                audioFileName = Date().stringDate()
                AudioRecordManager.share.startRecording(fileName: audioFileName)
                audioDuration = Date()
                setAudioTimerLabel()
                break
            case .ended :
                recordTimer.invalidate()
                AudioRecordManager.share.finishRecording()
                if fileExistAt(Path: audioFileName + ".m4a"){
                    //cần audioFileName để lấy nó từ local ra khi ghi âm nó tự lưu vào local r
                    sendMessage(text: nil, photo: nil, video: nil, location: nil, audio: audioFileName, audioDuration: Date().timeIntervalSince(audioDuration)-1)
                }
                messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: true)
                audioFileName = ""
                timerRecordLabel.text = "00:00"
                seconds = 0
                break
            default:
                print("Unknow longPressGesture state")
        }
    }
    
    func setAudioTimerLabel(){
        audioTimerStackView.addArrangedSubview(squareView)
        audioTimerStackView.addArrangedSubview(timerRecordLabel)
        messageInputBar.setMiddleContentView(audioTimerStackView, animated: true)
        recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRecordLabel), userInfo: nil, repeats: true)
    }

    @objc func updateRecordLabel() {
        seconds += 1
        let minutes = seconds / 60
        let seconds = seconds % 60
        timerRecordLabel.text = String(format: "%02d:%02d", minutes, seconds)
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
                await FirebaseChatListeners.shared.loadOldChat(chatRoomId: self.chatRoomId,isChannel)
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
    func sendMessage(text: String?, photo: UIImage?, video: URL?, location: CLLocationCoordinate2D?, audio: String?, audioDuration: Double = 0.0){
        DispatchQueue.global().async {
            OutComingMessage.sendMessageTo(chatRoomId: self.chatRoomId, text: text, photo: photo, video: video, location: location, audio: audio, audioDuration: audioDuration, memberIds: self.memberChatIds)
        }
    }
    
    //Follow & unfollow
    func followAction(){
        if channelData == nil {return}
        if channelData!.memberIds.contains(User.currentId){
            channelData!.memberIds = channelData!.memberIds.filter {$0 != User.currentId}
            subcribedBtn.title = "Subcribe"
        }
        else {
            subcribedBtn.title = "UnSubcribe"
            channelData!.memberIds.append(User.currentId)
        }
        FirebaseChannelListeners.shared.saveChannel(channel: channelData!)
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
            if !self.isChannel{
                FirebaseRefFor(collection: .Chat).document(self.chatRoomId).setData(["isRead" : [User.currentId : true]], merge: true)
            }
            FirebaseTypingListeners.shared.removeTypingObserver()
            FirebaseChatListeners.shared.newMessageListenter?.remove()
        }
    }
    
    //navigate To View Detail
    @objc func navigateToViewDetail(){
        let detailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailInfoView") as! DetailInfoTableViewController
        detailView.detailInfo = !isChannel ? .chat(guestData) : .channel(channelData)
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    
    //action attach message
    private func actionAttachMessage(){
        messageInputBar.inputTextView.resignFirstResponder()
        //Action Sheet
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takeAPics = UIAlertAction(title: "Take from camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let chooseAPics = UIAlertAction(title: "Choose from libary", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let shareLocation = UIAlertAction(title: "Share location", style: .default) { (action) in
            LocationManager.shared.requestNewLocation()
            LocationManager.shared.locationUpdateHandler = { location in
                self.sendMessage(text: nil, photo: nil, video: nil, location: location, audio: nil)
                LocationManager.shared.locationUpdateHandler = nil
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Bạn đã chọn Hủy")
        }
        takeAPics.setValue(UIImage(systemName: "camera"), forKey: "image")
        chooseAPics.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        alertController.addAction(takeAPics)
        alertController.addAction(chooseAPics)
        alertController.addAction(shareLocation)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - UIScrollView Delegate to load more
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


extension ChatDetailViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[.mediaType] as? String else {return}
        switch mediaType {
            case UTType.image.identifier:
                if  let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                    sendMessage(text: nil, photo: image, video: nil, location: nil, audio: nil)
                }
            case UTType.movie.identifier:
                if let videoURL = info[.mediaURL] as? URL {
                    sendMessage(text: nil, photo: nil, video: videoURL, location: nil, audio: nil)
                }
            default:
                print("You have nothing")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
