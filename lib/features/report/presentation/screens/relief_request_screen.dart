import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/relief_request_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/relief_request_event.dart';
import 'package:grampulse/features/report/presentation/bloc/relief_request_state.dart';
import 'package:grampulse/features/report/presentation/widgets/document_source_sheet_updated.dart';

class ReliefRequestScreen extends StatelessWidget {
  final List<ReportMedia> capturedMedia;
  final CategoryModel category;
  final String description;
  final int severity;
  final double latitude;
  final double longitude;
  final String address;

  const ReliefRequestScreen({
    Key? key,
    required this.capturedMedia,
    required this.category,
    required this.description,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReliefRequestBloc(),
      child: BlocConsumer<ReliefRequestBloc, ReliefRequestState>(
        listener: (context, state) {
          if (state is ReliefInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Relief'),
                  Text(
                    'Step 3/4: Relief Details',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: 0.75, // 3/4 steps
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            body: state is ReliefInitial
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, state),
            bottomNavigationBar: state is ReliefValid
                ? _buildBottomBar(context, state)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReliefRequestState state) {
    if (state is ReliefValid) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Damage description field
            Text(
              'Damage Description',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Describe the damage in detail...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                errorText: context.read<ReliefRequestBloc>().state is ReliefInvalid
                    ? (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['damageDescription']
                    : null,
              ),
              onChanged: (value) {
                context.read<ReliefRequestBloc>().add(UpdateDamageDescription(value));
              },
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Estimated loss amount field
            Text(
              'Estimated Loss Amount',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '0',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                errorText: context.read<ReliefRequestBloc>().state is ReliefInvalid
                    ? (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['lossAmount']
                    : null,
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                context.read<ReliefRequestBloc>().add(UpdateLossAmount(amount));
              },
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Bank details section
            Text(
              'Bank Details',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Account holder name
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Account Holder Name',
                      hintText: 'Enter full name as per bank records',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: context.read<ReliefRequestBloc>().state is ReliefInvalid
                          ? (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['accountHolder']
                          : null,
                    ),
                    onChanged: (value) {
                      _updateBankDetails(context, state, accountHolder: value);
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Account number
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      hintText: 'Enter account number',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: context.read<ReliefRequestBloc>().state is ReliefInvalid
                          ? (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['accountNumber']
                          : null,
                    ),
                    onChanged: (value) {
                      _updateBankDetails(context, state, accountNumber: value);
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // IFSC code
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'IFSC Code',
                            hintText: 'e.g. SBIN0001234',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            errorText: context.read<ReliefRequestBloc>().state is ReliefInvalid
                                ? (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['ifscCode']
                                : null,
                            suffixIcon: state.isLookingUpBank
                                ? Padding(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            _updateBankDetails(context, state, ifscCode: value.toUpperCase());
                            if (value.length >= 11) {
                              context.read<ReliefRequestBloc>().add(LookupBankFromIFSC(value.toUpperCase()));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  if (state.bankDetails.bankName.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${state.bankDetails.bankName} - ${state.bankDetails.branch}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Document upload section
            Text(
              'Supporting Documents',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (context.read<ReliefRequestBloc>().state is ReliefInvalid && 
                (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors.containsKey('documents'))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['documents']!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDocumentUpload(
                  context,
                  state,
                  'id_proof',
                  'ID Proof',
                  state.documents['id_proof'],
                  context.read<ReliefRequestBloc>().state is ReliefInvalid
                      ? (context.read<ReliefRequestBloc>().state as ReliefInvalid).fieldErrors['id_proof']
                      : null,
                ),
                _buildDocumentUpload(
                  context,
                  state,
                  'property_document',
                  'Property Document',
                  state.documents['property_document'],
                  null,
                ),
                _buildDocumentUpload(
                  context,
                  state,
                  'damage_photo',
                  'Damage Photo',
                  state.documents['damage_photo'],
                  null,
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Center(child: Text('Something went wrong'));
  }

  Widget _buildDocumentUpload(
    BuildContext context,
    ReliefValid state,
    String type,
    String label,
    File? file,
    String? errorText,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<File?>(
              context: context,
              builder: (context) => DocumentSourceSheet(),
            );
            
            if (result != null) {
              context.read<ReliefRequestBloc>().add(
                UploadDocument(documentType: type, file: result),
              );
            }
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null
                    ? Colors.red
                    : file != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                width: 1,
                style: file != null ? BorderStyle.solid : BorderStyle.none,
              ),
              borderRadius: BorderRadius.circular(8),
              image: file != null
                  ? DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: errorText != null
                            ? Colors.red
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tap to Upload',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: errorText != null
                              ? Colors.red
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            context.read<ReliefRequestBloc>().add(
                              RemoveDocument(type),
                            );
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: errorText != null ? Colors.red : null,
          ),
        ),
        if (errorText != null)
          Text(
            errorText,
            style: TextStyle(
              color: Colors.red,
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ReliefValid state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: state.canProceed
                  ? () {
                      context.read<ReliefRequestBloc>().add(const ValidateAndProceed());
                      
                      // Create relief request object
                      final reliefRequest = ReliefRequest(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        description: state.damageDescription,
                        damageValue: state.lossAmount,
                        bankDetails: BankDetails(
                          accountHolder: state.bankDetails.accountHolder,
                          accountNumber: state.bankDetails.accountNumber,
                          ifscCode: state.bankDetails.ifscCode,
                          bankName: state.bankDetails.bankName,
                          branch: state.bankDetails.branch,
                        ),
                        documents: state.documents,
                        status: ReliefRequestStatus.pending,
                        createdAt: DateTime.now(),
                      );
                      
                      // Navigate to final review screen
                      context.go('/report-issue/review', extra: {
                        'media': capturedMedia,
                        'category': category,
                        'description': description,
                        'severity': severity,
                        'latitude': latitude,
                        'longitude': longitude,
                        'address': address,
                        'reliefRequest': reliefRequest,
                      });
                    }
                  : null,
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to update bank details
  void _updateBankDetails(BuildContext context, ReliefValid state, {
    String? accountHolder,
    String? accountNumber,
    String? ifscCode,
  }) {
    context.read<ReliefRequestBloc>().add(
      UpdateBankDetails(
        accountHolder: accountHolder ?? state.bankDetails.accountHolder,
        accountNumber: accountNumber ?? state.bankDetails.accountNumber,
        ifscCode: ifscCode ?? state.bankDetails.ifscCode,
      ),
    );
  }
}
