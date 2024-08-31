import UIKit
import FirebaseDatabase

class MainViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var jewelryItems: [Jewelry] = []
    var showOnlyFavorites = false
    private let ref = Database.database().reference().child("jewelry")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")
        view.backgroundColor = .white
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let titleLabel = UILabel()
        titleLabel.text = showOnlyFavorites ? "מועדפים" : "קטלוג תכשיטים"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        navigationItem.titleView = titleLabel
        
        setupCollectionView()
        setupNavigationBar()
        fetchJewelryData()
    }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            print("viewDidAppear called")
                print("Navigation controller exists: \(navigationController != nil)")
                print("Navigation bar is hidden: \(navigationController?.isNavigationBarHidden ?? true)")
                print("Collection view frame: \(collectionView.frame)")
                print("Safe area insets: \(view.safeAreaInsets)")
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    
    private func setupNavigationBar() {
        if showOnlyFavorites {
            title = "מועדפים"
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזרה", style: .plain, target: self, action: #selector(goBack))
        } else {
            title = "קטלוג תכשיטים"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewJewelry))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "מועדפים", style: .plain, target: self, action: #selector(showFavorites))
        }
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupCollectionView() {
        let layout = JewelryCollectionViewLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.backgroundColor = .white
        collectionView.register(JewelryCollectionViewCell.self, forCellWithReuseIdentifier: "JewelryCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func fetchJewelryData() {
        ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var newItems: [Jewelry] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let jewelryDict = snapshot.value as? [String: Any],
                   var jewelry = Jewelry(dict: jewelryDict) {
                    jewelry.id = snapshot.key
                    newItems.append(jewelry)
                }
            }
            
            if self.showOnlyFavorites {
                newItems = newItems.filter { $0.isFavorite }
            }
            
            self.jewelryItems = newItems
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc private func showFavorites() {
        let favoritesVC = MainViewController()
        favoritesVC.showOnlyFavorites = true
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    @objc private func addNewJewelry() {
        let alertController = UIAlertController(title: "הוסף תכשיט חדש", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "שם"
        }
        alertController.addTextField { textField in
            textField.placeholder = "תיאור"
        }
        alertController.addTextField { textField in
            textField.placeholder = "מחיר"
            textField.keyboardType = .decimalPad
        }
        alertController.addTextField { textField in
            textField.placeholder = "URL של תמונה"
        }
        
        let addAction = UIAlertAction(title: "הוסף", style: .default) { [weak self] _ in
            guard let name = alertController.textFields?[0].text,
                  let description = alertController.textFields?[1].text,
                  let priceString = alertController.textFields?[2].text,
                  let price = Double(priceString),
                  let imageURL = alertController.textFields?[3].text else {
                return
            }
            
            let newJewelry = ["id": UUID().uuidString,
                              "name": name,
                              "description": description,
                              "price": price,
                              "imageURL": imageURL,
                              "isFavorite": false] as [String : Any]
            
            self?.ref.childByAutoId().setValue(newJewelry)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jewelryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JewelryCell", for: indexPath) as! JewelryCollectionViewCell
        let jewelry = jewelryItems[indexPath.item]
        cell.configure(with: jewelry)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let jewelry = jewelryItems[indexPath.item]
        let detailVC = JewelryDetailViewController(jewelry: jewelry)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let jewelry = jewelryItems[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "מחק", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteJewelry(jewelry)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    private func deleteJewelry(_ jewelry: Jewelry) {
        ref.child(jewelry.id).removeValue()
    }
}
