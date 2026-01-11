import 'dart:async';

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Common strings
  String get appName => 'GramPulse';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get delete => 'Delete';
  String get edit => 'Edit';
  String get submit => 'Submit';
  String get back => 'Back';
  String get next => 'Next';
  String get done => 'Done';
  String get ok => 'OK';
  String get yes => 'Yes';
  String get no => 'No';
  String get loading => 'Loading...';
  String get tryAgain => 'Try Again';
  String get refresh => 'Refresh';
  String get error => 'Error';
  String get search => 'Search';
  String get filter => 'Filter';
  String get sort => 'Sort';
  String get clearSelection => 'Clear Selection';
  String get selectStatus => 'Select Status';
  String get noData => 'No data available';
  String get noResultsFound => 'No results found';
  String get settings => 'Settings';
  String get profile => 'Profile';
  
  // Officer Module Strings
  String get officerDashboard => 'Officer Dashboard';
  String get incidentInbox => 'Incident Inbox';
  String get incidentDetails => 'Incident Details';
  String get noIncidents => 'No incidents available';
  String get toggleFilters => 'Toggle Filters';
  String get switchToList => 'Switch to List View';
  String get waitingForData => 'Waiting for data...';
  String errorLoadingIncident(String message) => 'Error loading incident: $message';
  String get addComment => 'Add Comment';
  String get description => 'Description';
  String get location => 'Location';
  String get reportedBy => 'Reported by';
  String dateReported(String date) => 'Date reported: $date';
  String get attachedPhotos => 'Attached Photos';
  String get timeline => 'Timeline';
  String get title => 'Title';
  String get fieldRequired => 'This field is required';
  String get assignTo => 'Assign to';
  String get dueDate => 'Due Date';
  String get create => 'Create';
  String get update => 'Update';
  String get enterComment => 'Enter your comment';
  String get add => 'Add';
  String get switchToKanban => 'Switch to Kanban View';
  
  // Issue Status
  String get issueStatusOpen => 'Open';
  String get issueStatusInProgress => 'In Progress';
  String get issueStatusAssigned => 'Assigned';
  String get issueStatusResolved => 'Resolved';
  String get issueStatusClosed => 'Closed';
  String get issueStatusReopened => 'Reopened';
  
  // Status text for incident details
  String get statusOpen => 'Open';
  String get statusAssigned => 'Assigned';
  String get statusInProgress => 'In Progress';
  String get statusResolved => 'Resolved';
  String get statusRejected => 'Rejected';
  String get statusCancelled => 'Cancelled';
  String get statusComment => 'Comment';
  String get pending => 'Pending';
  
  // Issue Status Labels for Details Screen
  String get resolved => 'Resolved';
  String get closed => 'Closed';
  
  // Priority Levels
  String get priorityLow => 'Low';
  String get priorityMedium => 'Medium';
  String get priorityHigh => 'High';
  String get priorityCritical => 'Critical';
  
  // Filter Panel
  String get filterByStatus => 'Filter by Status';
  String get filterByCategory => 'Filter by Category';
  String get filterBySLA => 'Filter by SLA';
  String get filterByDate => 'Filter by Date';
  String get allCategories => 'All Categories';
  String get allStatuses => 'All Statuses';
  String get overdueSLA => 'Overdue SLA';
  String get withinSLA => 'Within SLA';
  String get anySLA => 'Any SLA';
  String get startDate => 'Start Date';
  String get endDate => 'End Date';
  String get applyFilters => 'Apply Filters';
  String get resetFilters => 'Reset Filters';
  
  // Batch Actions
  String get selectedCount => 'Selected: {}';
  String get assignSelected => 'Assign Selected';
  String get updateStatus => 'Update Status';
  String get exportData => 'Export Data';
  String get batchActions => 'Batch Actions';
  
  // Table Column Headers
  String get columnId => 'ID';
  String get columnTitle => 'Title';
  String get columnCategory => 'Category';
  String get columnStatus => 'Status';
  String get columnPriority => 'Priority';
  String get columnDateReported => 'Reported';
  String get columnSLA => 'SLA';
  String get columnLocation => 'Location';
  String get columnReportedBy => 'Reported By';
  String get columnAssignedTo => 'Assigned To';
  String get columnActions => 'Actions';
  
  // SLA Indicators
  String get slaOverdue => 'Overdue';
  String slaRemainingHours(int hours) => '$hours hrs remaining';
  String slaRemainingDays(int days) => '$days days remaining';
  
  // Work Order Status
  String get created => 'Created';
  String get assigned => 'Assigned';
  String get inProgress => 'In Progress';
  String get completed => 'Completed';
  String get cancelled => 'Cancelled';
  String get new_ => 'New';
  String get rejected => 'Rejected';
  
  // Resolution Evidence
  String get resolutionEvidence => 'Resolution Evidence';
  String get addEvidence => 'Add Evidence';
  String get noEvidenceYet => 'No resolution evidence has been added yet';
  String get before => 'Before';
  String get after => 'After';
  String get noImage => 'No Image';
  String moreImages(int count) => '+$count more';
  String resolvedOn(String date) => 'Resolved on $date';
  
  // Work Orders
  String get workOrders => 'Work Orders';
  String get createWorkOrder => 'Create Work Order';
  String get noWorkOrders => 'No work orders have been created yet';
  String estimatedCost(String cost) => 'Est. Cost: ₹$cost';
  
  // Assignment
  String get assignment => 'Assignment';
  String get department => 'Department';
  String get assignedTo => 'Assigned To';
  String get notAssigned => 'Not assigned yet';
  String get reassign => 'Reassign';
  String get assign => 'Assign';
  String get resolve => 'Resolve';
  String get assignTask => 'Assign Task';
  String get contact => 'Contact';
  
  // Action Panel
  String get takeAction => 'Take Action';
  String get updateIncident => 'Update Incident';
  String get changeStatus => 'Change Status';
  String get addNotes => 'Add Notes';
  String get notesHint => 'Enter any additional information or notes about this update...';
  
  // Resolution Details
  String get resolutionDetails => 'Resolution Details';
  String get resolutionNotes => 'Resolution Notes';
  String get resolutionNotesHint => 'Describe how the issue was resolved...';
  String get workDetails => 'Work Details';
  String get completedBy => 'Completed By';
  String get workOrderReference => 'Work Order Reference';
  String get actualCost => 'Actual Cost';
  String get completionDate => 'Completion Date';
  String get selectDate => 'Select Date';
  String get submitResolution => 'Submit Resolution';
  String get actionTaken => 'Action Taken';
  String get actionTakenHint => 'Enter actions taken to resolve the issue';
  String get cost => 'Cost';
  String get costHint => 'Enter the cost of resolution';
  String get confirm => 'Confirm';
  String get selectCompletionDate => 'Select Completion Date';
  String get descriptionTooShort => 'Description is too short';
  String get evidencePhotos => 'Evidence Photos';
  String get noResolutionYet => 'No resolution has been added yet';
  String get addResolution => 'Add Resolution';
  String get resolutionSubmittedSuccessfully => 'Resolution submitted successfully';
  String errorSubmittingResolution(String error) => 'Error submitting resolution: $error';
  String resolutionCost(String cost) => 'Resolution Cost: ₹$cost';
  String get addResolutionEvidence => 'Add Resolution Evidence';
  String get errorLoadingData => 'Error loading data';
  
  // Before/After Photos
  String get beforeAfterPhotos => 'Before/After Photos';
  String get reportedIssue => 'Reported Issue';
  String get resolutionPhotos => 'Resolution Photos';
  String get resolutionPhotosDesc => 'Please add photos showing the resolved issue';
  String get noPhotosProvided => 'No photos provided';
  String get addPhoto => 'Add Photo';
  String get addAfterImage => 'Add After Image';
  String get beforePhotos => 'Before Photos';
  String get afterPhotos => 'After Photos';
  String get takePhoto => 'Take Photo';
  String get chooseFromGallery => 'Choose from Gallery';
  
  // Issue Summary
  String get issueSummary => 'Issue Summary';
  String reportedOn(String date) => 'Reported on $date';
  String get unknownLocation => 'Unknown Location';
  
  // SLA Text
  String daysOverdue(int days) => '$days days overdue';
  String hoursOverdue(int hours) => '$hours hours overdue';
  String daysRemaining(int days) => '$days days remaining';
  String hoursRemaining(int hours) => '$hours hours remaining';
}

// AppLocalizationsDelegate class
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support English, Hindi, and others as needed
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Load the language JSON file from assets
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
