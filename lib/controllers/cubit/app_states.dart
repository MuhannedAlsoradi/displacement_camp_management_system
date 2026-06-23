abstract class AppStates {}

class InitState extends AppStates {}

class ChangeCurrentIndexState extends AppStates {}

// Auth
class LoginLoadingState extends AppStates {}

class LoginSuccessState extends AppStates {}

class LoginErrorState extends AppStates {
  final String error;
  LoginErrorState(this.error);
}

class LogoutSuccessState extends AppStates {}

// Camps
class CampsLoadingState extends AppStates {}

class CampsSuccessState extends AppStates {}

class CampsErrorState extends AppStates {
  final String error;
  CampsErrorState(this.error);
}

class AddCampLoadingState extends AppStates {}

class AddCampSuccessState extends AppStates {}

class AddCampErrorState extends AppStates {
  final String error;
  AddCampErrorState(this.error);
}

class DeleteCampSuccessState extends AppStates {}

class DeleteCampErrorState extends AppStates {
  final String error;
  DeleteCampErrorState(this.error);
}

class UpdateCampSuccessState extends AppStates {}

// Displaced Persons
class DisplacedLoadingState extends AppStates {}

class DisplacedSuccessState extends AppStates {}

class DisplacedErrorState extends AppStates {
  final String error;
  DisplacedErrorState(this.error);
}

class AddDisplacedSuccessState extends AppStates {}

class AddDisplacedLoadingState extends AppStates {}

class AddDisplacedErrorState extends AppStates {
  final String error;
  AddDisplacedErrorState(this.error);
}

class DeleteFamilySuccessState extends AppStates {}

class DeleteFamilyErrorState extends AppStates {
  final String error;
  DeleteFamilyErrorState(this.error);
}

// Dashboard
class DashboardLoadingState extends AppStates {}

class DashboardSuccessState extends AppStates {}

class DashboardErrorState extends AppStates {
  final String error;
  DashboardErrorState(this.error);
}

// Storage
class UploadFileLoadingState extends AppStates {}

class UploadFileSuccessState extends AppStates {
  final String url;
  UploadFileSuccessState(this.url);
}

class UploadFileErrorState extends AppStates {
  final String error;
  UploadFileErrorState(this.error);
}

// Sync (Volunteer offline → online)
class SyncLoadingState extends AppStates {}

class SyncSuccessState extends AppStates {}

class SyncErrorState extends AppStates {
  final String error;
  SyncErrorState(this.error);
}

// IDP Family
class IdpFamilyLoadingState extends AppStates {}

class IdpFamilySuccessState extends AppStates {}

class IdpFamilyErrorState extends AppStates {
  final String error;
  IdpFamilyErrorState(this.error);
}

// Notifications
class NotificationsSuccessState extends AppStates {}

// Tents
class TentActionLoadingState extends AppStates {}

class TentActionSuccessState extends AppStates {
  final String message;
  TentActionSuccessState(this.message);
}

class TentActionErrorState extends AppStates {
  final String error;
  TentActionErrorState(this.error);
}

// Resources / Aid Types
class ResourcesSuccessState extends AppStates {}

class ResourcesErrorState extends AppStates {
  final String error;
  ResourcesErrorState(this.error);
}

class ResourceActionLoadingState extends AppStates {}

class ResourceActionSuccessState extends AppStates {
  final String message;
  ResourceActionSuccessState(this.message);
}

class ResourceActionErrorState extends AppStates {
  final String error;
  ResourceActionErrorState(this.error);
}

class AidSuccessState extends AppStates {}

class ConnectivityChangedState extends AppStates {
  final bool isOnline;
  ConnectivityChangedState(this.isOnline);
}

class SyncStatusChangedState extends AppStates {
  final bool hasPendingWrites;
  SyncStatusChangedState(this.hasPendingWrites);
}
