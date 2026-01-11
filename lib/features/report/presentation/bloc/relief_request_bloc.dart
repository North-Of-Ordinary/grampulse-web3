import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/relief_request_event.dart';
import 'package:grampulse/features/report/presentation/bloc/relief_request_state.dart';

class ReliefRequestBloc extends Bloc<ReliefRequestEvent, ReliefRequestState> {
  ReliefRequestBloc() : super(const ReliefInitial()) {
    on<InitializeReliefForm>(_onInitializeReliefForm);
    on<UpdateDamageDescription>(_onUpdateDamageDescription);
    on<UpdateLossAmount>(_onUpdateLossAmount);
    on<UpdateBankDetails>(_onUpdateBankDetails);
    on<LookupBankFromIFSC>(_onLookupBankFromIFSC);
    on<UploadDocument>(_onUploadDocument);
    on<RemoveDocument>(_onRemoveDocument);
    on<ValidateAndProceed>(_onValidateAndProceed);
    
    // Initialize with empty form
    add(const InitializeReliefForm());
  }

  Future<void> _onInitializeReliefForm(
    InitializeReliefForm event,
    Emitter<ReliefRequestState> emit
  ) async {
    emit(const ReliefUpdating());
    
    try {
      final initialState = ReliefValid(
        bankDetails: BankDetails.empty(),
        documents: {},
        damageDescription: '',
        lossAmount: 0.0,
      );
      emit(initialState);
    } catch (e) {
      emit(ReliefInvalid(message: 'Failed to initialize form: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDamageDescription(
    UpdateDamageDescription event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      final updatedState = currentState.copyWith(
        damageDescription: event.description,
      );
      
      emit(updatedState.copyWith(
        isFormValid: _validateForm(updatedState),
      ));
    }
  }

  Future<void> _onUpdateLossAmount(
    UpdateLossAmount event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      final updatedState = currentState.copyWith(
        lossAmount: event.amount,
      );
      
      emit(updatedState.copyWith(
        isFormValid: _validateForm(updatedState),
      ));
    }
  }

  Future<void> _onUpdateBankDetails(
    UpdateBankDetails event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      final updatedBankDetails = currentState.bankDetails.copyWith(
        accountHolder: event.accountHolder,
        accountNumber: event.accountNumber,
        ifscCode: event.ifscCode,
      );
      
      final updatedState = currentState.copyWith(
        bankDetails: updatedBankDetails,
      );
      
      emit(updatedState.copyWith(
        isFormValid: _validateForm(updatedState),
      ));
    }
  }

  Future<void> _onLookupBankFromIFSC(
    LookupBankFromIFSC event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      if (event.ifscCode.length < 11) {
        // IFSC codes are 11 characters, not enough to lookup
        return;
      }
      
      emit(currentState.copyWith(isLookingUpBank: true));
      
      try {
        // Simulate API call to lookup bank
        await Future.delayed(const Duration(seconds: 1));
        
        // Mock response based on first few characters
        String bankName;
        String? branch;
        
        if (event.ifscCode.startsWith('SBI')) {
          bankName = 'State Bank of India';
          branch = 'Main Branch';
        } else if (event.ifscCode.startsWith('HDFC')) {
          bankName = 'HDFC Bank';
          branch = 'City Branch';
        } else if (event.ifscCode.startsWith('ICIC')) {
          bankName = 'ICICI Bank';
          branch = 'Town Branch';
        } else {
          bankName = 'Unknown Bank';
          branch = 'Unknown Branch';
        }
        
        final updatedBankDetails = currentState.bankDetails.copyWith(
          ifscCode: event.ifscCode,
          bankName: bankName,
          branch: branch,
        );
        
        final updatedState = currentState.copyWith(
          bankDetails: updatedBankDetails,
          isLookingUpBank: false,
        );
        
        emit(updatedState.copyWith(
          isFormValid: _validateForm(updatedState),
        ));
      } catch (e) {
        emit(currentState.copyWith(isLookingUpBank: false));
        emit(ReliefInvalid(message: 'Failed to lookup bank: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      final updatedDocuments = Map<String, File>.from(currentState.documents);
      updatedDocuments[event.documentType] = event.file;
      
      final updatedState = currentState.copyWith(
        documents: updatedDocuments,
      );
      
      emit(updatedState.copyWith(
        isFormValid: _validateForm(updatedState),
      ));
    }
  }

  Future<void> _onRemoveDocument(
    RemoveDocument event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      final updatedDocuments = Map<String, File>.from(currentState.documents);
      updatedDocuments.remove(event.documentType);
      
      final updatedState = currentState.copyWith(
        documents: updatedDocuments,
      );
      
      emit(updatedState.copyWith(
        isFormValid: _validateForm(updatedState),
      ));
    }
  }

  Future<void> _onValidateAndProceed(
    ValidateAndProceed event,
    Emitter<ReliefRequestState> emit
  ) async {
    if (state is ReliefValid) {
      final currentState = state as ReliefValid;
      
      if (!_validateForm(currentState)) {
        // Show errors for each invalid field
        final errors = _getFieldErrors(currentState);
        emit(ReliefInvalid(
          message: 'Please fix the errors before proceeding',
          fieldErrors: errors,
        ));
        emit(currentState);
        return;
      }
      
      // If validation passes, we can proceed (handled by parent)
    }
  }
  
  // Helper methods
  bool _validateForm(ReliefValid state) {
    // Check for required fields
    if (state.damageDescription.isEmpty || state.damageDescription.length < 10) {
      return false;
    }
    
    if (state.lossAmount <= 0) {
      return false;
    }
    
    if (state.bankDetails.accountHolder.isEmpty || 
        state.bankDetails.accountNumber.isEmpty || 
        state.bankDetails.ifscCode.isEmpty) {
      return false;
    }
    
    // Validate account number is numeric and at least 9-18 digits
    if (state.bankDetails.accountNumber.length < 9 || 
        state.bankDetails.accountNumber.length > 18 ||
        !RegExp(r'^\d+$').hasMatch(state.bankDetails.accountNumber)) {
      return false;
    }
    
    // Validate IFSC code format (11 chars, alphanumeric)
    if (state.bankDetails.ifscCode.length != 11 ||
        !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(state.bankDetails.ifscCode)) {
      return false;
    }
    
    // Require at least ID proof and one more document
    if (!state.hasIdProof || (!state.hasPropertyDocument && !state.hasDamagePhoto)) {
      return false;
    }
    
    return true;
  }
  
  Map<String, String> _getFieldErrors(ReliefValid state) {
    final errors = <String, String>{};
    
    if (state.damageDescription.isEmpty) {
      errors['damageDescription'] = 'Damage description is required';
    } else if (state.damageDescription.length < 10) {
      errors['damageDescription'] = 'Description is too short';
    }
    
    if (state.lossAmount <= 0) {
      errors['lossAmount'] = 'Please enter a valid amount';
    }
    
    if (state.bankDetails.accountHolder.isEmpty) {
      errors['accountHolder'] = 'Account holder name is required';
    }
    
    if (state.bankDetails.accountNumber.isEmpty) {
      errors['accountNumber'] = 'Account number is required';
    } else if (state.bankDetails.accountNumber.length < 9 || 
               state.bankDetails.accountNumber.length > 18) {
      errors['accountNumber'] = 'Account number should be 9-18 digits';
    } else if (!RegExp(r'^\d+$').hasMatch(state.bankDetails.accountNumber)) {
      errors['accountNumber'] = 'Account number should only contain digits';
    }
    
    if (state.bankDetails.ifscCode.isEmpty) {
      errors['ifscCode'] = 'IFSC code is required';
    } else if (state.bankDetails.ifscCode.length != 11) {
      errors['ifscCode'] = 'IFSC code should be 11 characters';
    } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(state.bankDetails.ifscCode)) {
      errors['ifscCode'] = 'Invalid IFSC format';
    }
    
    if (!state.hasIdProof) {
      errors['id_proof'] = 'ID proof is required';
    }
    
    if (!state.hasPropertyDocument && !state.hasDamagePhoto) {
      errors['documents'] = 'At least one additional document is required';
    }
    
    return errors;
  }
}
