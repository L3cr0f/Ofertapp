//
//  ShowOffer.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 30/4/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Alamofire

class ShowOffer : UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var offer : OffersModel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var user : String = ""
    var admin : Bool = false
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 400
    
    var pointer = MKPointAnnotation()
    var longPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    var locationSelected: Bool = false
    
    let categories = ["Alimentación", "Cuidado Personal", "Deporte", "Energía", "Hogar", "Moda y Complementos", "Ocio", "Tecnología"]
    var selectedCategory : String = "Alimentación"
    
    //Cargar imagen
    var imagePicker = UIImagePickerController()
    var imageView = UIImageView()
    
    let url: String = "https://offers-ofertapp.herokuapp.com/todo/"
    
    var editMode : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Cargar los pickers
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        //Iniciamos los pickers
        initCategoryPicker()
        
        //Cargamos los valores de la oferta seleccionada
        nameTextField.text = offer.name
        descriptionTextView.text = offer.description
        startDate.date = stringToDate(offer.startDate)
        endDate.date = stringToDate(offer.endDate)
        
        var initialLocation: CLLocation
        
        checkLocationAuthorizationStatus()
        
        //Si la deteccion de la localizacion esta activada muestra tu ubicacion y se actualizan periodicamente,
        //si no va por defecto a una localizacion por defecto, en nuestro caso la catedral de Leon
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if !offer.location.isEmpty {
            //Obtengo la longitud y la latitud de la base de datos
            let locationString = offer.location.characters.split{$0 == "/"}.map(String.init)
            initialLocation = CLLocation(latitude: CLLocationDegrees(locationString[0])!, longitude: CLLocationDegrees(locationString[1])!)

            //Obtengo la longitud y la latitud de la base de datos
            pointer.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationString[0])!, longitude: CLLocationDegrees(locationString[1])!)
            
            pointer.title = offer.name
            pointer.subtitle = offer.description
            mapView.addAnnotation(pointer)
            locationSelected = true
        } else {
            initialLocation = CLLocation(latitude: 42.5995, longitude: -5.5667)
            locationSelected = false
        }
        
        centerMapOnLocation(initialLocation)
    
        self.user = MainScreen.userData.userNickname
        self.admin = MainScreen.userData.userAdmin

        if user == offer.user || self.admin {
            self.navigationItem.rightBarButtonItem = self.editButton
            self.navigationItem.rightBarButtonItem = self.removeButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        NSNotificationCenter.defaultCenter().postNotificationName("menuButtonHidden", object: nil)
    }
    
    //Inicializamos el selector de categoria
    func initCategoryPicker() {
        var counter : Int = 0
        
        while categories[counter] != offer.category {
            counter = counter + 1
        }

        categoryPicker.selectRow(counter, inComponent: 0, animated: false)
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
        longPress = UILongPressGestureRecognizer(target: self, action: "pointer:")
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
    
    func stringToDate(string: String) -> NSDate {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let date: NSDate = dateFormater.dateFromString(string)!
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
    
    @IBAction func editarButtonClick(sender: UIBarButtonItem) {
        self.nameTextField.userInteractionEnabled = true
        self.categoryPicker.userInteractionEnabled = true
        self.descriptionTextView.userInteractionEnabled = true
        self.startDate.userInteractionEnabled = true
        self.endDate.userInteractionEnabled = true
        self.mapView.userInteractionEnabled = true
        self.mapView.scrollEnabled = true
        //Seleccion de una ubicacion
        addLocation()
        
        self.acceptButton.hidden = false
        self.cancelButton.hidden = false
        
        editMode = true
    }
    
    func endEdition() {
        self.nameTextField.userInteractionEnabled = false
        self.categoryPicker.userInteractionEnabled = false
        self.descriptionTextView.userInteractionEnabled = false
        self.startDate.userInteractionEnabled = false
        self.endDate.userInteractionEnabled = false
        self.mapView.userInteractionEnabled = false
        self.mapView.scrollEnabled = false
        self.mapView.removeGestureRecognizer(longPress)
        
        self.acceptButton.hidden = true
        self.cancelButton.hidden = true
        
        editMode = false
        
        viewDidLoad()
    }
    
    @IBAction func removeOffer(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "¡Atención!", message:
            "Está a punto de eliminar esta oferta, ¿seguro que desea continuar?", preferredStyle: UIAlertControllerStyle.Alert)
        //Llamo a eliminar oferta
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in Alamofire.request(.DELETE, self.url + self.offer.id) .responseJSON { response in};             self.navigationController!.popViewControllerAnimated(true)}))
        //Si cancela no se elimina la oferta
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func accept(sender: UIButton) {
        
        var createOffer = true
        
        if nameTextField.text!.isEmpty || descriptionTextView.text!.isEmpty || !checkEndDateIsCorrect() || !checkEndDateIsCorrect() {
            createOffer = false
        }
        
        //Si los datos son validos crear la oferta, sino lanzar una alarma
        if createOffer {
            //Guardar la informacion en la base de datos
            
            let parameters : [String: AnyObject] = [
                "Name" : nameTextField.text!,
                "Category" : selectedCategory,
                "Description" : descriptionTextView.text,
                "StartDate" : dateToString(startDate),
                "EndDate" : dateToString(endDate),
                "Location" : locationToString(pointer),
                "__v" : offer.version
            ]
            
            Alamofire.request(.PUT, url + self.offer.id, parameters: parameters) .responseJSON { response in
            }
            
            //Llamo a finalizar edición para bloquear todos los campos
            endEdition()
            
            self.navigationController!.popViewControllerAnimated(true)
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
                "Todos los cambios se perderán, ¿seguro que desea continuar?", preferredStyle: UIAlertControllerStyle.Alert)
            //Llamo a finalizar edición para bloquear todos los campos
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in self.endEdition()}))
            //Si cancela no se pierde la edición
            alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}
