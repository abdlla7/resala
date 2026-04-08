import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @modernGreen.
  ///
  /// In en, this message translates to:
  /// **'Modern Green'**
  String get modernGreen;

  /// No description provided for @classicBlue.
  ///
  /// In en, this message translates to:
  /// **'Classic Blue'**
  String get classicBlue;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @downloadOffline.
  ///
  /// In en, this message translates to:
  /// **'Download for Offline'**
  String get downloadOffline;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssue;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @fieldCoordinator.
  ///
  /// In en, this message translates to:
  /// **'Academic Tutor'**
  String get fieldCoordinator;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get courses;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Academic Stats'**
  String get stats;

  /// No description provided for @volunteerHub.
  ///
  /// In en, this message translates to:
  /// **'STUDYHUB'**
  String get volunteerHub;

  /// No description provided for @resala.
  ///
  /// In en, this message translates to:
  /// **'Academic Excellence'**
  String get resala;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Master your subjects with ease. Your journey to academic success starts right here.'**
  String get welcomeMessage;

  /// No description provided for @expertTraining.
  ///
  /// In en, this message translates to:
  /// **'Top-Rated Tutors'**
  String get expertTraining;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Student Forum'**
  String get community;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String hi(Object name);

  /// No description provided for @fieldReadyVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Top Student'**
  String get fieldReadyVolunteer;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Learning Progress'**
  String get overallProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @motivationMessage.
  ///
  /// In en, this message translates to:
  /// **'Excellent work! Keep going to ace your upcoming exams.'**
  String get motivationMessage;

  /// No description provided for @learningPaths.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get learningPaths;

  /// No description provided for @disasterRelief.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get disasterRelief;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume Lesson'**
  String get resume;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @remainingModules.
  ///
  /// In en, this message translates to:
  /// **'{count} topics remaining'**
  String remainingModules(Object count);

  /// No description provided for @communityTeaching.
  ///
  /// In en, this message translates to:
  /// **'English Language'**
  String get communityTeaching;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Topic'**
  String get startLearning;

  /// No description provided for @logisticsSupply.
  ///
  /// In en, this message translates to:
  /// **'World History'**
  String get logisticsSupply;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get enterEmailPassword;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrongPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get invalidEmail;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(Object error);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @readyToContinue.
  ///
  /// In en, this message translates to:
  /// **'Ready to continue your studies?'**
  String get readyToContinue;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New student? '**
  String get newHere;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get createAccount;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too easy to guess.'**
  String get weakPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email.'**
  String get emailAlreadyInUse;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the Academy'**
  String get joinCommunity;

  /// No description provided for @joinCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Study, collaborate, and reach your goals together.'**
  String get joinCommunitySubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @orSignUpWithEmail.
  ///
  /// In en, this message translates to:
  /// **'OR REGISTER WITH EMAIL'**
  String get orSignUpWithEmail;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Abdallah Ahmed'**
  String get namePlaceholder;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailPlaceholder;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordPlaceholder;

  /// No description provided for @startVolunteering.
  ///
  /// In en, this message translates to:
  /// **'Enroll Now'**
  String get startVolunteering;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @learningPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Plan'**
  String get learningPathTitle;

  /// No description provided for @volunteerTrack.
  ///
  /// In en, this message translates to:
  /// **'Academic Track'**
  String get volunteerTrack;

  /// No description provided for @disasterReliefBasics.
  ///
  /// In en, this message translates to:
  /// **'Calculus & Algebra'**
  String get disasterReliefBasics;

  /// No description provided for @disasterReliefDescription.
  ///
  /// In en, this message translates to:
  /// **'Building a strong foundation in advanced mathematics and problem-solving techniques.'**
  String get disasterReliefDescription;

  /// No description provided for @levelsComplete.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} Topics Complete'**
  String levelsComplete(Object completed, Object total);

  /// No description provided for @orientation.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get orientation;

  /// No description provided for @orientationDesc.
  ///
  /// In en, this message translates to:
  /// **'Overview of the curriculum and learning objectives.'**
  String get orientationDesc;

  /// No description provided for @safetyProtocols.
  ///
  /// In en, this message translates to:
  /// **'Grammar & Vocabulary'**
  String get safetyProtocols;

  /// No description provided for @safetyProtocolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Mastering the essentials of the English language.'**
  String get safetyProtocolsDesc;

  /// No description provided for @engagingCommunity.
  ///
  /// In en, this message translates to:
  /// **'Historical Analysis'**
  String get engagingCommunity;

  /// No description provided for @engagingCommunityDesc.
  ///
  /// In en, this message translates to:
  /// **'Understanding the events that shaped our modern world.'**
  String get engagingCommunityDesc;

  /// No description provided for @crisisCommunication.
  ///
  /// In en, this message translates to:
  /// **'Exam Preparation'**
  String get crisisCommunication;

  /// No description provided for @crisisCommunicationDesc.
  ///
  /// In en, this message translates to:
  /// **'Key strategies for solving complex problems under time pressure.'**
  String get crisisCommunicationDesc;

  /// No description provided for @fieldDeployment.
  ///
  /// In en, this message translates to:
  /// **'Final Assessment'**
  String get fieldDeployment;

  /// No description provided for @fieldDeploymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive final exam to validate your knowledge.'**
  String get fieldDeploymentDesc;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT TOPIC'**
  String get currentLevel;

  /// No description provided for @levelN.
  ///
  /// In en, this message translates to:
  /// **'TOPIC {level}'**
  String levelN(Object level);

  /// No description provided for @resumeLearning.
  ///
  /// In en, this message translates to:
  /// **'Resume Study'**
  String get resumeLearning;

  /// No description provided for @fieldSafetyBasics.
  ///
  /// In en, this message translates to:
  /// **'Language Skills'**
  String get fieldSafetyBasics;

  /// No description provided for @lesson3.
  ///
  /// In en, this message translates to:
  /// **'LESSON 3'**
  String get lesson3;

  /// No description provided for @lessonBody.
  ///
  /// In en, this message translates to:
  /// **'Focus on consistent practice and critical thinking. Success in any subject comes from understanding the logic behind the facts.'**
  String get lessonBody;

  /// No description provided for @quickTips.
  ///
  /// In en, this message translates to:
  /// **'Study Tips'**
  String get quickTips;

  /// No description provided for @doKey.
  ///
  /// In en, this message translates to:
  /// **'DO'**
  String get doKey;

  /// No description provided for @doTip.
  ///
  /// In en, this message translates to:
  /// **'Review your notes regularly and ask questions when a concept isn\'t clear.'**
  String get doTip;

  /// No description provided for @dontKey.
  ///
  /// In en, this message translates to:
  /// **'DON\'T'**
  String get dontKey;

  /// No description provided for @dontTip.
  ///
  /// In en, this message translates to:
  /// **'Skip the practice exercises; they are key to mastering the material.'**
  String get dontTip;

  /// No description provided for @completeLevel.
  ///
  /// In en, this message translates to:
  /// **'Complete Topic'**
  String get completeLevel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
