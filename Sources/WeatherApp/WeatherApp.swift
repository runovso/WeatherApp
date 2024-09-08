//
//  WeatherApp.swift
//  
//
//  Created by Sergei Runov on 07.09.2024.
//

import UIKit
import CoreLocation

public final class WeatherApp: UIViewController {
    
    // MARK: - Public properties
    
    public let weatherService: WeatherServiceProtocol
    public let imageService: ImageServiceProtocol
    public let appName = "Weather"
    public let appIconName = "thermometer.sun"
    public var viewMode: String {
        didSet {
            mode = ViewMode(rawValue: viewMode)
        }
    }
    
    // MARK: - Subviews
    
    private let locationLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let weatherIconImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let temperatureDetailsLabel = UILabel()
    // TODO: Progress view
    
    // MARK: - Propertes
    
    private let locationManager: LocationManagerProtocol
    private var weatherIconName: String? {
        didSet {
            if oldValue != weatherIconName {
                getWeatherImage()
            }
        }
    }
    private var mode: ViewMode? {
        didSet {
            setupLayout()
            setupInteractionMode()
        }
    }
    
    // MARK: - View Modes
    
    enum ViewMode: String {
        case compact, halfscreen, fullscreen
    }
    
    // MARK: - Lifecycle

    public init(viewMode: String = "compact",
                weatherApiUrl: String, 
                weatherApiKey: String,
                imageApiUrl: String) {
        self.viewMode = viewMode
        self.mode = ViewMode(rawValue: viewMode)
        let weatherService = WeatherService(apiUrl: weatherApiUrl, apiKey: weatherApiKey)
        self.weatherService = weatherService
        let imageService = ImageService(apiUrl: imageApiUrl)
        self.imageService = imageService
        self.locationManager = LocationManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupInteraction()
        setupHierarchy()
        setupAppearance()
        setupLayout()
    }
    
    // MARK: - Private methods
        
    private func showAlert(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }
        rootVC.present(alert, animated: true, completion: nil)
    }
}

// MARK: - AppProtocol methods

public extension WeatherApp {
    
    func setupInteractionMode() {
        guard let mode else { return }
        switch mode {
        case .compact:
            view.subviews.forEach {
                $0.isUserInteractionEnabled = false
            }
        case .halfscreen, .fullscreen:
            view.subviews.forEach {
                $0.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - LocationManagerDelegate Methods

extension WeatherApp: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        getWeather(for: location)
    }
}

// MARK: - Private network methods

private extension WeatherApp {
    
    private func getWeather(for location: CLLocation) {
        weatherService.getWeather(latitude: location.coordinate.latitude,
                                  longitude: location.coordinate.longitude) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let data):
                    updateLabels(with: data)
                case .failure(let error):
                    showAlert(error)
                }
            }
        }
    }
    
    private func getWeatherImage() {
        guard let weatherIconName else { return }
        imageService.getData(forImage: weatherIconName) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let data):
                    updateIcon(with: data)
                case .failure(let error):
                    showAlert(error)
                }
            }
        }
    }
}

// MARK: - Private setup methods

private extension WeatherApp {
    
    func setupInteraction() {
        locationManager.delegate = self
        locationManager.requestAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupHierarchy() {
        [locationLabel, weatherDescriptionLabel, weatherIconImageView, temperatureLabel, temperatureDetailsLabel].forEach {
            view.addSubview($0)
        }
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
        view.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        locationLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        locationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        weatherDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        weatherIconImageView.contentMode = .scaleAspectFit
        
        temperatureLabel.font = .systemFont(ofSize: 21, weight: .light)
        temperatureLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        temperatureDetailsLabel.font = .systemFont(ofSize: 13, weight: .regular)
    }
    
    func setupLayout() {
        [locationLabel, weatherDescriptionLabel, weatherIconImageView, temperatureLabel, temperatureDetailsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [compactConstraints, halfscreenConstraints].forEach {
            NSLayoutConstraint.deactivate($0)
        }
        
        guard let mode else { return }
        switch mode {
        case .compact, .halfscreen:
            NSLayoutConstraint.activate(compactConstraints)
        case .fullscreen:
            NSLayoutConstraint.activate(halfscreenConstraints)
        }
    }
    
    func updateLabels(with weatherInfo: WeatherAPIResponseDTO) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            locationLabel.text = weatherInfo.place
            temperatureLabel.text = "\(weatherInfo.data.temp)°C"
            temperatureDetailsLabel.text = "H: \(Int(weatherInfo.data.tempMax.rounded()))°C, L: \(Int(weatherInfo.data.tempMin.rounded()))°C"
            guard let weather = weatherInfo.weather.first else { return }
            weatherDescriptionLabel.text = weather.description.capitalized
            weatherIconName = weather.icon
        }
    }
    
    func updateIcon(with imageData: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            weatherIconImageView.image = UIImage(data: imageData)
        }
    }
}

// MARK: - Constraints

private extension WeatherApp {
    
    var compactConstraints: [NSLayoutConstraint] { 
        let margins = view.layoutMarginsGuide
        return [
            locationLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor, constant: -8),
            locationLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            
            weatherDescriptionLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            weatherDescriptionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            
            weatherIconImageView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            weatherIconImageView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            weatherIconImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            weatherIconImageView.widthAnchor.constraint(equalTo: margins.widthAnchor),
            
            temperatureLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            temperatureDetailsLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            temperatureDetailsLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
    }
    
    var halfscreenConstraints: [NSLayoutConstraint] {
        let margins = view.layoutMarginsGuide
        return [
            locationLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 64),
            locationLabel.trailingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor, constant: -8),
            locationLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 64),
            
            weatherDescriptionLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 64),
            weatherDescriptionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -64),
            
            weatherIconImageView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            weatherIconImageView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            weatherIconImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            weatherIconImageView.widthAnchor.constraint(equalTo: margins.widthAnchor),
            
            temperatureLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 64),
            temperatureLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -64),
            
            temperatureDetailsLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -64),
            temperatureDetailsLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -64)
        ]
    }
}
