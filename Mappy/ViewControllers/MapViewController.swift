//
//  MapViewController.swift
//  Mappy
//
//  Created by Тim Akhm on 27.06.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private lazy var addressButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "adressButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(adressButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addShadowOnView()
        return button
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "refreshButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addShadowOnView()
        button.isHidden = true
        return button
    }()
    
    private lazy var routeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "routeButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addShadowOnView()
        button.isHidden = true
        return button
    }()
    
    private var pointAnnotationArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setDelegates()
        setConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .none
        
        view.addSubview(mapView)
        mapView.addSubview(addressButton)
        mapView.addSubview(refreshButton)
        mapView.addSubview(routeButton)
    }
    
    private func setDelegates() {
        mapView.delegate = self
    }
    
    @objc private func adressButtonTapped() {
        presentSearchAlertConroller(withTitle: "Пожалуйста, введите адрес",
                                    message: nil,
                                    style: .alert) { [self] address in
            setupPlaceMark(address: address)
        }
    }
    
    @objc private func refreshButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        refreshButton.isHidden = true
        routeButton.isHidden = true
        }
    
    @objc private func routeButtonTapped() {
        for index in 0...pointAnnotationArray.count - 2 {
            createDirectionRequest(startCoordinate: pointAnnotationArray[index].coordinate, finishCoordinate: pointAnnotationArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(pointAnnotationArray, animated: true)
    }
    
    private func setupPlaceMark(address: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemark, error in
            if let error = error {
                print(error)
                self.alert(title: "Ошибка", message: "Сервер не доступен. Попробуйте снова."){
                    self.dismiss(animated: true)
                }
                return
            }
            
            guard let placemarks = placemark else { return }
            let placemark = placemarks.first
            let annotanion = MKPointAnnotation()
            annotanion.title = "\(address)"
            
            guard let placemarkLocation = placemark?.location else { return }
            annotanion.coordinate = placemarkLocation.coordinate
            
            self.pointAnnotationArray.append(annotanion)
            
            if self.pointAnnotationArray.count != 0 {
                self.refreshButton.isHidden = false
            }
            
            if self.pointAnnotationArray.count > 1 {
                self.routeButton.isHidden = false
            }
            
            self.mapView.showAnnotations(self.pointAnnotationArray, animated: true)
        }
    }
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, finishCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let finishLocation = MKPlacemark(coordinate: finishCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: finishLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }
            guard let responce = responce else {
                self.alert(title: "Ошибка", message: "Сервер не доступен. Попробуйте снова."){
                    self.dismiss(animated: true)
                }
                return
            }
            
            var minRoute = responce.routes[0]
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}
extension MapViewController: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0.9987913966, green: 0.2939536273, blue: 0.3107184768, alpha: 1)
        return renderer
    }
}

//MARK: - Set constrains
extension MapViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            addressButton.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            addressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -15),
            addressButton.heightAnchor.constraint(equalToConstant: 50),
            addressButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            refreshButton.centerXAnchor.constraint(equalTo: addressButton.centerXAnchor),
            refreshButton.topAnchor.constraint(equalTo: addressButton.bottomAnchor, constant: 40),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            refreshButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            routeButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -40),
            routeButton.heightAnchor.constraint(equalToConstant: 80),
            routeButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}
