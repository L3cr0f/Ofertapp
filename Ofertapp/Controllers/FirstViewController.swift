//
//  FirstViewController.swift
//  delete
//
//  Created by Ernesto Fdez on 12/3/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 400
    
    var offerModel = [OffersModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cargo las ofertas de la base de datos
        offerModel = MainScreen.offersData.offerModel
        
        checkLocationAuthorizationStatus()
        
        //Si la deteccion de la localizacion esta activada muestra tu ubicacion y se actualizan periodicamente,
        //si no va por defecto a una localizacion por defecto, en nuestro caso la catedral de Leon
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            while locationManager.location == nil {
                sleep(1)
            }
            centerMapOnLocation(locationManager.location!)
        } else {
            let initialLocation = CLLocation(latitude: 42.5995, longitude: -5.5667)
            centerMapOnLocation(initialLocation)
        }
        
        // MainScreen sends refreshData
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: "refreshData", object: nil)
        
        //Muestra las diferentes ofertas en el mapa
        showOffers()
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //centerMapOnLocation(locationManager.location!)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Actualizamos la información presente en el mapa
    func refreshData() {
        offerModel = OffersModel.loadOffers()
        MainScreen.offersData.offerModel = offerModel
        removeAnnotations()
        showOffers()
    }
    
    func removeAnnotations() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
    //Puntos en el mapa
    func showOffers() {
        
        //Array de puntos en el mapa
        var points = [MKPointAnnotation]()
        
        for offer in offerModel {
            let annotation = MKPointAnnotation()
            
            //Si el valor de la localización no es vacio entra
            if !offer.location.isEmpty {
                //Obtengo la longitud y la latitud de la base de datos
                let locationString = offer.location.characters.split{$0 == "/"}.map(String.init)
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationString[0])!, longitude: CLLocationDegrees(locationString[1])!)
                
                annotation.title = offer.name
                annotation.subtitle = offer.description
            
                points.append(annotation)
            }
        }
        
        mapView.addAnnotations(points)
    }
}

