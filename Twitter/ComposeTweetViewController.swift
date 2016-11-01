//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/31/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
protocol ComposeTweetViewControllerDelegate {
    func fromComposeTweet(tweet: Tweet)
}
class ComposeTweetViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tweetButton : UIButton!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var letterCount: UILabel!
   
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textCountView: UIView!
    var delegate : ComposeTweetViewControllerDelegate?
    
    let charLimit = 140
    var tweet : Tweet?
    let placeholder = "What's happening?"
    var isPlaceHolderShown : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.becomeFirstResponder()
        
        if(tweet != nil){
   
            textView.text = "@" + " "
            letterCount.text = "\(charLimit - textView.text.characters.count)"
            
        } else {
            self.profileImageView.setImageWith((User.currentUser?.profileURL)!)
            self.nameLabel.text = User.currentUser?.name!
            setPlaceholder()
        }
        
        

    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTweetClick(_ sender: UIButton) {
        
        var params = [String : String]()
        params["status"] = textView.text
        
        let currentUser = User.currentUser
        let username = "@" + (currentUser?.screenName)!
        let now = Date()
        let newTweet = Tweet(name: (currentUser?.name)!, screen_name: username, tweetText: textView.text, profileImageUrl: (currentUser?.profileURL)!,currentTime : now)
       
        
        TwitterClient.sharedInstance.postTweet(params: params, success: {
          
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
            }, failure: { (error : Error) in
               
        })
        
        delegate?.fromComposeTweet(tweet: newTweet)
    }
    
    @IBAction func onCloseClick(_ sender: AnyObject) {
        
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
           
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = -44
            } else {
                self.bottomConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: animationCurve,
                           animations: {},
                           completion: nil)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        
        
            let newCount = charLimit - textView.text.characters.count
            if(newCount < 20){
                
                letterCount.textColor = UIColor.red

            } else {
                
                letterCount.textColor = UIColor.lightGray
                
            }
            if(newCount < 0){
                tweetButton.isEnabled = false
            } else {
                tweetButton.isEnabled = true
            }
            letterCount.text = ("\(newCount)")
        
        
    }
    
    func setPlaceholder(){
        let startPosition : UITextPosition = textView.beginningOfDocument
        textView.text = placeholder
        textView.textColor =  UIColor.gray
        textView.selectedTextRange = textView.textRange(from: startPosition, to: startPosition)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText =  textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
      
        if updatedText.isEmpty {
            isPlaceHolderShown = true
            textView.text = placeholder
            textView.textColor = UIColor.gray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            tweetButton.isEnabled = false
            letterCount.text = "\(charLimit)"
            return false
        }
            
          
        else if textView.textColor == UIColor.gray && !text.isEmpty {
            isPlaceHolderShown = false
            textView.text = nil
            textView.textColor = UIColor.black
            tweetButton.isEnabled = true
            
        }
        return true
        
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
