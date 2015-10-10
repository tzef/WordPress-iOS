import Foundation

public class ThemeBrowserViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    // MARK: - Properties: must be set by parent
    
    /**
     *  @brief      The blog this VC will work with.
     *  @details    Must be set by the creator of this VC.
     */
    private var blog : Blog!
    
    // MARK: - Properties: managed object context & services
    
    /**
     *  @brief      The managed object context this VC will use for it's operations.
     */
    private let managedObjectContext : NSManagedObjectContext = {
        ContextManager.sharedInstance()!.newDerivedContext()
    }()
    
    /**
     *  @brief      The FRC this VC will use to display filtered content.
     */
    private lazy var themesController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Theme.entityName())
        fetchRequest.fetchBatchSize = 20
        let predicate = NSPredicate(format: "blog == %@", self.blog)
        fetchRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch let error as NSError {
            DDLogSwift.logError("Error fetching themes: \(error.localizedDescription)")
        }
        
        return frc
    }()
    
    /**
     *  @brief      The themes service we'll use in this VC.
     */
    private lazy var themeService : ThemeService = {
        ThemeService(managedObjectContext: self.managedObjectContext)
    }()
    
    // MARK: - Additional initialization
    
    public func configureWithBlog(blog: Blog) {
        do {
            let blogInContext = try managedObjectContext.existingObjectWithID(blog.objectID) as? Blog
            self.blog = blogInContext
        } catch let error as NSError {
            DDLogSwift.logError("Error finding blog: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Themes", comment: "Title of Themes browser page")
        
        WPStyleGuide.configureColorsForView(view, collectionView:collectionView)
        
        updateThemes()
    }

    public override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @available(iOS 8.0, *)
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Updating the list of themes
    
    private func updateThemes() {
        
        if collectionView(collectionView!, numberOfItemsInSection: 0) == 0 {
            let title = NSLocalizedString("Fetching Themes...", comment:"Text displayed while fetching themes")
            WPNoResultsView.displayAnimatedBoxWithTitle(title, message: nil, view: self.view)
        }

        themeService.getThemesForBlog(
            blog,
            success: { [weak self] (themes : [AnyObject]?) -> Void in
                WPNoResultsView.removeFromView(self?.view)
            },
            failure: {(error : NSError!) -> Void in
                DDLogSwift.logError("Error updating themes: \(error.localizedDescription)")
            })
    }
    
    // MARK: - UICollectionViewController protocol UICollectionViewDataSource
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = themesController.fetchedObjects?.count
        return count ?? 0
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> ThemeBrowserCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ThemeBrowserCell", forIndexPath: indexPath) as! ThemeBrowserCell
        let theme = themesController.objectAtIndexPath(indexPath) as? Theme
        
        cell.theme = theme
        
        return cell
    }
    
    public override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ThemeBrowserHeaderView", forIndexPath: indexPath)
        return header
    }
    
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: - UICollectionViewController protocol UICollectionViewDelegate

    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let theme = themesController.objectAtIndexPath(indexPath) as? Theme {
            showDemoForTheme(theme)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        let width = cellWidthForFrameWidth(parentViewWidth)
        
        return CGSize(width: width, height: ThemeBrowserCell.heightForWidth(width))
    }
    
    // MARK: - Layout calculation helper methods
    
    /**
     *  @brief      Calculates the cell width for parent frame
     *
     *  @param      parentViewWidth     The width of the parent view.
     *
     *  @returns    The requested cell width.
     */
    private func cellWidthForFrameWidth(parentViewWidth : CGFloat) -> CGFloat {
        let numberOfColumns = max(1, trunc(parentViewWidth / WPStyleGuide.Themes.minimumColumnWidth))
        let numberOfMargins = numberOfColumns + 1
        let marginsWidth = numberOfMargins * WPStyleGuide.Themes.columnMargin
        let columnsWidth = parentViewWidth - marginsWidth
        let columnWidth = trunc(columnsWidth / numberOfColumns)
        
        return columnWidth
    }
    
    // MARK: - UISearchBarDelegate
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // SEARCH AWAY!!!
    }
    
    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dispatch_async(dispatch_get_main_queue(), {
            collectionView?.reloadData()
        })
    }
    
    // MARK: - Theme actions
    
    private func showDemoForTheme(theme: Theme) {
        
        let url = NSURL(string: theme.demoUrl)
        let webViewController = WPWebViewController(URL: url)
        
        webViewController.authToken = blog.authToken
        webViewController.username = blog.usernameForSite
        webViewController.password = blog.password
        webViewController.wpLoginURL = NSURL(string: blog.loginUrl())
        
        let navController = UINavigationController(rootViewController: webViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
}
