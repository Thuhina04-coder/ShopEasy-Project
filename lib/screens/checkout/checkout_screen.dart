import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/user.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../profile/address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPayment = 'cod';
  bool _isProcessing = false;

  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.replaceAll(' ', '').isEmpty) {
      return 'Card number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) {
      return 'Enter a valid card number (13-19 digits)';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Expiry is required';
    final parts = value.split('/');
    if (parts.length != 2) return 'Use MM/YY format';
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return 'Invalid date';
    if (month < 1 || month > 12) return 'Invalid month';
    final now = DateTime.now();
    final fullYear = 2000 + year;
    if (fullYear < now.year ||
        (fullYear == now.year && month < now.month)) {
      return 'Card has expired';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (value.length < 3 || value.length > 4) return 'Enter 3 or 4 digits';
    if (int.tryParse(value) == null) return 'Numbers only';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final selectedAddress = auth.defaultAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && selectedAddress == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add a shipping address'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
            return;
          }
          if (_currentStep == 1 &&
              _selectedPayment == 'card' &&
              !_cardFormKey.currentState!.validate()) {
            return;
          }
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _placeOrder(context, cart, auth);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : details.onStepContinue,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentStep == 2 ? 'Place Order' : 'Continue'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Shipping Address'),
            subtitle: selectedAddress != null
                ? Text(selectedAddress.label)
                : null,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildAddressStep(selectedAddress),
          ),
          Step(
            title: const Text('Payment Method'),
            subtitle: Text(_getPaymentLabel()),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildPaymentStep(),
          ),
          Step(
            title: const Text('Order Summary'),
            isActive: _currentStep >= 2,
            content: _buildSummaryStep(cart, selectedAddress),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep(Address? selectedAddress) {
    if (selectedAddress == null) {
      return Column(
        children: [
          Icon(Icons.location_off, size: 48, color: AppTheme.textHint),
          const SizedBox(height: 8),
          const Text('No shipping address found'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      selectedAddress.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (selectedAddress.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddressScreen()),
                    );
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedAddress.fullName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(selectedAddress.formatted),
            Text(selectedAddress.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Form(
      key: _cardFormKey,
      child: Column(
        children: [
          _PaymentOption(
            icon: Icons.money,
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive your order',
            isSelected: _selectedPayment == 'cod',
            onTap: () => setState(() => _selectedPayment = 'cod'),
          ),
          _PaymentOption(
            icon: Icons.credit_card,
            title: 'Credit/Debit Card',
            subtitle: 'Simulated secure payment',
            isSelected: _selectedPayment == 'card',
            onTap: () => setState(() => _selectedPayment = 'card'),
          ),
          if (_selectedPayment == 'card') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a simulated payment. No real charges will be made.',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.accentColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '4242 4242 4242 4242',
                prefixIcon: Icon(Icons.credit_card),
              ),
              validator: _validateCardNumber,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cardExpiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                    ),
                    validator: _validateExpiry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cardCvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '***',
                    ),
                    validator: _validateCvv,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNameController,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
          ],
          _PaymentOption(
            icon: Icons.account_balance,
            title: 'Bank Transfer',
            subtitle: 'Transfer to our bank account',
            isSelected: _selectedPayment == 'bank',
            onTap: () => setState(() => _selectedPayment = 'bank'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(CartProvider cart, Address? address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...cart.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Qty: ${item.quantity} x ${AppConstants.formatPrice(item.product.price)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppConstants.formatPrice(item.totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        _SummaryRow(label: 'Subtotal', value: cart.subtotal),
        _SummaryRow(
          label: 'Shipping',
          value: cart.shippingFee,
          isFree: cart.shippingFee == 0,
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              AppConstants.formatPrice(cart.total),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.payment, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Payment: ${_getPaymentLabel()}',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        if (address != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ship to: ${address.formatted}',
                  style: TextStyle(color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getPaymentLabel() {
    switch (_selectedPayment) {
      case 'cod':
        return 'Cash on Delivery';
      case 'card':
        return 'Credit/Debit Card';
      case 'bank':
        return 'Bank Transfer';
      default:
        return _selectedPayment;
    }
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartProvider cart,
    AuthProvider auth,
  ) async {
    final address = auth.defaultAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a shipping address')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final orderProvider = context.read<OrderProvider>();

    // Simulated payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Simulate card payment with 90% success rate
    if (_selectedPayment == 'card') {
      final random = Random();
      final success = random.nextDouble() < 0.9;
      if (!success) {
        setState(() => _isProcessing = false);
        _showPaymentFailedDialog();
        return;
      }
    }

    final order = await orderProvider.placeOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      shippingFee: cart.shippingFee,
      total: cart.total,
      shippingAddress: address,
      paymentMethod: _getPaymentLabel(),
    );

    await cart.clearCart();

    setState(() => _isProcessing = false);

    if (!mounted) return;

    _showOrderSuccessDialog(order);
  }

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.errorColor, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Payment Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your card payment could not be processed. Please check your card details and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _currentStep = 1);
              },
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccessDialog(dynamic order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${order.id}',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${AppConstants.formatPrice(order.total)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            if (_selectedPayment == 'card') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16, color: AppTheme.successColor),
                    SizedBox(width: 4),
                    Text(
                      'Payment processed successfully',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.successColor),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Thank you for shopping with ShopEasy!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Continue Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 1.5)
              : Border.all(color: AppTheme.dividerColor),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.03)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isFree;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(
            isFree ? 'FREE' : AppConstants.formatPrice(value),
            style: TextStyle(
              color: isFree ? AppTheme.successColor : null,
              fontWeight: isFree ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }
}
