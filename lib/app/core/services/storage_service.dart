import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

/// Simple Storage Service for organization data only
class StorageService extends GetxService {

  static StorageService get to => Get.find();

  late GetStorage _box;

  // Storage Keys
  static const String _organizationNameKey = 'organization_name';
  static const String _organizationAddressKey = 'organization_address';
  static const String _userNameKey = 'user_name';

  /// Initialize storage service
  Future<StorageService> init() async {
    developer.log('Initializing Storage Service', name: 'StorageService');

    await GetStorage.init('app_storage');
    _box = GetStorage('app_storage');

    developer.log('Storage Service initialized', name: 'StorageService');
    return this;
  }

  /// Store organization data - call after successful login
  void storeOrganizationData({
    required String organizationName,
    required String organizationAddress,
    required String userName,
  }) {
    try {
      _box.write(_organizationNameKey, organizationName);
      _box.write(_organizationAddressKey, organizationAddress);
      _box.write(_userNameKey, userName);

      developer.log('Organization data stored: $organizationName', name: 'StorageService');
    } catch (e) {
      developer.log('Failed to store organization data: $e', name: 'StorageService');
    }
  }

  /// Get organization name - call to restore after hot reload
  String getOrganizationName() {
    try {
      final name = _box.read(_organizationNameKey) ?? 'Hotel Name';
      return name;
    } catch (e) {
      developer.log('Failed to get organization name: $e', name: 'StorageService');
      return 'Hotel Name';
    }
  }

  /// Get organization address - call to restore after hot reload
  String getOrganizationAddress() {
    try {
      final address = _box.read(_organizationAddressKey) ?? 'Hotel Address';
      return address;
    } catch (e) {
      developer.log('Failed to get organization address: $e', name: 'StorageService');
      return 'Hotel Address';
    }
  }

  String getUserName() {
    try {
      final userName = _box.read(_userNameKey) ?? 'raju';
      return userName;
    } catch (e) {
      developer.log('Failed to get organization address: $e', name: 'StorageService');
      return 'Hotel Address';
    }
  }

  /// Clear organization data - call on logout
  void clearOrganizationData() {
    try {
      _box.remove(_organizationNameKey);
      _box.remove(_organizationAddressKey);
      _box.remove(_userNameKey);

      developer.log('Organization data cleared', name: 'StorageService');
    } catch (e) {
      developer.log('Failed to clear organization data: $e', name: 'StorageService');
    }
  }
}