//
//  ProfileViewController.swift
//  ManUNews
//
//  Created by MILIKET on 2/26/17.
//  Copyright © 2017 Bình Anh Electonics. All rights reserved.
//
import UIKit
import SnapKit
import PHExtensions
import CleanroomLogger
import FBSDKLoginKit
import FBSDKCoreKit

class ProfileViewController: GeneralViewController {
    fileprivate enum Size: CGFloat {
        case padding15 = 15, padding5 = 5, padding10 = 10, button = 44
    }
    
    var loginFb: FBSDKLoginButton!
    
    //-------------------------------------------
    // MARK: - ENUM
    //-------------------------------------------
    
    /**
     Enum xác định các TextField
     */
    internal enum TextField: Int {
        case  name = 0, phone, email
    }
    
    var user: User!
    
    internal var back: UIBarButtonItem!
    internal var edit: UIBarButtonItem!
    
    
    var headerView: ProfileHeaderTableView!
    
    var table: UITableView!
    
    var selectedTextFeild: UITextField?
    var selectedImage: UIImage?
    
    
    var shadowAvatar: UIView!
    var avatarImage: UIImageView!
    
    var shadowConstaints: Constraint!
    var avatarConstraints: Constraint!
    
    var textFieldPhone: UITextField!
    var textFieldName: UITextField!
    var textFieldEmail: UITextField!
    
    /// Các thông báo
    var alertType: AlertType?
    enum AlertType {
        case editAvatar
        
        var title: String {
            switch self {
            case .editAvatar:
                return "Chọn ảnh đại diện"
            }
        }
        
        var message: String {
            switch self {
            case .editAvatar:
                return ""
            }
        }
    }
        
    /**
     Xác định đang sửa hay không
     */
    var isEditingProfile = false
    
    /**
     Title, ảnh của từng cell
     */
    lazy var textFieldArray:[(placeHolder: String, image: UIImage)]! = [
        ("Nhập tên", Icon.Register.Personal),
        ("Nhập số điện thoại", Icon.Register.Phone),
        ("Nhập email", Icon.Register.Email)
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User(name: nil, id: nil, email: nil, sex: nil, timeZone: nil)
        
        setupAllSubview()
        view.setNeedsUpdateConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            setupAllConstraints()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
}

//------------------------------
//MARK: SELECTOR
//------------------------------
extension ProfileViewController {
    
    func loginFb(_ sender: UIButton) {
        
        checkToken()
        
    }
    
    /**
     Nút Back
     */
    func back(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    /**
     Nút Done
     */
    func edit(_ sender: UIBarButtonItem) {
        
        switchEditingProfileState()
        
    }
    
    /**
     Chọn ảnh đại diện khác
     */
    func changeAvatar(_ sender: UITapGestureRecognizer) {
        
        hideKeyboard()
        showAlert(type: .editAvatar)
    }
    
    /**
     Lấy thông tin chiều cao của bàn phím khi hiện lên
     Để sau này tính offset cho các màn hình bé
     
     - parameter sender:
     */
    func keyboardWillShow(_ sender: Foundation.Notification) {
        if navigationController?.topViewController !== self { return }
        
        if let userInfo = (sender as NSNotification).userInfo {
            
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            let scrollPoint = CGPoint(x: 0.0, y: scrollHeight + keyboardHeight)
            if scrollPoint.y > 0 {
                table.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    func keyboardWillHide(_ sender: Foundation.Notification) {
        table.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
}

//------------------------------
//MARK: PRIVATE METHOD
//------------------------------
extension ProfileViewController {
        
    /**
     Ẩn Bàn phím
     */
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    /**
     Thay đổi giữa cho phép sửa và Done
     */
    fileprivate func switchEditingProfileState() {
        
        /**
         Nếu chưa cho phép sửa thì cho sửa
         */
        if !isEditingProfile {
            edit.image = Icon.Navi.done
            
            for textField in [textFieldPhone, textFieldName, textFieldEmail] {
                textField?.isEnabled = true
                textField?.alpha = 1.0
            }
            
            textFieldName.becomeFirstResponder()
            isEditingProfile = true
            
        }  else {
            
            if let email = textFieldEmail.text, email.characters.count > 0 && !Utility.shared.validateEmail(email) {
                HUD.showMessage("Email bạn nhập không đúng, xin vui lòng nhập lại.")
                return
            }
            
            edit.image = Icon.Navi.edit
            
            hideKeyboard()
            updateUserInfo()
            
        }
    }
    
    /// MARK: - Get Address
    internal func updateUserInfo() {
        
        isEditingProfile = false
        for textField in [textFieldPhone, textFieldName, textFieldEmail] {
            textField?.isEnabled = false
        }
    }
    
    /**
     Kiểm tra sửa tên hoặc email hay không
     */
    fileprivate func isUserInfoUpdated() -> Bool {
        return false
        
    }
    
    /**
     Reset Thông tin người dùng
     */
    fileprivate func resetUserInfo() {
        
    }
    
    func checkToken() {
                
        if FBSDKAccessToken.current() != nil {
            getProfile()
            
        } else {
            loginFacebook()
            
        }
        
    }
    
    /**
     Login with facebook account
     */
    func loginFacebook() {
        
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(
            withReadPermissions: ["public_profile","email","read_custom_friendlists"],
            from: self,
            handler: { (result, error) -> Void in
                Log.message(.debug, message: "result: \(result) \nerror: \(error)")
                if (error == nil) {
                    print("login facebook successfully")
                    self.getProfile()
                } else {
                    print(error ?? "error")
                }
            }
        )
    }
    
    /**
     get user information and fill to model
     */
    func getProfile() {
        
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: nil
        )
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil){
                Log.message(.debug, message: "Error: \(error)")
                
            } else {
                let data: [String: AnyObject] = result as! [String: AnyObject]
               
                Log.message(.debug, message: "result: \(data)")
                
                self.user = User(
                    name: data["name"] as? String,
                    id: data["id"] as? String,
                    email: data["email"] as? String,
                    sex: data["gender"] as? String,
                    timeZone: data["timezone"] as? Double
                )
                
                self.dismiss(animated: true) {
                    self.table.reloadData()
                }
            }
            
        })
        
        
    }
    
    
}

extension ProfileViewController: FBSDKLoginButtonDelegate {
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
        
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            
            
        } else {
            returnUserData()
        }
    }
    
    func returnUserData() {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields":"id,interested_in,gender,birthday,email,age_range,name,picture.width(480).height(480)"]
        )
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            }
            else {
                print("fetched user: \(result)")
            }
        })
    }
}

