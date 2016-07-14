import UIKit
import CoreData
import Alamofire
import Darwin

class MainScreen : UIViewController {
    
    // This value matches the left menu's width in the Storyboard
    let leftMenuWidth:CGFloat = 260
    
    // Need a handle to the scrollView to open and close the menu
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
    
    let url: String = "https://users-ofertapp.herokuapp.com/todo/"

    struct offersData {
        static var offerModel = [OffersModel]()
    }
    
    struct userData {
        static var userNickname : String = ""
        static var userEmail : String = ""
        static var userID : String = ""
        static var userAdmin : Bool = false
        static var userVersion : Int = 0
    }
    
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    var myPageViewController: MyPageViewController?{
        didSet {
            myPageViewController?.myDelegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        offersData.offerModel = OffersModel.loadOffers()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initially close menu programmatically.  This needs to be done on the main thread initially in order to work.
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
                
        // Tab bar controller's child pages have a top-left button toggles the menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuButtonPressed", name: "menuButtonPressed", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeMenuViaNotification", name: "closeMenuViaNotification", object: nil)
        
        // LeftMenu sends openAddOffer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openAddOffer", name: "openAddOffer", object: nil)
        
        // LeftMenu sends openSettings
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openSettings", name: "openSettings", object: nil)
        
        // LeftMenu sends openHelp
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openHelp", name: "openHelp", object: nil)
        
        // LeftMenu sends deleteUser
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteUser", name: "deleteUser", object: nil)
        
        // LeftMenu sends logout
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "logout", object: nil)
        
        
        // OfferTable sends menuButtonHidden
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuButtonHidden", name: "menuButtonHidden", object: nil)
        
        // OfferTable sends menuButtonShow
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuButtonShow", name: "menuButtonShow", object: nil)
        
        // Selected Tab Map
        mapTabSelected()

        fetchData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        // Initially close menu programmatically.  This needs to be done on the main thread initially in order to work.
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
    }
    
    func fetchData () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let user = appDelegate.managedObjectContext
        let userFetch = NSFetchRequest(entityName: "User")
        
        do {
            let fetchedUser = try user.executeFetchRequest(userFetch) as! [User]
            userData.userNickname = fetchedUser.first!.nickname!
            userData.userEmail = fetchedUser.first!.email!
            userData.userID = fetchedUser.first!.id!
            userData.userVersion = fetchedUser.first!.version!.integerValue
            
            if fetchedUser.first!.admin! == 1 {
                userData.userAdmin = true
            } else if fetchedUser.first!.admin! == 0 {
                userData.userAdmin = false
            } else {
                print("Algo ha salido mal")
            }
            
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func openAddOffer() {
        performSegueWithIdentifier("openAddOffer", sender: nil)
    }
    
    func openSettings() {
        performSegueWithIdentifier("openSettings", sender: nil)
    }
    
    func openHelp() {
        performSegueWithIdentifier("openHelp", sender: nil)
    }
    
    func deleteUser() {
        
        let alertController = UIAlertController(title: "¡Atención!", message:
            "Está a punto de eliminar su cuenta, ¿seguro que desea continuar?", preferredStyle: UIAlertControllerStyle.Alert)
        //Llamo a finalizar edición para bloquear todos los campos
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in Alamofire.request(.DELETE, self.url + userData.userID) .responseJSON { response in}; self.logout()}))
        //Si cancela no se pierde la edición
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func logout() {
        deleteData()
        exit(0)
    }

    // Buttons
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let myPageViewController = segue.destinationViewController as? MyPageViewController {
            self.myPageViewController = myPageViewController
        }
    }
    
    @IBAction func mapButtonPressed(sender: UIButton) {
        mapTabSelected()
        self.myPageViewController?.scrollToViewController(index: 0)
    }
    
    @IBAction func offersButtonPressed(sender: UIButton) {
        offersTabSelected()
        self.myPageViewController?.scrollToViewController(index: 1)
    }
    
    func menuButtonPressed(){
        scrollView.contentOffset.x == 0  ? closeMenu() : openMenu()
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("menuButtonPressed", object: nil)
    }
    
    // Change Tab color when is selected and hidden or show the buttons
    func mapTabSelected(){
        menuButtonShow()
        refreshButtonShow()
        
        mapButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        mapButton.titleLabel!.textColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)
        offersButton.backgroundColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)
        offersButton.titleLabel!.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func offersTabSelected(){
        refreshButtonHidden()

        offersButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        offersButton.titleLabel!.textColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)
        mapButton.backgroundColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)
        mapButton.titleLabel!.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func deleteData() {
        
        // create an instance of our managedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let user = appDelegate.managedObjectContext
        let coord = appDelegate.persistentStoreCoordinator
        
        let userFetch = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: userFetch)

        do {
            try coord.executeRequest(deleteRequest, withContext: user)
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    // This wrapper function is necessary because
    // closeMenu params do not match up with Notification
    func closeMenuViaNotification(){
        closeMenu()
    }
    
    // Use scrollview content offset-x to slide the menu.
    func closeMenu(animated:Bool = true){
        scrollView.setContentOffset(CGPoint(x: leftMenuWidth, y: 0), animated: animated)
    }
    
    // Open is the natural state of the menu because of how the storyboard is setup.
    func openMenu(){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func menuButtonHidden() {
        menuButton.hidden = true
    }
    
    func menuButtonShow() {
        menuButton.hidden = false
    }
    
    @IBAction func refresh(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("refreshData", object: nil)
    }
    
    func refreshButtonHidden() {
        refreshButton.hidden = true
    }
    
    func refreshButtonShow() {
        refreshButton.hidden = false
    }
    
}

extension MainScreen : UIScrollViewDelegate {
    
    // http://www.4byte.cn/question/49110/uiscrollview-change-contentoffset-when-change-frame.html
    // When paging is enabled on a Scroll View, 
    // a private method _adjustContentOffsetIfNecessary gets called,
    // presumably when present whatever controller is called.
    // The idea is to disable paging.
    // But we rely on paging to snap the slideout menu in place
    // (if you're relying on the built-in pan gesture).
    // So the approach is to keep paging disabled.  
    // But enable it at the last minute during scrollViewWillBeginDragging.
    // And then turn it off once the scroll view stops moving.
    // 
    // Approaches that don't work:
    // 1. automaticallyAdjustsScrollViewInsets -- don't bother
    // 2. overriding _adjustContentOffsetIfNecessary -- messing with private methods is a bad idea
    // 3. disable paging altogether.  works, but at the loss of a feature
    // 4. nest the scrollview inside UIView, so UIKit doesn't mess with it.  may have worked before,
    //    but not anymore.
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.pagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.pagingEnabled = false
    }
}

extension MainScreen: MyPageViewControllerDelegate {
    
    // Change Tab color when is selected with slider movement
    func selectedTab(myPageViewController: MyPageViewController,
        didUpdatePageIndex index: Int){
    
            if index == 0 {
                mapTabSelected()
            } else if index == 1 {
                offersTabSelected()
            }
    }
}