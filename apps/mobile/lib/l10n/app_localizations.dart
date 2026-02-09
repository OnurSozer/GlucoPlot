import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GlucoPlot'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your health measurements, log daily activities, and stay connected with your healthcare provider.'**
  String get welcomeDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @scanQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code provided by your doctor to activate your account.'**
  String get scanQrDescription;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'A verification code was sent to'**
  String get otpSentTo;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendOtp;

  /// No description provided for @invalidQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Please try again.'**
  String get invalidQrCode;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get invalidOtp;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Please request a new one.'**
  String get otpExpired;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @glucoseMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Glucose Measurement'**
  String get glucoseMeasurement;

  /// No description provided for @tapToLogReading.
  ///
  /// In en, this message translates to:
  /// **'Tap to log reading'**
  String get tapToLogReading;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @toilet.
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get toilet;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcohol;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @stress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stress;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// No description provided for @recentMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Recent Measurements'**
  String get recentMeasurements;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @lastMeasured.
  ///
  /// In en, this message translates to:
  /// **'Last measured'**
  String get lastMeasured;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @glucose.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose'**
  String get glucose;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @oxygenSaturation.
  ///
  /// In en, this message translates to:
  /// **'Oxygen (SpO2)'**
  String get oxygenSaturation;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectType;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter Value'**
  String get enterValue;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// No description provided for @measurementSaved.
  ///
  /// In en, this message translates to:
  /// **'Measurement saved'**
  String get measurementSaved;

  /// No description provided for @dailyLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Log'**
  String get dailyLog;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get entrySaved;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get networkError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @noMeasurementsYet.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurementsYet;

  /// No description provided for @addFirstMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add First Measurement'**
  String get addFirstMeasurement;

  /// No description provided for @logActivity.
  ///
  /// In en, this message translates to:
  /// **'Log Activity'**
  String get logActivity;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all your logged activities'**
  String get historySubtitle;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'logs'**
  String get logs;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'log'**
  String get log;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your health activities'**
  String get startTracking;

  /// No description provided for @addLogsFromHome.
  ///
  /// In en, this message translates to:
  /// **'Use the quick action buttons on the home page to add logs'**
  String get addLogsFromHome;

  /// No description provided for @addFirstLog.
  ///
  /// In en, this message translates to:
  /// **'Add First Log'**
  String get addFirstLog;

  /// No description provided for @swipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete'**
  String get swipeToDelete;

  /// No description provided for @logDeleted.
  ///
  /// In en, this message translates to:
  /// **'Log deleted'**
  String get logDeleted;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @whatAreYouLogging.
  ///
  /// In en, this message translates to:
  /// **'What are you logging?'**
  String get whatAreYouLogging;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get when;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @addMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Add more details...'**
  String get addMoreDetails;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @foodDetails.
  ///
  /// In en, this message translates to:
  /// **'I ate'**
  String get foodDetails;

  /// No description provided for @nutritionOptional.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (optional)'**
  String get nutritionOptional;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @sleepDetails.
  ///
  /// In en, this message translates to:
  /// **'I woke up'**
  String get sleepDetails;

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'Duration (hours)'**
  String get durationHours;

  /// No description provided for @sleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Sleep duration'**
  String get sleepDuration;

  /// No description provided for @sleepDuration2to5.
  ///
  /// In en, this message translates to:
  /// **'2-5 hrs'**
  String get sleepDuration2to5;

  /// No description provided for @sleepDuration5to7.
  ///
  /// In en, this message translates to:
  /// **'5-7 hrs'**
  String get sleepDuration5to7;

  /// No description provided for @sleepDuration7to9.
  ///
  /// In en, this message translates to:
  /// **'7-9 hrs'**
  String get sleepDuration7to9;

  /// No description provided for @sleepDuration9plus.
  ///
  /// In en, this message translates to:
  /// **'9+ hrs'**
  String get sleepDuration9plus;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @usualSleepTime.
  ///
  /// In en, this message translates to:
  /// **'Usual sleep time'**
  String get usualSleepTime;

  /// No description provided for @usualSleepTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Used for notifications and calculations'**
  String get usualSleepTimeHint;

  /// No description provided for @sleepTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sleep time updated'**
  String get sleepTimeUpdated;

  /// No description provided for @exerciseDetails.
  ///
  /// In en, this message translates to:
  /// **'I exercised'**
  String get exerciseDetails;

  /// No description provided for @durationMin.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get durationMin;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get caloriesBurned;

  /// No description provided for @exerciseDuration.
  ///
  /// In en, this message translates to:
  /// **'Exercise duration'**
  String get exerciseDuration;

  /// No description provided for @duration30min.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get duration30min;

  /// No description provided for @duration1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get duration1hour;

  /// No description provided for @duration2hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get duration2hours;

  /// No description provided for @medicationDetails.
  ///
  /// In en, this message translates to:
  /// **'I took medicine'**
  String get medicationDetails;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @waterDetails.
  ///
  /// In en, this message translates to:
  /// **'I drank water'**
  String get waterDetails;

  /// No description provided for @amountMl.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get amountMl;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get glasses;

  /// No description provided for @alcoholDetails.
  ///
  /// In en, this message translates to:
  /// **'I drank alcohol'**
  String get alcoholDetails;

  /// No description provided for @drinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get drinks;

  /// No description provided for @alcoholType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get alcoholType;

  /// No description provided for @beer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get beer;

  /// No description provided for @wine.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get wine;

  /// No description provided for @spirits.
  ///
  /// In en, this message translates to:
  /// **'Spirits'**
  String get spirits;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @alcoholAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get alcoholAmount;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @double.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get double;

  /// No description provided for @triple.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get triple;

  /// No description provided for @toiletDetails.
  ///
  /// In en, this message translates to:
  /// **'Bathroom Visit'**
  String get toiletDetails;

  /// No description provided for @toiletType.
  ///
  /// In en, this message translates to:
  /// **'Urine Amount'**
  String get toiletType;

  /// No description provided for @urination.
  ///
  /// In en, this message translates to:
  /// **'Little'**
  String get urination;

  /// No description provided for @bowelMovement.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get bowelMovement;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'A lot'**
  String get both;

  /// No description provided for @stressDetails.
  ///
  /// In en, this message translates to:
  /// **'I felt stressed'**
  String get stressDetails;

  /// No description provided for @stressLevel.
  ///
  /// In en, this message translates to:
  /// **'Level (1-10)'**
  String get stressLevel;

  /// No description provided for @triggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers (optional)'**
  String get triggers;

  /// No description provided for @hintFood.
  ///
  /// In en, this message translates to:
  /// **'e.g., Breakfast, Lunch, Snack'**
  String get hintFood;

  /// No description provided for @hintSleep.
  ///
  /// In en, this message translates to:
  /// **'e.g., Night Sleep, Nap'**
  String get hintSleep;

  /// No description provided for @hintExercise.
  ///
  /// In en, this message translates to:
  /// **'e.g., Morning Walk, Yoga'**
  String get hintExercise;

  /// No description provided for @hintMedication.
  ///
  /// In en, this message translates to:
  /// **'e.g., Metformin, Insulin'**
  String get hintMedication;

  /// No description provided for @hintWater.
  ///
  /// In en, this message translates to:
  /// **'e.g., Morning hydration'**
  String get hintWater;

  /// No description provided for @hintAlcohol.
  ///
  /// In en, this message translates to:
  /// **'e.g., Dinner wine'**
  String get hintAlcohol;

  /// No description provided for @hintToilet.
  ///
  /// In en, this message translates to:
  /// **'e.g., Morning routine'**
  String get hintToilet;

  /// No description provided for @hintStress.
  ///
  /// In en, this message translates to:
  /// **'e.g., Work deadline'**
  String get hintStress;

  /// No description provided for @quickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @orEnterCustom.
  ///
  /// In en, this message translates to:
  /// **'Or enter custom title below'**
  String get orEnterCustom;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hour ago'**
  String hoursAgo(Object hours);

  /// No description provided for @customTime.
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get customTime;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @callDoctor.
  ///
  /// In en, this message translates to:
  /// **'Call Doctor'**
  String get callDoctor;

  /// No description provided for @doctorPhone.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s Phone'**
  String get doctorPhone;

  /// No description provided for @noDoctorPhone.
  ///
  /// In en, this message translates to:
  /// **'No doctor phone number available'**
  String get noDoctorPhone;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntry;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @tapToDelete.
  ///
  /// In en, this message translates to:
  /// **'Tap to delete'**
  String get tapToDelete;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent Entries'**
  String get recentEntries;

  /// No description provided for @noRecentEntries.
  ///
  /// In en, this message translates to:
  /// **'No recent entries'**
  String get noRecentEntries;

  /// No description provided for @usedRecently.
  ///
  /// In en, this message translates to:
  /// **'Used recently'**
  String get usedRecently;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaq;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @managePreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences'**
  String get managePreferences;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @pleaseEnterValidDiastolic.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid diastolic value'**
  String get pleaseEnterValidDiastolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @whenMeasured.
  ///
  /// In en, this message translates to:
  /// **'When was this measured?'**
  String get whenMeasured;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any notes about this measurement...'**
  String get notesHint;

  /// No description provided for @bloodGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose'**
  String get bloodGlucose;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
