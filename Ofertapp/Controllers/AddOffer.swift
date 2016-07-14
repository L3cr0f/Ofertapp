//
//  AddOffer.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 23/4/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Alamofire

class AddOffer : UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    
    var user = ""
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 400
    
    var pointer = MKPointAnnotation()
    var locationSelected: Bool = false
    
    let categories = ["Alimentación", "Cuidado Personal", "Deporte", "Energía", "Hogar", "Moda y Complementos", "Ocio", "Tecnología"]
    var selectedCategory : String = "Alimentación"
    
    //Cargar imagen
    var imagePicker = UIImagePickerController()
    var imageView = UIImageView()
    
    let url: String = "https://offers-ofertapp.herokuapp.com/todo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var initialLocation: CLLocation
        
        checkLocationAuthorizationStatus()
                
        //Si la deteccion de la localizacion esta activada muestra tu ubicacion y se actualizan periodicamente,
        //si no va por defecto a una localizacion por defecto, en nuestro caso la catedral de Leon
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            initialLocation = locationManager.location!
        } else {
            initialLocation = CLLocation(latitude: 42.5995, longitude: -5.5667)
        }
        
        centerMapOnLocation(initialLocation)
        
        //Seleccion de una ubicacion
        addLocation()
        
        //Cargar los pickers
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        self.user = MainScreen.userData.userNickname
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addLocation() {
        let longPress = UILongPressGestureRecognizer(target: self, action: "pointer:")
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
    }

    //Crea el puntero de la localización de la oferta
    func pointer(gestureRecognizer:UIGestureRecognizer) {
        
        //Si ya ha seleccionado una ubicacion
        if locationSelected {
            removeLocation()
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        pointer.coordinate = newCoord
        pointer.title = nameTextField.text
        pointer.subtitle = descriptionTextView.text
        mapView.addAnnotation(pointer)
        locationSelected = true
    }
    
    //Elimina la anterior localizacion
    func removeLocation() {
        mapView.removeAnnotation(pointer)
    }
    
    //Transforma el formato de fecha al deseado
    func dateToString(datePicker: UIDatePicker)-> String {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let date: String = dateFormater.stringFromDate(datePicker.date)
        return date
    }
    
    func checkEndDateIsCorrect () -> Bool {
        var isCorrect : Bool = false
        let startDate = dateToString(self.startDate).characters.split{$0 == "-"}.map(String.init)
        let endDate = dateToString(self.endDate).characters.split{$0 == "-"}.map(String.init)
        
        //Comprobamos que la fecha de finalización sea mayor o igual que la de inicio
        if Int(endDate[2]) > Int(startDate[2]) {
            isCorrect = true
        } else if Int(endDate[2]) == Int(startDate[2]) {
            if Int(endDate[1]) > Int(startDate[1]) {
                isCorrect = true
            } else if Int(endDate[1]) == Int(startDate[1]) {
                if Int(endDate[0]) >= Int(startDate[0]) {
                    isCorrect = true
                } else {
                    isCorrect = false
                }
            } else {
                isCorrect = false
            }
        } else {
            isCorrect = false
        }
        
        //Si hasta el momento la fecha es valida, continua con la comprobacion
        if isCorrect {
            let dateFormater = NSDateFormatter()
            dateFormater.dateFormat = "dd-MM-yyyy"
            let date = NSDate()
            let currentDate = dateFormater.stringFromDate(date).characters.split{$0 == "-"}.map(String.init)
            
            //Comprobamos que la fecha de finalizacion de promocion sea mayor o igual que la actual
            if Int(endDate[2]) > Int(currentDate[2]) {
                isCorrect = true
            } else if Int(endDate[2]) == Int(currentDate[2]) {
                if Int(endDate[1]) > Int(currentDate[1]) {
                    isCorrect = true
                } else if Int(endDate[1]) == Int(currentDate[1]) {
                    if Int(endDate[0]) >= Int(currentDate[0]) {
                        isCorrect = true
                    } else {
                        isCorrect = false
                    }
                } else {
                    isCorrect = false
                }
            } else {
                isCorrect = false
            }
        }
        
        return isCorrect
    }
    
    func locationToString (mkPointAnnotation: MKPointAnnotation) -> String {
        let latitud : String = mkPointAnnotation.coordinate.latitude.description
        let longitud : String = mkPointAnnotation.coordinate.longitude.description
        
        let location : String = latitud + "/" + longitud
        return location
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]

    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = categories[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 10.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
            
        return myTitle

    }
    
    @IBAction func clickCameraButton(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        imageView.image = image
        
    }
    
    @IBAction func accept(sender: UIButton) {

        var createOffer = true
        
        if nameTextField.text!.isEmpty || descriptionTextView.text!.isEmpty || !checkEndDateIsCorrect() || !checkEndDateIsCorrect() {
            createOffer = false
        }
        
        //Si los datos son validos crear la oferta, sino lanzar una alarma
        if createOffer {
            //Guardar la informacion en la base de datos
            
            let parameters : [String: String]
            if locationToString(pointer) == "0.0/0.0" {
                parameters = [
                    "Name" : nameTextField.text!,
                    "Category" : selectedCategory,
                    "Description" : descriptionTextView.text!,
                    "StartDate" : dateToString(startDate),
                    "EndDate" : dateToString(endDate),
                    "User" : self.user
                ]
            } else {
                
                parameters = [
                    "Name" : nameTextField!.text!,
                    "Category" : selectedCategory,
                    "Description" : descriptionTextView.text!,
                    "StartDate" : dateToString(startDate),
                    "EndDate" : dateToString(endDate),
                    "Location" : locationToString(pointer),
                    "User" : self.user
                ]
            }
        
            Alamofire.request(.POST, url, parameters: parameters) .responseJSON { response in
            }
            MainScreen.offersData.offerModel = OffersModel.loadOffers()
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Hay campos con errores o que se encuentran incompletos", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
    @IBAction func cancel (sender: UIButton) {
        
        if !nameTextField.text!.isEmpty || !descriptionTextView.text!.isEmpty {
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Tienes campos con información, ¿seguro que desea continuar?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in self.dismissViewControllerAnimated(true, completion: nil)}))
            alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}