import '../features/shopping/view_model/shopping_view_model.dart';

/// Previews and test fixtures for Shopping list.
abstract class ShoppingFixtures {
  static const standard = ShoppingViewModel(
    items: [
      ShoppingItemViewModel(
        id: 's-01',
        name: 'Chicken (curry cut)',
        amount: '1 kg',
        category: 'Meat & Poultry',
      ),
      ShoppingItemViewModel(
        id: 's-02',
        name: 'Chana daal',
        amount: '500 g',
        category: 'Pantry Staples',
      ),
      ShoppingItemViewModel(
        id: 's-03',
        name: 'Chakki atta',
        amount: '5 kg',
        category: 'Pantry Staples',
        isPurchased: true,
      ),
      ShoppingItemViewModel(
        id: 's-04',
        name: 'Tomatoes & onions',
        amount: '1 kg each',
        category: 'Fresh Produce',
      ),
      ShoppingItemViewModel(
        id: 's-05',
        name: 'Dahi (Plain yogurt)',
        amount: '500 g',
        category: 'Dairy',
      ),
    ],
  );

  static const empty = ShoppingViewModel(items: []);
}
