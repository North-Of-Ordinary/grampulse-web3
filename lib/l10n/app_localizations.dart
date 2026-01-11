import 'package:flutter/material.dart';

// Extension on BuildContext to provide localized strings
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Class that holds all the localized strings
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? 
           AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = {
    'en': {
      // General
      'all': 'All',
      'navigate': 'Navigate',
      'viewDetails': 'View Details',
      'pending': 'Pending',
      'inProgress': 'In Progress',
      'resolved': 'Resolved',
      'rejected': 'Rejected',
      'unknownLocation': 'Unknown Location',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'minutesAgo': '{} mins ago',
      'hoursAgo': '{} hours ago',
      'daysAgo': '{} days ago',
      
      // Status labels
      'new_': 'New',
      'assigned': 'Assigned',
      'closed': 'Closed',
      'status': 'Status',
      
      // Filter and sort
      'category': 'Category',
      'slaStatus': 'SLA Status',
      'slaBreached': 'SLA Breached',
      'slaAtRisk': 'At Risk',
      'slaOnTrack': 'On Track',
      'dateRange': 'Date Range',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'resetFilters': 'Reset',
      'applyFilters': 'Apply',
      
      // Officer module
      'incidentInbox': 'Incident Inbox',
      'selectedCount': 'Selected: {}',
      'clearSelection': 'Clear Selection',
      'batchActions': 'Batch Actions',
      'assignSelected': 'Assign Selected',
      'updateStatus': 'Update Status',
      'exportData': 'Export Data',
      'actions': 'Actions',
      'sla': 'SLA',
      'title': 'Title',
      
      // SLA time formatting
      'daysOverdue': '{}d overdue',
      'hoursOverdue': '{}h overdue',
      'daysRemaining': '{}d left',
      'hoursRemaining': '{}h left',
      
      // Map Screen
      'nearbyIssues': 'Nearby Issues',
      'mapView': 'Map View',
      'listView': 'List View',
      'filterIssues': 'Filter Issues',
      'noIssuesFound': 'No issues found in this area',
      'sortBy': 'Sort by',
      'nearestFirst': 'Nearest First',
      'oldestFirst': 'Oldest First',
      'priority': 'Priority',
      
      // Bottom Sheet
      'addPhoto': 'Add Photo',
      'noPhotosAdded': 'No photos added',
      
      // Volunteer - Assist Citizen
      'assistCitizen': 'Assist a Citizen',
      'howToAssist': 'How to assist a citizen',
      'assistStep1': '1. Explain the purpose of the GramPulse app to the citizen.',
      'assistStep2': '2. Get their consent to report an issue on their behalf.',
      'assistStep3': '3. Collect their phone number and name to associate with the report.',
      'assistStep4': '4. Complete the report with all necessary details and media.',
      'citizenDetails': 'Citizen Details',
      'citizenPhone': 'Phone Number',
      'phoneHint': '10-digit mobile number',
      'citizenPhoneHelper': 'Enter 10-digit mobile number without country code',
      'recentlyAssisted': 'Recently Assisted',
      'citizenName': 'Full Name',
      'nameHint': 'Citizen\'s full name',
      'citizenConsentText': 'I confirm that I have obtained the citizen\'s verbal consent to report an issue on their behalf and to use their contact information for this purpose.',
      'continueToReport': 'Continue to Report Issue',
      'speakPhoneNumber': 'Speak phone number',
      'enterValidPhone': 'Please enter a valid 10-digit phone number',
      'enterValidName': 'Please enter the citizen\'s name',
    },
    // Add more languages here
  };

  String get all => _localizedValues[locale.languageCode]?['all'] ?? 'All';
  String get navigate => _localizedValues[locale.languageCode]?['navigate'] ?? 'Navigate';
  String get viewDetails => _localizedValues[locale.languageCode]?['viewDetails'] ?? 'View Details';
  String get pending => _localizedValues[locale.languageCode]?['pending'] ?? 'Pending';
  String get inProgress => _localizedValues[locale.languageCode]?['inProgress'] ?? 'In Progress';
  String get resolved => _localizedValues[locale.languageCode]?['resolved'] ?? 'Resolved';
  String get rejected => _localizedValues[locale.languageCode]?['rejected'] ?? 'Rejected';
  String get unknownLocation => _localizedValues[locale.languageCode]?['unknownLocation'] ?? 'Unknown Location';
  String get low => _localizedValues[locale.languageCode]?['low'] ?? 'Low';
  String get medium => _localizedValues[locale.languageCode]?['medium'] ?? 'Medium';
  String get high => _localizedValues[locale.languageCode]?['high'] ?? 'High';

  // Status labels
  String get new_ => _localizedValues[locale.languageCode]?['new_'] ?? 'New';
  String get assigned => _localizedValues[locale.languageCode]?['assigned'] ?? 'Assigned';
  String get closed => _localizedValues[locale.languageCode]?['closed'] ?? 'Closed';
  String get status => _localizedValues[locale.languageCode]?['status'] ?? 'Status';
  
  // Filter and sort
  String get category => _localizedValues[locale.languageCode]?['category'] ?? 'Category';
  String get slaStatus => _localizedValues[locale.languageCode]?['slaStatus'] ?? 'SLA Status';
  String get slaBreached => _localizedValues[locale.languageCode]?['slaBreached'] ?? 'SLA Breached';
  String get slaAtRisk => _localizedValues[locale.languageCode]?['slaAtRisk'] ?? 'At Risk';
  String get slaOnTrack => _localizedValues[locale.languageCode]?['slaOnTrack'] ?? 'On Track';
  String get dateRange => _localizedValues[locale.languageCode]?['dateRange'] ?? 'Date Range';
  String get startDate => _localizedValues[locale.languageCode]?['startDate'] ?? 'Start Date';
  String get endDate => _localizedValues[locale.languageCode]?['endDate'] ?? 'End Date';
  String get resetFilters => _localizedValues[locale.languageCode]?['resetFilters'] ?? 'Reset';
  String get applyFilters => _localizedValues[locale.languageCode]?['applyFilters'] ?? 'Apply';
  
  // Officer module
  String get incidentInbox => _localizedValues[locale.languageCode]?['incidentInbox'] ?? 'Incident Inbox';
  String get selectedCount => _localizedValues[locale.languageCode]?['selectedCount'] ?? 'Selected: {}';
  String get clearSelection => _localizedValues[locale.languageCode]?['clearSelection'] ?? 'Clear Selection';
  String get batchActions => _localizedValues[locale.languageCode]?['batchActions'] ?? 'Batch Actions';
  String get assignSelected => _localizedValues[locale.languageCode]?['assignSelected'] ?? 'Assign Selected';
  String get updateStatus => _localizedValues[locale.languageCode]?['updateStatus'] ?? 'Update Status';
  String get exportData => _localizedValues[locale.languageCode]?['exportData'] ?? 'Export Data';
  String get actions => _localizedValues[locale.languageCode]?['actions'] ?? 'Actions';
  String get sla => _localizedValues[locale.languageCode]?['sla'] ?? 'SLA';
  String get title => _localizedValues[locale.languageCode]?['title'] ?? 'Title';
  
  // SLA time formatting
  String daysOverdue(int days) => (_localizedValues[locale.languageCode]?['daysOverdue'] ?? '{}d overdue').replaceAll('{}', days.toString());
  String hoursOverdue(int hours) => (_localizedValues[locale.languageCode]?['hoursOverdue'] ?? '{}h overdue').replaceAll('{}', hours.toString());
  String daysRemaining(int days) => (_localizedValues[locale.languageCode]?['daysRemaining'] ?? '{}d left').replaceAll('{}', days.toString());
  String hoursRemaining(int hours) => (_localizedValues[locale.languageCode]?['hoursRemaining'] ?? '{}h left').replaceAll('{}', hours.toString());
  String get nearbyIssues => _localizedValues[locale.languageCode]?['nearbyIssues'] ?? 'Nearby Issues';
  String get mapView => _localizedValues[locale.languageCode]?['mapView'] ?? 'Map View';
  String get listView => _localizedValues[locale.languageCode]?['listView'] ?? 'List View';
  String get filterIssues => _localizedValues[locale.languageCode]?['filterIssues'] ?? 'Filter Issues';
  String get noIssuesFound => _localizedValues[locale.languageCode]?['noIssuesFound'] ?? 'No issues found in this area';
  String get sortBy => _localizedValues[locale.languageCode]?['sortBy'] ?? 'Sort by';
  String get nearestFirst => _localizedValues[locale.languageCode]?['nearestFirst'] ?? 'Nearest First';
  String get oldestFirst => _localizedValues[locale.languageCode]?['oldestFirst'] ?? 'Oldest First';
  String get priority => _localizedValues[locale.languageCode]?['priority'] ?? 'Priority';
  String get addPhoto => _localizedValues[locale.languageCode]?['addPhoto'] ?? 'Add Photo';
  String get noPhotosAdded => _localizedValues[locale.languageCode]?['noPhotosAdded'] ?? 'No photos added';
  
  // Volunteer - Assist Citizen
  String get assistCitizen => _localizedValues[locale.languageCode]?['assistCitizen'] ?? 'Assist a Citizen';
  String get howToAssist => _localizedValues[locale.languageCode]?['howToAssist'] ?? 'How to assist a citizen';
  String get assistStep1 => _localizedValues[locale.languageCode]?['assistStep1'] ?? '1. Explain the purpose of the app to the citizen.';
  String get assistStep2 => _localizedValues[locale.languageCode]?['assistStep2'] ?? '2. Get their consent to report an issue on their behalf.';
  String get assistStep3 => _localizedValues[locale.languageCode]?['assistStep3'] ?? '3. Collect their phone number and name to associate with the report.';
  String get assistStep4 => _localizedValues[locale.languageCode]?['assistStep4'] ?? '4. Complete the report with all necessary details and media.';
  String get citizenDetails => _localizedValues[locale.languageCode]?['citizenDetails'] ?? 'Citizen Details';
  String get citizenPhone => _localizedValues[locale.languageCode]?['citizenPhone'] ?? 'Phone Number';
  String get phoneHint => _localizedValues[locale.languageCode]?['phoneHint'] ?? '10-digit mobile number';
  String get citizenPhoneHelper => _localizedValues[locale.languageCode]?['citizenPhoneHelper'] ?? 'Enter 10-digit mobile number without country code';
  String get recentlyAssisted => _localizedValues[locale.languageCode]?['recentlyAssisted'] ?? 'Recently Assisted';
  String get citizenName => _localizedValues[locale.languageCode]?['citizenName'] ?? 'Full Name';
  String get nameHint => _localizedValues[locale.languageCode]?['nameHint'] ?? 'Citizen\'s full name';
  String get citizenConsentText => _localizedValues[locale.languageCode]?['citizenConsentText'] ?? 'I confirm that I have obtained the citizen\'s verbal consent to report an issue on their behalf and to use their contact information for this purpose.';
  String get continueToReport => _localizedValues[locale.languageCode]?['continueToReport'] ?? 'Continue to Report Issue';
  String get speakPhoneNumber => _localizedValues[locale.languageCode]?['speakPhoneNumber'] ?? 'Speak phone number';
  String get enterValidPhone => _localizedValues[locale.languageCode]?['enterValidPhone'] ?? 'Please enter a valid 10-digit phone number';
  String get enterValidName => _localizedValues[locale.languageCode]?['enterValidName'] ?? 'Please enter the citizen\'s name';

  String minutesAgo(int minutes) {
    return (_localizedValues[locale.languageCode]?['minutesAgo'] ?? '{} mins ago').replaceAll('{}', minutes.toString());
  }

  String hoursAgo(int hours) {
    return (_localizedValues[locale.languageCode]?['hoursAgo'] ?? '{} hours ago').replaceAll('{}', hours.toString());
  }

  String daysAgo(int days) {
    return (_localizedValues[locale.languageCode]?['daysAgo'] ?? '{} days ago').replaceAll('{}', days.toString());
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
