//
//  ImageEditorViewController.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import UIKit
import PresentationLayer

protocol ImageEditorViewControllerDelegate {
    func didRequestFilterButtons(from imageData: Data)
    func didRequestFilter(_ number: Int, on imageData: Data)
    func didSetForAdjustment(_ imageData: Data)
    func didAdjustImageSetting(_ number: Int, to newValue: Float)
    func didRequestSave(_ imageData: Data, fromOriginalURL url: URL)
}

public final class ImageEditorViewController: UIViewController, ImageEditorCanvasView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageScrollContainer: UIView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filtersScrollView: UIScrollView!
    @IBOutlet weak var settingsScrollView: UIScrollView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var filterTabButton: UIButton!
    @IBOutlet weak var editTabButton: UIButton!
    @IBOutlet weak var tabButtons: UIStackView!
    @IBOutlet weak var editorButtons: UIStackView!
    
    private var alert: UIAlertController!
    
    var delegate: ImageEditorViewControllerDelegate?
    var imageData: Data!
    var url: URL!
    
    private var filteredImageData: Data!
    private var modifiedImageData: Data!
    private var buttonImagesData = [Data]()
    private var selectedSetting = 0
    private var isEditingText = false
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Editor"
        setupInitialView()
    }
    
    private func setupInitialView() {
        setImage()
        setupTextView()
        
        setupFilterButtons()
        filtersScrollView.isHidden = true
        
        setupSettingsButtons()
        settingsScrollView.isHidden = true
        setupSaveAlert()
        
        textField.isHidden = true
        sliderView.isHidden = true
        tabButtons.isHidden = false
        filterTabButton.isSelected = false
        editTabButton.isSelected = false
        editorButtons.isHidden = true
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
    }
    
    public func display(_ viewModel: ImageEditorCanvasViewVM) {
        imageView.image = UIImage(data: viewModel.filteredImageData)
        filteredImageData = viewModel.filteredImageData
    }
    
    public func displayAdjustment(_ viewModel: ImageEditorCanvasViewVM) {
        imageView.image = UIImage(data: viewModel.filteredImageData)
        modifiedImageData = viewModel.filteredImageData
    }
    
    @IBAction func editTabButtonTapped(_ sender: UIButton) {
        self.filtersScrollView.isHidden = true
        self.filterTabButton.isSelected = false
        self.editTabButton.isSelected = true
        UIView.transition(with: settingsScrollView, duration: 0.33, options: [.curveEaseIn, .transitionCrossDissolve]) {
            self.settingsScrollView.isHidden = false
        }
    }
    
    @IBAction func filterTabButtonTapped(_ sender: UIButton) {
        self.filterTabButton.isSelected = true
        self.editTabButton.isSelected = false
        self.settingsScrollView.isHidden = true
        UIView.transition(with: filtersScrollView, duration: 0.33, options: [.curveEaseIn, .transitionCrossDissolve]) {
            self.filtersScrollView.isHidden = false
        }
    }
    
    private func setupSaveAlert() {
        alert = UIAlertController(title: "Saving Result", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
}

// MARK: - Saving Image

extension ImageEditorViewController: ImageSaveProgressView {
    
    @objc func saveTapped(_ sender: UIBarButtonItem) {
        let renderer = UIGraphicsImageRenderer(size: imageScrollContainer.bounds.size)
        let image = renderer.image { ctx in
            imageScrollContainer.drawHierarchy(in: imageScrollContainer.bounds, afterScreenUpdates: true)
        }
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            fatalError("Failed to render image data from view")
        }
        delegate?.didRequestSave(imageData, fromOriginalURL: url)
    }
    
    public func displayResult(_ viewModel: ImageSaveProgressViewVM) {
        switch viewModel.result {
        case .success:
            alert.message = "Completed Successfully"
        case let .failure(error):
            alert.message = "Failed with error: \(error)"
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Text Editing
extension ImageEditorViewController: UITextFieldDelegate  {
    
    func setupTextView() {
        textField.delegate = self
        let font =  UIFont(name: fonts()[0], size: 45)!
        textField.font = UIFontMetrics.default.scaledFont(for: font)
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        addButton(to: stackView, with: fonts()[0], at: 0, x: 0, y: 0, width: 10, height: 44)
        addButton(to: stackView, with: fonts()[1], at: 1, x: 10, y: 0, width: 10, height: 44)
        addButton(to: stackView, with: fonts()[2], at: 2, x: 20, y: 0, width: 10, height: 44)
        addButton(to: stackView, with: fonts()[3], at: 3, x: 30, y: 0, width: 10, height: 44)
        textField.inputAccessoryView = stackView
    }
    
    private func fonts() -> [String] {
        return ["Shizuru-Regular", "IndieFlower", "Lobster-Regular", "Pacifico-Regular"]
    }
    
    private func addButton(to view: UIStackView, with font: String, at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.backgroundColor = .darkGray.withAlphaComponent(0.7)
        button.setTitle("Aa", for: .normal)
        let uiFont = UIFont(name: font, size: UIFont.labelFontSize)!
        button.titleLabel?.font = UIFontMetrics.default.scaledFont(for: uiFont)
        button.tag = position
        button.clipsToBounds = true
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        button.addTarget(self, action: #selector(changeFont), for: .touchUpInside)
        view.addArrangedSubview(button)
    }
    
    @objc func changeFont(sender: UIButton) {
        let font =  UIFont(name: fonts()[sender.tag], size: 45)!
        textField.font =  UIFontMetrics.default.scaledFont(for: font)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        isEditingText = !isEditingText
        if isEditingText {
            textField.sizeToFit()
            textField.isHidden = false
            textField.becomeFirstResponder()
        } else {
            if textField.text == "" {
                textField.isHidden = true
            }
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func textFieldDragged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        textField.center.x += translation.x
        textField.center.y += translation.y
        sender.setTranslation(CGPoint.zero, in: sender.view)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


// MARK: - Setting Adjustment

extension ImageEditorViewController  {

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        delegate?.didAdjustImageSetting(selectedSetting, to: sender.value)
    }
    
    @objc func showSlider(sender: UIButton) {
        delegate?.didSetForAdjustment(modifiedImageData!)
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = nil
        setTitleForSetting(sender.tag)
        selectedSetting = sender.tag
        filtersScrollView.isHidden = true
        settingsScrollView.isHidden = true
        sliderView.isHidden = false
        
        tabButtons.isHidden = true
        editorButtons.isHidden = false
    }
    
    private func setTitleForSetting(_ settingNumber: Int) {
        switch settingNumber {
        case 1:
            title = "Brightness"
        case 2:
            title = "Hue"
        case 3:
            title = "Contrast"
        case 4:
            title = "Saturation"
        case 5:
            title = "Exposure"
        default:
            title = "Vibrance"
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        sliderView.isHidden = true
        slider.value = 0
        editorButtons.isHidden = true
        tabButtons.isHidden = false
        filterTabButton.isSelected = false
        editTabButton.isSelected = true
        settingsScrollView.isHidden = false
        navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))

        title = "Editor"
        
        imageView.image = UIImage(data: filteredImageData)
        modifiedImageData = filteredImageData
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        sliderView.isHidden = true
        slider.value = 0
        editorButtons.isHidden = true
        tabButtons.isHidden = false
        filterTabButton.isSelected = false
        editTabButton.isSelected = true
        settingsScrollView.isHidden = false
        navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        title = "Editor"
        
        filteredImageData = modifiedImageData
        imageView.image = UIImage(data: filteredImageData)
    }
    
}


// MARK: - Settings Buttons

extension ImageEditorViewController {
    
    private func setupSettingsButtons() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 0
        let width: CGFloat = settingsScrollView.bounds.height
        let height: CGFloat = width / 1.5
        let gap: CGFloat = 5
        
        setupBrightnessButton(at: 1, x: xCoord, y: yCoord, width: width, height: height)
        moveCoordinateX()
        
        setupHueButton(at: 2, x: xCoord, y: yCoord, width: width, height: height)
        moveCoordinateX()
        
        setupContrastButton(at: 3, x: xCoord, y: yCoord, width: width, height: height)
        moveCoordinateX()
        
        setupSaturationButton(at: 4, x: xCoord, y: yCoord, width: width, height: height)
        moveCoordinateX()
        
        setupExposureButton(at: 5, x: xCoord, y: yCoord, width: width, height: height)
        moveCoordinateX()
        
        setupVibranceButton(at: 6, x: xCoord, y: yCoord, width: width, height: height)
        moveCoordinateX()
        
        let buttonsCount = CGFloat(6)
        settingsScrollView.contentSize = CGSize(width: width * buttonsCount + (buttonsCount + 1) * gap, height: height)
        view.setNeedsDisplay()
        settingsScrollView.setNeedsDisplay()
        settingsScrollView.layoutSubviews()
        
        func moveCoordinateX() {
            xCoord += width + gap
        }
    }
    
    // MARK: - Button Setups
    
    private func setupBrightnessButton(at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let image = UIImage(named: "brightness.png")!.withRenderingMode(.alwaysTemplate)
        addStack(with: image, for: "Brightness", at: position, x: x, y: y, width: width, height: height)
    }
    
    private func setupSaturationButton(at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let image = UIImage(named: "saturation.png")!.withRenderingMode(.alwaysTemplate)
        addStack(with: image, for: "Saturation", at: position, x: x, y: y, width: width, height: height)
    }
    
    
    private func setupContrastButton(at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let image = UIImage(named: "contrast.png")!.withRenderingMode(.alwaysTemplate)
        addStack(with: image, for: "Contrast", at: position, x: x, y: y, width: width, height: height)
    }
    
    private func setupHueButton(at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let image = UIImage(named: "hue.png")!.withRenderingMode(.alwaysTemplate)
        addStack(with: image, for: "Hue", at: position, x: x, y: y, width: width, height: height)
    }
    
    private func setupExposureButton(at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let image = UIImage(named: "exposure.png")!.withRenderingMode(.alwaysTemplate)
        addStack(with: image, for: "Exposure", at: position, x: x, y: y, width: width, height: height)
    }
    
    private func setupVibranceButton(at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let image = UIImage(named: "vibrance.png")!.withRenderingMode(.alwaysTemplate)
        addStack(with: image, for: "Vibrance", at: position, x: x, y: y, width: width, height: height)
    }
    
    private func addStack(with image: UIImage, for text: String, at position: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let stack = createButtonStack(x: x, y: y, width: width, height: height)
        addButton(to: stack, at: position, with: image, x: x, y: y, width: width, height: height - height / 10)
        addLabel(to: stack, with: text, x: x, y: y, width: width, height: height / 10)
        settingsScrollView.addSubview(stack)
    }
    
    // MARK: - Helpers
    
    private func createButtonStack(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIStackView {
        let stackView = UIStackView(frame: CGRect(x: x, y: y, width: width, height: height))
        stackView.spacing = 0
        stackView.axis = .vertical
        return stackView
    }
    
    private func addLabel(to view: UIStackView, with text: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        label.text = text
        label.textAlignment = .center
        view.addArrangedSubview(label)
        
    }
    private func addButton(to view: UIStackView, at position: Int, with image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let button = UIButton(type: .custom)
        button.imageView!.contentMode = UIView.ContentMode.scaleAspectFill
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.clipsToBounds = true
        button.tag = position
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        button.addTarget(self, action: #selector(showSlider), for: .touchUpInside)
        view.addArrangedSubview(button)
    }
}

// MARK: - Filter Buttons

extension ImageEditorViewController: ImageEditorButtonsView {

    private func setupFilterButtons() {
        guard let data = imageData else {
            fatalError("ImageEditor created with no image data.")
        }
        delegate?.didRequestFilterButtons(from: data)
    }
    
    public func display(_ viewModel: ImageEditorButtonsViewVM) {
        buttonImagesData = viewModel.buttonImagesData
        createFilterButtons(for: buttonImagesData)
    }
    
    private func createFilterButtons(for buttonImagesData: [Data]) {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 0
        let buttonWidth: CGFloat = filtersScrollView.bounds.height
        let buttonHeight: CGFloat = buttonWidth
        let gapBetweenButtons: CGFloat = 5
        
        for (indx, buttonImageData) in buttonImagesData.enumerated() {
            let filterButton = UIButton(type: .custom)
            filterButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFill
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = indx
            filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
            filterButton.clipsToBounds = true
            
            let buttonImage = UIImage(data: buttonImageData)
            filterButton.setImage(buttonImage, for: .normal)
            xCoord +=  buttonWidth + gapBetweenButtons
            self.filtersScrollView.addSubview(filterButton)
        }
        
        let filterCount = CGFloat(buttonImagesData.count)
        filtersScrollView.contentSize = CGSize(width: buttonWidth * filterCount + (filterCount + 1) * gapBetweenButtons, height: buttonHeight)
        view.setNeedsDisplay()
        scrollView.setNeedsDisplay()
        scrollView.layoutSubviews()
    }
    
    @objc private func filterButtonTapped(sender: UIButton) {
        guard let data = imageData else {
            fatalError("ImageEditor created with no image data.")
        }
        delegate?.didRequestFilter(sender.tag, on: data)
    }
}

// MARK: - Scroll View Delegate (Main Image View)

extension ImageEditorViewController: UIScrollViewDelegate {
    
    private func setImage() {
        modifiedImageData = imageData
        filteredImageData = imageData
        
        if let imgData = imageData {
            imageView.image = UIImage(data: imgData)
        }
        
        
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true

        imageView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor).isActive = true

        imageView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor).isActive = true
        //        updateMinZoomScaleForSize(scrollView.bounds.size)
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        updateConstraintsForSize(scrollView.bounds.size)
        updateConstraints()
    }
//
//    func updateConstraintsForSize(_ size: CGSize) {
//        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
//        imageViewTopConstraint.constant = yOffset
//        imageViewBottomConstraint.constant = yOffset
//
//        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
//        imageViewLeadingConstraint.constant = xOffset
//        imageViewTrailingConstraint.constant = xOffset
//
//        view.layoutIfNeeded()
//    }
//
    func updateConstraints() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
}
