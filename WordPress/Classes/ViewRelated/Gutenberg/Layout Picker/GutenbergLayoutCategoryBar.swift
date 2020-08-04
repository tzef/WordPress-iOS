import UIKit

protocol CategoryBarDelegate {
    func numberOfCategories() -> Int
    func category(forIndex: Int) -> GutenbergLayoutDisplayCategory
}

class GutenbergLayoutFilterBar: UICollectionView {
    var categoryDelegate: CategoryBarDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(LayoutPickerFilterCollectionViewCell.nib, forCellWithReuseIdentifier: LayoutPickerFilterCollectionViewCell.cellReuseIdentifier)
        self.delegate = self
        self.dataSource = self
    }
}

extension GutenbergLayoutFilterBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}

extension GutenbergLayoutFilterBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105.0, height: 44.0)
     }
}

extension GutenbergLayoutFilterBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryDelegate?.numberOfCategories() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LayoutPickerFilterCollectionViewCell.cellReuseIdentifier, for: indexPath) as! LayoutPickerFilterCollectionViewCell
        return cell
    }
}
