import UIKit

class JewelryCollectionViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    func setupLayout() {
            minimumInteritemSpacing = 10
            minimumLineSpacing = 10
            sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            let width = UIScreen.main.bounds.width
            let itemWidth = (width - 30) / 2 // 2 items per row with 10 points spacing
            itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        }
}
