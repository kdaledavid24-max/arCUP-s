import '../models/product.dart';

/// Centralized repository of all menu products for arCUPs Coffee Shop.
/// Prices adhere to the student project guidelines:
/// - Drinks (Coffee & Frappe): ₱100 - ₱200
/// - Salad & Pasta: ₱200 - ₱300
class ProductData {
  static const List<String> categories = [
    'All',
    'Coffee & Espresso',
    'Frappe Series',
    'Salad',
    'Pasta',
  ];

  static final List<Product> products = [
    // ------------------------------------------------------------------------
    // COFFEE & ESPRESSO (Range: ₱100 - ₱200)
    // ------------------------------------------------------------------------
    const Product(
      id: 'coffee_001',
      name: 'Biscoff Latte',
      category: 'Coffee & Espresso',
      description:
          'A rich, creamy espresso infused with caramelized Lotus Biscoff spread and topped with crushed biscuits.',
      price: 160.00,
      image: 'assets/images/drinks/biscoff_latte.jpg',
      available: true,
    ),
    const Product(
      id: 'coffee_002',
      name: 'Americano',
      category: 'Coffee & Espresso',
      description:
          'Classic bold espresso shots poured over hot water or served chilled over ice for pure coffee lovers.',
      price: 120.00,
      image: 'assets/images/drinks/americano.jpg',
      available: true,
    ),
    const Product(
      id: 'coffee_003',
      name: 'Mocha Latte',
      category: 'Coffee & Espresso',
      description:
          'Harmonious balance of deep roasted espresso, rich chocolate syrup, and silky steamed milk.',
      price: 150.00,
      image: 'assets/images/drinks/mocha_latte.jpg',
      available: true,
    ),
    const Product(
      id: 'coffee_004',
      name: 'Caramel Macchiato',
      category: 'Coffee & Espresso',
      description:
          'Freshly steamed vanilla milk marked with rich espresso and drizzled with sweet golden caramel.',
      price: 165.00,
      image: 'assets/images/drinks/caramel_macchiato.jpg',
      available: true,
    ),
    const Product(
      id: 'coffee_005',
      name: 'Dirty Matcha',
      category: 'Coffee & Espresso',
      description:
          'Premium Japanese ceremonial green tea matcha layered over milk and crowned with a bold shot of espresso.',
      price: 170.00,
      image: 'assets/images/drinks/dirty_matcha.jpg',
      available: true,
    ),
    const Product(
      id: 'coffee_006',
      name: 'Roasted Almond Latte',
      category: 'Coffee & Espresso',
      description:
          'Smooth espresso elevated with fragrant roasted almond notes and velvety textured milk.',
      price: 165.00,
      image: 'assets/images/drinks/roasted_almond_latte.jpg',
      available: true,
    ),

    // ------------------------------------------------------------------------
    // FRAPPE SERIES (Range: ₱100 - ₱200)
    // ------------------------------------------------------------------------
    const Product(
      id: 'frappe_001',
      name: 'Biscoff Frappe',
      category: 'Frappe Series',
      description:
          'Blended ice beverage featuring spiced Lotus cookie butter, creamy milk, and decadent whipped cream.',
      price: 180.00,
      image: 'assets/images/frappe/biscoff_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_002',
      name: 'Blueberry Frappe',
      category: 'Frappe Series',
      description:
          'Refreshing ice-blended smoothie bursting with real wild blueberries and sweet cream.',
      price: 170.00,
      image: 'assets/images/frappe/blueberry_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_003',
      name: 'Caramel Frappuccino',
      category: 'Frappe Series',
      description:
          'Coffee blended with buttery caramel syrup, ice, and milk, garnished with whipped cream and caramel drizzle.',
      price: 175.00,
      image: 'assets/images/frappe/caramel_frappuccino.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_004',
      name: 'Cookies and Cream Frappe',
      category: 'Frappe Series',
      description:
          'A crowd favorite crushed chocolate sandwich cookies blended with vanilla bean milk base.',
      price: 170.00,
      image: 'assets/images/frappe/cookies_cream_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_005',
      name: 'Java Chips Frappe',
      category: 'Frappe Series',
      description:
          'Espresso, chocolate chips, and mocha sauce blended with ice for a crunchy, chocolatey coffee experience.',
      price: 185.00,
      image: 'assets/images/frappe/java_chips_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_006',
      name: 'Matcha Frappe',
      category: 'Frappe Series',
      description:
          'Vibrant sweetened Uji matcha powder blended with fresh milk, crushed ice, and topped with light cream.',
      price: 175.00,
      image: 'assets/images/frappe/matcha_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_007',
      name: 'Strawberry Frappe',
      category: 'Frappe Series',
      description:
          'Delightful blend of real strawberry puree and sweet vanilla cream swirled over cold ice.',
      price: 170.00,
      image: 'assets/images/frappe/strawberry_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_008',
      name: 'Vanilla Frappe',
      category: 'Frappe Series',
      description:
          'Pure creamy indulgence made with rich Madagascar vanilla syrup, milk, and smooth crushed ice.',
      price: 160.00,
      image: 'assets/images/frappe/vanilla_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_009',
      name: 'Coffee Jelly Frappe',
      category: 'Frappe Series',
      description:
          'Handcrafted chilled coffee frappe served over chewy, aromatic homemade coffee gelatin cubes.',
      price: 165.00,
      image: 'assets/images/frappe/coffee_jelly_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_010',
      name: 'Ube Frappe',
      category: 'Frappe Series',
      description:
          'Signature Filipino purple yam blended into a vibrant, silky purple frappe with coconut cream hints.',
      price: 170.00,
      image: 'assets/images/frappe/ube_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_011',
      name: 'White Chocolate Frappe',
      category: 'Frappe Series',
      description:
          'Velvety melted white chocolate confection blended with fresh milk, ice, and cloud-like topping.',
      price: 175.00,
      image: 'assets/images/frappe/white_chocolate_frappe.jpg',
      available: true,
    ),
    const Product(
      id: 'frappe_012',
      name: 'Nutella Frappe',
      category: 'Frappe Series',
      description:
          'Generous swirls of hazelnut cocoa Nutella blended to frosty perfection and topped with roasted cocoa dust.',
      price: 190.00,
      image: 'assets/images/frappe/nutella_frappe.jpg',
      available: true,
    ),

    // ------------------------------------------------------------------------
    // SALAD (Range: ₱200 - ₱300)
    // ------------------------------------------------------------------------
    const Product(
      id: 'salad_001',
      name: 'Caesar Salad',
      category: 'Salad',
      description:
          'Crisp romaine lettuce, crunchy herb croutons, savory bacon bits, and aged parmesan cheese tossed in creamy Caesar dressing.',
      price: 240.00,
      image: 'assets/images/salad/caesar_salad.jpg',
      available: true,
    ),
    const Product(
      id: 'salad_002',
      name: 'Kani Mango Garden Salad',
      category: 'Salad',
      description:
          'Fresh garden greens tossed with shredded Japanese crab sticks, sweet ripe mangoes, nori strips, and creamy roasted sesame dressing.',
      price: 260.00,
      image: 'assets/images/salad/kani_mango_garden_salad.jpg',
      available: true,
    ),
    const Product(
      id: 'salad_003',
      name: 'Shrimp Garden Salad',
      category: 'Salad',
      description:
          'Succulent pan-seared garlic shrimps atop seasonal mixed greens, cherry tomatoes, cucumber, and zesty citrus vinaigrette.',
      price: 280.00,
      image: 'assets/images/salad/shrimp_garden_salad.jpg',
      available: true,
    ),

    // ------------------------------------------------------------------------
    // PASTA (Range: ₱200 - ₱300)
    // ------------------------------------------------------------------------
    const Product(
      id: 'pasta_001',
      name: 'Creamy Carbonara',
      category: 'Pasta',
      description:
          'Al dente fettuccine coated in rich egg-yolk and cream sauce with crispy smoked bacon, mushrooms, and fresh parmesan.',
      price: 250.00,
      image: 'assets/images/pasta/creamy_carbonara.jpg',
      available: true,
    ),
    const Product(
      id: 'pasta_002',
      name: 'Pesto Pasta',
      category: 'Pasta',
      description:
          'Fragrant homemade sweet basil pesto tossed with extra virgin olive oil, toasted pine nuts, and shaved parmesan.',
      price: 240.00,
      image: 'assets/images/pasta/pesto_pasta.jpg',
      available: true,
    ),
    const Product(
      id: 'pasta_003',
      name: 'Spaghetti',
      category: 'Pasta',
      description:
          'Classic slow-simmered savory tomato meat sauce with minced ground beef, Italian herbs, and melted cheddar.',
      price: 220.00,
      image: 'assets/images/pasta/spaghetti.jpg',
      available: true,
    ),
    const Product(
      id: 'pasta_004',
      name: 'Spanish Sardines Pasta',
      category: 'Pasta',
      description:
          'Spicy gourmet Spanish sardines sautéed in garlic olive oil, black olives, capers, and chili flakes over tender spaghetti.',
      price: 270.00,
      image: 'assets/images/pasta/spanish_sardines_pasta.jpg',
      available: true,
    ),
  ];
}
