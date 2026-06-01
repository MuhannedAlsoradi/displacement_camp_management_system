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

// Notifications ← جديد
class NotificationsSuccessState extends AppStates {}
