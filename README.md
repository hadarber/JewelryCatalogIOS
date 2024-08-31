# Jewelry Catalog iOS App

## Overview
Jewelry Catalog is an iOS application that showcases a collection of jewelry items. Users can view, add, and manage jewelry items in the catalog. The application is integrated with Firebase Realtime Database for real-time data synchronization.

## Features
- **View Jewelry Items:** Browse through a list of jewelry items.
- **Add New Jewelry:** Add new items to the catalog with name, description, price, and image URL.
- **Favorite Items:** Mark items as favorites and view only the favorite items.
- **Delete Items:** Remove items from the catalog.
- **Purchase Item:** Simulate the purchase of an item with a confirmation message (note: no actual purchase is processed).

## Screenshots

## Screenshots
## Screenshots

<img src="https://github.com/user-attachments/assets/f6203098-0e4d-4ddb-b361-c91d4fa25d22" alt="Screenshot1" width="300"/>


<img src="https://github.com/user-attachments/assets/9114ec95-6bc3-41fe-ba34-6b46b3da743b" alt="Screenshot2" width="300"/>


<img src="https://github.com/user-attachments/assets/f8f75a54-fd2b-47e3-93bc-566403390731" alt="Screenshot3" width="300"/>


<img src="https://github.com/user-attachments/assets/d558a721-58c7-4eb4-a8bf-47729757de11" alt="Screenshot4" width="300"/>


<img src="https://github.com/user-attachments/assets/20731d3f-20ae-4a37-99b7-3d0fd80d9955" alt="Screenshot5" width="300"/>


<img src="https://github.com/user-attachments/assets/265181e9-863d-45d6-a19a-7a6d685a2f98" alt="Screenshot6" width="300"/>


<img src="https://github.com/user-attachments/assets/e5537bd3-13ff-48c2-9d4c-35cd0d449d05" alt="Screenshot7" width="300"/>


## Video
[Watch the demo video](path/to/demo-video.mp4)

## Technologies Used
- **iOS Development:** UIKit
- **Database:** Firebase Realtime Database

## Code Examples

### Firebase Integration

To initialize Firebase Realtime Database:

```swift
private let ref = Database.database().reference().child("jewelry")

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
```


## Adding New Jewelry


```swift
@objc private func addNewJewelry() {
    let alertController = UIAlertController(title: "Add New Jewelry", message: nil, preferredStyle: .alert)
    
    alertController.addTextField { textField in
        textField.placeholder = "Name"
    }
    alertController.addTextField { textField in
        textField.placeholder = "Description"
    }
    alertController.addTextField { textField in
        textField.placeholder = "Price"
        textField.keyboardType = .decimalPad
    }
    alertController.addTextField { textField in
        textField.placeholder = "Image URL"
    }
    
    let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
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
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alertController, animated: true, completion: nil)
}
```

## Deleting Jewelry

```swift
private func deleteJewelry(_ jewelry: Jewelry) {
    ref.child(jewelry.id).removeValue()
}
```



## Purchasing Item

```swift
@objc private func purchaseItem() {
    let alert = UIAlertController(title: nil, message: "Great choice! The jewelry is on its way :)", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
}
```



## Installation
Clone the repository:

```swift
git clone https://github.com/hadarber/JewelryCatalogIOS.git
```

Open the project in Xcode.

Install Firebase
Open the .xcworkspace file in Xcode.

## Contributing

Feel free to open an issue or submit a pull request if you have any suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
