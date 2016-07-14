//
//  OffersTableViewController.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 2/4/16.
//  Copyright © 2016 AE. All rights reserved.
//
import UIKit
import CoreLocation

class OffersTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var offerModel = [OffersModel]()
    var userModel = UserModel!()
    var filteredOffers = [OffersModel]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchBarIsEnabled = false
    var menuButtonHidden = false
    
    var locationManager = CLLocationManager()
    var locationEnabled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationAuthorizationStatus()
        
        //Si la deteccion de la localizacion esta activada comprobamos si las oferta esta lejos,
        //si no mostramos todas las ofertas estén lejos o no
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            while locationManager.location == nil {
                sleep(1)
            }
            
            locationEnabled = true
        } else {
            locationEnabled = false
        }
        
        self.offerModel = MainScreen.offersData.offerModel
        self.removePastOffers()
        if locationEnabled {
            self.removeFarOffers()
        }
        self.sortOffers()
        
        // Setup the Search Controller
        UISearchBar.appearance().barTintColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)
        UISearchBar.appearance().tintColor = UIColor.whiteColor()
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Nombre", "Categoría"]
        self.tableView.tableHeaderView = searchController.searchBar
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
        if menuButtonHidden && !searchBarIsEnabled {
            NSNotificationCenter.defaultCenter().postNotificationName("menuButtonShow", object: nil)
        } else if menuButtonHidden && searchBarIsEnabled {
            NSNotificationCenter.defaultCenter().postNotificationName("menuButtonHidden", object: nil)
        }
    }
    
    //Actualizar ofertas
    func refresh(sender:AnyObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.offerModel = OffersModel.loadOffers()
            self.removePastOffers()
            if self.locationEnabled {
                self.removeFarOffers()
            }
            self.sortOffers()
            
            if self.refreshControl!.refreshing {
                self.refreshControl!.endRefreshing()
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredOffers.count
        }
        return offerModel.count
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        
        if scope == "Nombre" {
            filteredOffers = offerModel.filter { offer in
                return offer.name.lowercaseString.containsString(searchText.lowercaseString)
            }
        } else if scope == "Categoría" {
            filteredOffers = offerModel.filter { offer in
                return offer.category.lowercaseString.containsString(searchText.lowercaseString)
            }
        } else {
            print("Error: scope not found")
        }
        tableView.reloadData()
    }
    
    func sortOffers() {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        self.offerModel.sortInPlace{dateFormat.dateFromString($0.endDate)!.compare(dateFormat.dateFromString($1.endDate)!) == .OrderedAscending}
    }
    
    func removePastOffers() {

        var counter = 0
        
        for offer in self.offerModel {
            if self.pastOffer(offer.endDate) {
                self.offerModel.removeAtIndex(counter)
            } else {
                counter = counter + 1
            }
        }
    }
    
    func removeFarOffers() {
        
        if locationEnabled {
            
            var counter = 0
            
            for offer in self.offerModel {
                
                if !offer.location.isEmpty {
                    if self.farOffer(offer.location) {
                        self.offerModel.removeAtIndex(counter)
                    } else {
                        counter = counter + 1                        
                    }
                } else {
                    counter = counter + 1
                }
            }
        }
    }
    
    //Nos dice si la fecha de vencimiento de la oferta ya ha pasado
    func pastOffer (endDate: String) -> Bool {
        var pastDate : Bool = false
        
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let date = NSDate()
        let currentDate = dateFormater.stringFromDate(date).characters.split{$0 == "-"}.map(String.init)
        let splittedEndDate = endDate.characters.split{$0 == "-"}.map(String.init)
        
        //Comprobamos que la fecha de finalizacion de promocion sea mayor que la actual
        if Int(splittedEndDate[2]) < Int(currentDate[2]) {
            pastDate = true
        } else if Int(splittedEndDate[2]) == Int(currentDate[2]) {
            if Int(splittedEndDate[1]) < Int(currentDate[1]) {
                pastDate = true
            } else if Int(splittedEndDate[1]) == Int(currentDate[1]) {
                if Int(splittedEndDate[0]) < Int(currentDate[0]) {
                    pastDate = true
                } else {
                    pastDate = false
                }
            } else {
                pastDate = false
            }
        } else {
            pastDate = false
        }
        
        return pastDate
    }
    
    func farOffer (location: String) -> Bool {
        var farOffer : Bool = false
        let offerLocation = location.characters.split{$0 == "/"}.map(String.init)
        let myLocationString = locationToString(locationManager.location!)
        let myLocation = myLocationString.characters.split{$0 == "/"}.map(String.init)
        
        //Coordenadas de los limites
        let latitudeTop = Double(myLocation[0])! + 0.2
        let latitudeBottom = Double(myLocation[0])! - 0.2
        let longitudeRight = Double(myLocation[1])! + 0.2
        let longitudeLeft = Double(myLocation[1])! - 0.2
        
        if Double(offerLocation[0]) < latitudeTop && Double(offerLocation[0]) > latitudeBottom && Double(offerLocation[1]) < longitudeRight && Double(offerLocation[1]) > longitudeLeft {
            farOffer = false
        } else {
            farOffer = true
        }
        
        return farOffer
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationToString (location: CLLocation) -> String {
        let latitud : String = location.coordinate.latitude.description
        let longitud : String = location.coordinate.longitude.description
        
        let location : String = latitud + "/" + longitud
        return location
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OffersTableCell", forIndexPath: indexPath) as! OffersTableCell
        let offer : OffersModel
        
        if searchController.active && searchController.searchBar.text != "" {
            offer = filteredOffers[indexPath.row]
        } else {
            offer = offerModel[indexPath.row]
        }
        
        cell.imageField.image = UIImage(named: "ImageNotAvailable")
        cell.nameLabel.text = offer.name

        cell.categoryLabel.text = offer.category
        cell.fechaInicioLabel.text = offer.startDate
        cell.fechaFinLabel.text = offer.endDate
        
        userModel = UserModel.loadUser(offer.user)
        
        if userModel.enterprise == true {
            cell.validationImage.hidden = false
        } else {
            cell.validationImage.hidden = true
        }
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let selectedCell = sender as? UITableViewCell, selectedRowIndex = tableView.indexPathForCell(selectedCell)?.row
            where segue.identifier == "openShowOfferViewController" else {
                fatalError("sender is not a UITableViewCell or was not found in the tableView, or segue.identifier is incorrect")
        }
        
        let offer = offerModel[selectedRowIndex]
        let detailViewController = segue.destinationViewController as! ShowOffer
        detailViewController.offer = offer
        
        menuButtonHidden = true
    }
}

extension OffersTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBarIsEnabled = true
        menuButtonHidden = true
        NSNotificationCenter.defaultCenter().postNotificationName("menuButtonHidden", object: nil)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBarIsEnabled = false
        menuButtonHidden = false
        NSNotificationCenter.defaultCenter().postNotificationName("menuButtonShow", object: nil)
    }
}

extension OffersTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}