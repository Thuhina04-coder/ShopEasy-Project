import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';

class DataService {
  static final List<Category> categories = [
    const Category(
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.devices,
      imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
    ),
    const Category(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom,
      imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400',
    ),
    const Category(
      id: 'home',
      name: 'Home & Living',
      icon: Icons.home,
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
    ),
    const Category(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_basketball,
      imageUrl: 'https://images.unsplash.com/photo-1461896836934-bd45ba8c3e1b?w=400',
    ),
    const Category(
      id: 'beauty',
      name: 'Beauty',
      icon: Icons.face,
      imageUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400',
    ),
    const Category(
      id: 'books',
      name: 'Books',
      icon: Icons.menu_book,
      imageUrl: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400',
    ),
    const Category(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket,
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
    ),
    const Category(
      id: 'toys',
      name: 'Toys & Games',
      icon: Icons.toys,
      imageUrl: 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=400',
    ),
  ];

  static final List<Product> products = [
    // Electronics
    const Product(
      id: 'e1',
      name: 'Samsung Galaxy S24 Ultra',
      description:
          'Experience the pinnacle of mobile technology with the Samsung Galaxy S24 Ultra. Featuring a stunning 6.8" Dynamic AMOLED 2X display, powerful Snapdragon 8 Gen 3 processor, and an incredible 200MP camera system. Built with titanium frame for durability and elegance.',
      price: 389990.00,
      originalPrice: 429990.00,
      imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
      ],
      categoryId: 'electronics',
      rating: 4.8,
      reviewCount: 1256,
      vendor: 'Samsung Official',
      specifications: {
        'Display': '6.8" Dynamic AMOLED 2X',
        'Processor': 'Snapdragon 8 Gen 3',
        'RAM': '12GB',
        'Storage': '256GB',
        'Battery': '5000mAh',
        'Camera': '200MP + 12MP + 50MP + 10MP',
      },
    ),
    const Product(
      id: 'e2',
      name: 'Apple MacBook Air M3',
      description:
          'Supercharged by the M3 chip, MacBook Air delivers exceptional performance in an impossibly thin design. Up to 18 hours of battery life, a brilliant Liquid Retina display, and a silent, fanless design.',
      price: 524990.00,
      originalPrice: 574990.00,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
      ],
      categoryId: 'electronics',
      rating: 4.9,
      reviewCount: 892,
      vendor: 'Apple Store',
      specifications: {
        'Chip': 'Apple M3',
        'Display': '13.6" Liquid Retina',
        'RAM': '8GB Unified',
        'Storage': '256GB SSD',
        'Battery': 'Up to 18 hours',
      },
    ),
    const Product(
      id: 'e3',
      name: 'Sony WH-1000XM5 Headphones',
      description:
          'Industry-leading noise cancellation with Auto NC Optimizer. Crystal clear hands-free calling with 4 beamforming microphones. Up to 30 hours of battery life with quick charging.',
      price: 89990.00,
      originalPrice: 109990.00,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400',
      ],
      categoryId: 'electronics',
      rating: 4.7,
      reviewCount: 2341,
      vendor: 'Sony Lanka',
      specifications: {
        'Type': 'Over-ear',
        'Noise Cancellation': 'Active (Auto NC Optimizer)',
        'Battery': '30 hours',
        'Driver': '30mm',
        'Weight': '250g',
      },
    ),
    const Product(
      id: 'e4',
      name: 'iPad Air 11" M2',
      description:
          'The iPad Air with M2 chip delivers powerful performance in a thin, portable design. Features an 11-inch Liquid Retina display, 12MP front and back cameras, and supports Apple Pencil Pro.',
      price: 249990.00,
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
      categoryId: 'electronics',
      rating: 4.6,
      reviewCount: 567,
      vendor: 'Apple Store',
      specifications: {
        'Chip': 'Apple M2',
        'Display': '11" Liquid Retina',
        'Storage': '128GB',
        'Camera': '12MP Wide',
      },
    ),
    const Product(
      id: 'e5',
      name: 'JBL Charge 5 Speaker',
      description:
          'Portable Bluetooth speaker with powerful JBL Pro Sound, bold design, and IP67 waterproof and dustproof rating. PartyBoost feature lets you pair multiple speakers.',
      price: 34990.00,
      originalPrice: 42990.00,
      imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
      categoryId: 'electronics',
      rating: 4.5,
      reviewCount: 1890,
      vendor: 'JBL Official',
      specifications: {
        'Output': '40W',
        'Battery': '20 hours',
        'Waterproof': 'IP67',
        'Bluetooth': '5.1',
      },
    ),

    // Fashion
    const Product(
      id: 'f1',
      name: 'Nike Air Max 270 Running Shoes',
      description:
          'Nike Air Max 270 delivers visible cushioning under every step. The design draws inspiration from Air Max icons, featuring Nike\'s biggest heel Air unit yet for a super-soft ride.',
      price: 24990.00,
      originalPrice: 29990.00,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
      ],
      categoryId: 'fashion',
      rating: 4.6,
      reviewCount: 3456,
      vendor: 'Nike Store',
      specifications: {
        'Material': 'Mesh upper',
        'Sole': 'Air Max',
        'Closure': 'Lace-up',
        'Style': 'Running/Casual',
      },
    ),
    const Product(
      id: 'f2',
      name: 'Levi\'s 501 Original Jeans',
      description:
          'The iconic straight fit with original riveted construction. Sits at the waist, regular through the thigh, with a straight leg. The original jean since 1873.',
      price: 14990.00,
      imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
      categoryId: 'fashion',
      rating: 4.4,
      reviewCount: 1234,
      vendor: 'Levi\'s Official',
      specifications: {
        'Fit': 'Original Straight',
        'Material': '100% Cotton Denim',
        'Rise': 'Regular',
      },
    ),
    const Product(
      id: 'f3',
      name: 'Ray-Ban Aviator Sunglasses',
      description:
          'The original Ray-Ban Aviator Classic. Gold metal frame with green G-15 lenses. Iconic design that has been a symbol of cool for decades.',
      price: 29990.00,
      originalPrice: 34990.00,
      imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400',
      categoryId: 'fashion',
      rating: 4.7,
      reviewCount: 876,
      vendor: 'Ray-Ban Store',
      specifications: {
        'Frame': 'Gold Metal',
        'Lens': 'Green Classic G-15',
        'Protection': 'UV400',
        'Size': '58mm',
      },
    ),
    const Product(
      id: 'f4',
      name: 'Casio G-Shock GA-2100',
      description:
          'Thin, compact G-SHOCK with a carbon core guard structure. Features shock resistance, 200m water resistance, world time, and LED light.',
      price: 19990.00,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      categoryId: 'fashion',
      rating: 4.8,
      reviewCount: 2100,
      vendor: 'Casio Lanka',
      specifications: {
        'Movement': 'Quartz',
        'Water Resistance': '200m',
        'Case Size': '45.4mm',
        'Weight': '51g',
      },
    ),

    // Home & Living
    const Product(
      id: 'h1',
      name: 'Dyson V15 Detect Vacuum',
      description:
          'Dyson\'s most powerful, intelligent cordless vacuum. Laser reveals microscopic dust. Piezo sensor counts and sizes particles. Adapts suction power automatically.',
      price: 189990.00,
      originalPrice: 219990.00,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400',
      categoryId: 'home',
      rating: 4.7,
      reviewCount: 456,
      vendor: 'Dyson Lanka',
      specifications: {
        'Runtime': 'Up to 60 minutes',
        'Suction': '240 AW',
        'Weight': '3.1kg',
        'Bin Volume': '0.76L',
      },
    ),
    const Product(
      id: 'h2',
      name: 'Nespresso Vertuo Coffee Machine',
      description:
          'Brew barista-quality coffee at home with the Nespresso Vertuo. Centrifusion technology extracts rich crema-topped coffee. Makes 5 cup sizes from espresso to carafe.',
      price: 54990.00,
      originalPrice: 64990.00,
      imageUrl: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=400',
      categoryId: 'home',
      rating: 4.5,
      reviewCount: 789,
      vendor: 'Nespresso',
      specifications: {
        'Pressure': '19 bar',
        'Water Tank': '1.1L',
        'Cup Sizes': '5 sizes',
        'Heat-up Time': '15 seconds',
      },
    ),
    const Product(
      id: 'h3',
      name: 'Luxury Cotton Bedsheet Set',
      description:
          '800 thread count Egyptian cotton bedsheet set. Includes fitted sheet, flat sheet, and 2 pillowcases. Exceptionally soft and durable.',
      price: 12990.00,
      originalPrice: 16990.00,
      imageUrl: 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
      categoryId: 'home',
      rating: 4.3,
      reviewCount: 567,
      vendor: 'HomeComfort',
      specifications: {
        'Thread Count': '800',
        'Material': 'Egyptian Cotton',
        'Size': 'Queen',
        'Pieces': '4 (fitted sheet, flat sheet, 2 pillowcases)',
      },
    ),

    // Sports
    const Product(
      id: 's1',
      name: 'Yoga Mat Premium 6mm',
      description:
          'Non-slip premium yoga mat with alignment lines. Made from eco-friendly TPE material. Perfect thickness for cushioning and stability.',
      price: 4990.00,
      originalPrice: 6990.00,
      imageUrl: 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400',
      categoryId: 'sports',
      rating: 4.4,
      reviewCount: 890,
      vendor: 'FitGear',
      specifications: {
        'Material': 'TPE',
        'Thickness': '6mm',
        'Size': '183cm x 61cm',
        'Weight': '0.8kg',
      },
    ),
    const Product(
      id: 's2',
      name: 'Adjustable Dumbbell Set 20kg',
      description:
          'Space-saving adjustable dumbbell set. Quick-change weight system from 2kg to 20kg. Chrome-plated handles with comfortable grip.',
      price: 15990.00,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      categoryId: 'sports',
      rating: 4.6,
      reviewCount: 345,
      vendor: 'IronFit',
      specifications: {
        'Weight Range': '2kg - 20kg',
        'Material': 'Cast Iron, Chrome Handle',
        'Adjustment': 'Pin-lock system',
      },
    ),
    const Product(
      id: 's3',
      name: 'Wilson Tennis Racket Pro',
      description:
          'Professional grade tennis racket with graphite frame. Ideal for intermediate to advanced players. Comfortable grip and excellent control.',
      price: 34990.00,
      originalPrice: 39990.00,
      imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=400',
      categoryId: 'sports',
      rating: 4.5,
      reviewCount: 210,
      vendor: 'Wilson Sports',
      specifications: {
        'Frame': 'Graphite Composite',
        'Head Size': '100 sq in',
        'Weight': '300g',
        'String Pattern': '16x19',
      },
    ),

    // Beauty
    const Product(
      id: 'b1',
      name: 'The Ordinary Skincare Set',
      description:
          'Complete skincare routine set including Niacinamide 10% + Zinc 1%, Hyaluronic Acid 2% + B5, and Natural Moisturizing Factors + HA. Ideal for all skin types.',
      price: 7990.00,
      originalPrice: 9990.00,
      imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
      categoryId: 'beauty',
      rating: 4.7,
      reviewCount: 3456,
      vendor: 'Beauty Hub',
      specifications: {
        'Pieces': '3',
        'Skin Type': 'All',
        'Key Ingredients': 'Niacinamide, Hyaluronic Acid',
      },
    ),
    const Product(
      id: 'b2',
      name: 'MAC Lipstick Ruby Woo',
      description:
          'The iconic matte red lipstick. Ruby Woo is a vivid blue-red that looks stunning on every skin tone. Retro matte finish with intense color payoff.',
      price: 6490.00,
      imageUrl: 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400',
      categoryId: 'beauty',
      rating: 4.8,
      reviewCount: 5678,
      vendor: 'MAC Cosmetics',
      specifications: {
        'Finish': 'Retro Matte',
        'Shade': 'Ruby Woo',
        'Weight': '3g',
      },
    ),
    const Product(
      id: 'b3',
      name: 'Dove Body Wash Collection',
      description:
          'Nourishing body wash gift set with 3 variants: Deeply Nourishing, Sensitive Skin, and Shea Butter. Gentle cleansing with NutriumMoisture technology.',
      price: 3490.00,
      originalPrice: 4490.00,
      imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
      categoryId: 'beauty',
      rating: 4.3,
      reviewCount: 1200,
      vendor: 'Dove Lanka',
      specifications: {
        'Variants': '3',
        'Volume': '500ml each',
        'Skin Type': 'All',
      },
    ),

    // Books
    const Product(
      id: 'bk1',
      name: 'Atomic Habits by James Clear',
      description:
          'An Easy & Proven Way to Build Good Habits & Break Bad Ones. Tiny Changes, Remarkable Results. One of the most impactful books on personal development.',
      price: 2990.00,
      originalPrice: 3990.00,
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
      categoryId: 'books',
      rating: 4.9,
      reviewCount: 8901,
      vendor: 'Book House',
      specifications: {
        'Author': 'James Clear',
        'Pages': '320',
        'Format': 'Paperback',
        'Language': 'English',
      },
    ),
    const Product(
      id: 'bk2',
      name: 'Rich Dad Poor Dad',
      description:
          'What the Rich Teach Their Kids About Money That the Poor and Middle Class Do Not! Robert Kiyosaki\'s classic on financial literacy and wealth building.',
      price: 2490.00,
      imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
      categoryId: 'books',
      rating: 4.7,
      reviewCount: 6543,
      vendor: 'Book House',
      specifications: {
        'Author': 'Robert T. Kiyosaki',
        'Pages': '336',
        'Format': 'Paperback',
        'Language': 'English',
      },
    ),

    // Groceries
    const Product(
      id: 'g1',
      name: 'Ceylon Tea Premium Collection',
      description:
          'Premium collection of authentic Ceylon teas. Includes black tea, green tea, and herbal infusions. Sourced directly from Sri Lankan tea estates.',
      price: 1990.00,
      originalPrice: 2490.00,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
      categoryId: 'groceries',
      rating: 4.8,
      reviewCount: 2345,
      vendor: 'Ceylon Tea Co.',
      specifications: {
        'Varieties': '6 types',
        'Weight': '600g total',
        'Origin': 'Sri Lanka',
      },
    ),
    const Product(
      id: 'g2',
      name: 'Organic Spice Gift Box',
      description:
          'Collection of 12 organic Sri Lankan spices including cinnamon, cardamom, cloves, pepper, turmeric and more. Perfect for authentic cooking.',
      price: 3490.00,
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
      categoryId: 'groceries',
      rating: 4.6,
      reviewCount: 876,
      vendor: 'Spice Island',
      specifications: {
        'Spices': '12 varieties',
        'Certification': 'Organic',
        'Origin': 'Sri Lanka',
      },
    ),

    // Toys & Games
    const Product(
      id: 't1',
      name: 'LEGO Creator 3-in-1 Set',
      description:
          'Build 3 different models with one set! Includes over 500 pieces for creative building. Suitable for ages 8+. Encourages imagination and fine motor skills.',
      price: 12990.00,
      originalPrice: 15990.00,
      imageUrl: 'https://images.unsplash.com/photo-1587654780291-39c9404d7dd0?w=400',
      categoryId: 'toys',
      rating: 4.8,
      reviewCount: 1567,
      vendor: 'Toy World',
      specifications: {
        'Pieces': '500+',
        'Age': '8+',
        'Models': '3-in-1',
        'Theme': 'Creator',
      },
    ),
    const Product(
      id: 't2',
      name: 'Board Game Collection Box',
      description:
          'Family board game collection including classics like Chess, Checkers, Ludo, and Snakes & Ladders. High quality wooden pieces and board.',
      price: 4990.00,
      imageUrl: 'https://images.unsplash.com/photo-1611371805429-8b5c1b2c34ba?w=400',
      categoryId: 'toys',
      rating: 4.5,
      reviewCount: 432,
      vendor: 'Game Zone',
      specifications: {
        'Games': '4 classic games',
        'Material': 'Wood',
        'Players': '2-4',
        'Age': '6+',
      },
    ),
  ];

  static List<Product> getProductsByCategory(String categoryId) {
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  static List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery) ||
          p.vendor.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Product? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Product> getFeaturedProducts() {
    return products.where((p) => p.rating >= 4.7).toList();
  }

  static List<Product> getDealsOfTheDay() {
    return products.where((p) => p.originalPrice != null).toList();
  }
}
