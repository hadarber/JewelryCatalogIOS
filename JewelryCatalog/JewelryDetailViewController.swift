import UIKit
import FirebaseDatabase

class JewelryDetailViewController: UIViewController {
    
    private var jewelry: Jewelry
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteButton = UIButton()
    private let deleteButton = UIButton()
    private let purchaseButton = UIButton()
    private let ref = Database.database().reference().child("jewelry")
    
    init(jewelry: Jewelry) {
        self.jewelry = jewelry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
    }
    
    private func setupViews() {
        view.backgroundColor = .white

        [imageView, nameLabel, descriptionLabel, priceLabel, favoriteButton, deleteButton, purchaseButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
                 priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 200),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),

            deleteButton.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 20),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 200),
            deleteButton.heightAnchor.constraint(equalToConstant: 40),

            purchaseButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 20),
            purchaseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            purchaseButton.widthAnchor.constraint(equalToConstant: 200),
            purchaseButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        priceLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        favoriteButton.setTitleColor(.white, for: .normal)
        favoriteButton.backgroundColor = .systemBlue
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)

        deleteButton.setTitle("הסר מהקטלוג", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 20
        deleteButton.addTarget(self, action: #selector(deleteJewelry), for: .touchUpInside)

        purchaseButton.setTitle("רכישת פריט", for: .normal)
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.backgroundColor = .orange
        purchaseButton.layer.cornerRadius = 20
        purchaseButton.addTarget(self, action: #selector(purchaseItem), for: .touchUpInside)
    }
    
    private func updateUI() {
        nameLabel.text = jewelry.name
        descriptionLabel.text = jewelry.description
        
        // Price customization
        let priceText = "$\(jewelry.price)"
        let attributedPrice = NSMutableAttributedString(string: priceText)
        
        attributedPrice.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 24), range: NSRange(location: 0, length: priceText.count))
        attributedPrice.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: 0, length: priceText.count))
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.gray
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        attributedPrice.addAttribute(.shadow, value: shadow, range: NSRange(location: 0, length: priceText.count))
        
        priceLabel.attributedText = attributedPrice
        
        updateFavoriteButton()
        
        if let url = URL(string: jewelry.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        }
    }

    
    private func updateFavoriteButton() {
        let title = jewelry.isFavorite ? "הסר ממועדפים" : "הוסף למועדפים"
        favoriteButton.setTitle(title, for: .normal)
    }
    
    @objc private func toggleFavorite() {
        jewelry.isFavorite.toggle()
        updateFavoriteButton()
        
        ref.child(jewelry.id).updateChildValues(["isFavorite": jewelry.isFavorite])
    }
    
    @objc private func deleteJewelry() {
        let alert = UIAlertController(title: "הסרת פריט", message: "האם אתה בטוח שברצונך להסיר פריט זה מהקטלוג?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "הסר", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.ref.child(self.jewelry.id).removeValue { error, _ in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func purchaseItem() {
        let alert = UIAlertController(title: nil, message: "בחירה מצוינת! התכשיט בדרך אליך :)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
