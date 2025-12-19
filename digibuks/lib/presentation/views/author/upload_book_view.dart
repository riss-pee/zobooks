import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../controllers/author_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';

class UploadBookView extends StatefulWidget {
  const UploadBookView({super.key});

  @override
  State<UploadBookView> createState() => _UploadBookViewState();
}

class _UploadBookViewState extends State<UploadBookView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _rentalDaysController = TextEditingController();
  final _selectedLanguage = AppConstants.languageEnglish.obs;
  final _selectedType = AppConstants.bookTypePurchase.obs;
  final _selectedFileType = AppConstants.fileTypePDF.obs;
  final _selectedGenres = <String>[].obs;
  final authorController = Get.find<AuthorController>();

  final List<String> _availableGenres = [
    'Fiction',
    'Non-Fiction',
    'Poetry',
    'History',
    'Culture',
    'Biography',
    'Science',
    'Education',
    'Cookbook',
    'Travel',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _rentalPriceController.dispose();
    _rentalDaysController.dispose();
    super.dispose();
  }

  void _handleUpload() {
    if (_formKey.currentState!.validate()) {
      // Validate pricing based on type
      if (_selectedType.value == AppConstants.bookTypePurchase) {
        if (_priceController.text.isEmpty) {
          showSnackSafe('Error', 'Price is required for purchase type');
          return;
        }
      } else if (_selectedType.value == AppConstants.bookTypeRental) {
        if (_rentalPriceController.text.isEmpty) {
          showSnackSafe('Error', 'Rental price is required');
          return;
        }
        if (_rentalDaysController.text.isEmpty) {
          showSnackSafe('Error', 'Rental days is required');
          return;
        }
      }

      showSnackSafe(
        'Success',
        'Book uploaded successfully! It will be reviewed by admin.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
      
      // Reload books
      authorController.loadMyBooks();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  hintText: 'Enter book title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => Validators.validateRequired(value, 'Title'),
              ),
              const SizedBox(height: 20),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter book description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => Validators.validateRequired(value, 'Description'),
              ),
              const SizedBox(height: 20),
              // Language
              Obx(
                () => DropdownButtonFormField<String>(
                  value: _selectedLanguage.value,
                  decoration: InputDecoration(
                    labelText: 'Language *',
                    prefixIcon: const Icon(Icons.language),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.languageEnglish,
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.languageMizo,
                      child: Text('Mizo'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _selectedLanguage.value = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // File Type
              Obx(
                () => DropdownButtonFormField<String>(
                  value: _selectedFileType.value,
                  decoration: InputDecoration(
                    labelText: 'File Type *',
                    prefixIcon: const Icon(Icons.insert_drive_file),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.fileTypePDF,
                      child: Text('PDF'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.fileTypeEPUB,
                      child: Text('EPUB'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _selectedFileType.value = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Book Type
              Obx(
                () => DropdownButtonFormField<String>(
                  value: _selectedType.value,
                  decoration: InputDecoration(
                    labelText: 'Book Type *',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.bookTypePurchase,
                      child: Text('Purchase Only'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.bookTypeRental,
                      child: Text('Rental Only'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.bookTypeFree,
                      child: Text('Free'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _selectedType.value = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Price (if purchase)
              if (_selectedType.value == AppConstants.bookTypePurchase)
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (₹) *',
                    hintText: 'Enter price',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (_selectedType.value == AppConstants.bookTypePurchase) {
                      return Validators.validateRequired(value, 'Price');
                    }
                    return null;
                  },
                ),
              if (_selectedType.value == AppConstants.bookTypePurchase)
                const SizedBox(height: 20),
              // Rental Price (if rental)
              if (_selectedType.value == AppConstants.bookTypeRental) ...[
                TextFormField(
                  controller: _rentalPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Rental Price (₹) *',
                    hintText: 'Enter rental price',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (_selectedType.value == AppConstants.bookTypeRental) {
                      return Validators.validateRequired(value, 'Rental Price');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _rentalDaysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Rental Days *',
                    hintText: 'Enter rental period in days',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (_selectedType.value == AppConstants.bookTypeRental) {
                      return Validators.validateRequired(value, 'Rental Days');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
              // Genres
              Text(
                'Genres',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableGenres.map((genre) {
                    final isSelected = _selectedGenres.contains(genre);
                    return FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _selectedGenres.add(genre);
                        } else {
                          _selectedGenres.remove(genre);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              // Upload File Button
              OutlinedButton.icon(
                onPressed: () {
                  showSnackSafe('File Picker', 'File picker will open here');
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Book File (PDF/EPUB)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleUpload,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Upload Book',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

