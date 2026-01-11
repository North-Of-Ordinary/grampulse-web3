import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class ReliefRequestState extends Equatable {
  const ReliefRequestState();

  @override
  List<Object?> get props => [];
}

class ReliefInitial extends ReliefRequestState {
  const ReliefInitial();
}

class ReliefUpdating extends ReliefRequestState {
  const ReliefUpdating();
}

class ReliefValid extends ReliefRequestState {
  final String damageDescription;
  final double lossAmount;
  final BankDetails bankDetails;
  final Map<String, File> documents;
  final bool isLookingUpBank;
  final bool isFormValid;

  const ReliefValid({
    this.damageDescription = '',
    this.lossAmount = 0.0,
    required this.bankDetails,
    required this.documents,
    this.isLookingUpBank = false,
    this.isFormValid = false,
  });

  @override
  List<Object?> get props => [
    damageDescription,
    lossAmount,
    bankDetails,
    documents,
    isLookingUpBank,
    isFormValid,
  ];

  bool get canProceed => isFormValid;

  bool get hasIdProof => documents.containsKey('id_proof');
  
  bool get hasPropertyDocument => documents.containsKey('property_document');
  
  bool get hasDamagePhoto => documents.containsKey('damage_photo');

  ReliefValid copyWith({
    String? damageDescription,
    double? lossAmount,
    BankDetails? bankDetails,
    Map<String, File>? documents,
    bool? isLookingUpBank,
    bool? isFormValid,
  }) {
    return ReliefValid(
      damageDescription: damageDescription ?? this.damageDescription,
      lossAmount: lossAmount ?? this.lossAmount,
      bankDetails: bankDetails ?? this.bankDetails,
      documents: documents ?? this.documents,
      isLookingUpBank: isLookingUpBank ?? this.isLookingUpBank,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class ReliefInvalid extends ReliefRequestState {
  final String message;
  final Map<String, String> fieldErrors;

  const ReliefInvalid({
    required this.message,
    this.fieldErrors = const {},
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}
