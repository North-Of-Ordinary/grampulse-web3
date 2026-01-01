import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class DescribeIssueState extends Equatable {
  const DescribeIssueState();

  @override
  List<Object?> get props => [];
}

class DescribeInitial extends DescribeIssueState {
  const DescribeInitial();
}

class DescribeUpdating extends DescribeIssueState {
  const DescribeUpdating();
}

class DescribeReady extends DescribeIssueState {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String description;
  final int severity;
  final double latitude;
  final double longitude;
  final String address;
  final bool isProcessingVoice;
  
  const DescribeReady({
    required this.categories,
    this.selectedCategoryId,
    this.description = '',
    this.severity = 2, // Medium severity by default
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isProcessingVoice = false,
  });
  
  @override
  List<Object?> get props => [
    categories,
    selectedCategoryId,
    description,
    severity,
    latitude,
    longitude,
    address,
    isProcessingVoice,
  ];
  
  bool get isDisasterCategory {
    if (selectedCategoryId == null) return false;
    
    final category = categories.firstWhere(
      (c) => c.id == selectedCategoryId,
      orElse: () => CategoryModel(
        id: '',
        name: '',
        iconCode: '',
        isDisasterRelated: false,
      ),
    );
    
    return category.isDisasterRelated;
  }
  
  bool get canProceed => 
    selectedCategoryId != null && 
    description.isNotEmpty && 
    description.length >= 10; // Minimum 10 characters
    
  CategoryModel? get selectedCategory {
    if (selectedCategoryId == null) return null;
    
    try {
      return categories.firstWhere((c) => c.id == selectedCategoryId);
    } catch (_) {
      return null;
    }
  }
  
  DescribeReady copyWith({
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    String? description,
    int? severity,
    double? latitude,
    double? longitude,
    String? address,
    bool? isProcessingVoice,
  }) {
    return DescribeReady(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isProcessingVoice: isProcessingVoice ?? this.isProcessingVoice,
    );
  }
}

class DescribeError extends DescribeIssueState {
  final String message;
  
  const DescribeError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
