import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitState()) {}
  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeCurrentIndexState());
  }
}
