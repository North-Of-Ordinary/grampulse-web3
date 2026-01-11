import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ReliefRequestEvent extends Equatable {
  const ReliefRequestEvent();

  @override
  List<Object?> get props => [];
}

class InitializeReliefForm extends ReliefRequestEvent {
  const InitializeReliefForm();
}

class UpdateDamageDescription extends ReliefRequestEvent {
  final String description;

  const UpdateDamageDescription(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdateLossAmount extends ReliefRequestEvent {
  final double amount;

  const UpdateLossAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateBankDetails extends ReliefRequestEvent {
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  
  const UpdateBankDetails({
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
  });
  
  @override
  List<Object?> get props => [accountHolder, accountNumber, ifscCode];
}

class LookupBankFromIFSC extends ReliefRequestEvent {
  final String ifscCode;

  const LookupBankFromIFSC(this.ifscCode);

  @override
  List<Object?> get props => [ifscCode];
}

class UploadDocument extends ReliefRequestEvent {
  final String documentType;
  final File file;

  const UploadDocument({
    required this.documentType,
    required this.file,
  });

  @override
  List<Object?> get props => [documentType, file];
}

class RemoveDocument extends ReliefRequestEvent {
  final String documentType;

  const RemoveDocument(this.documentType);

  @override
  List<Object?> get props => [documentType];
}

class ValidateAndProceed extends ReliefRequestEvent {
  const ValidateAndProceed();
}
