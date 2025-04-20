// leaf_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeafState {
  final int currentLeaf;
  final int totalLeaves;
  LeafState({required this.currentLeaf, required this.totalLeaves});
}

class LeafCubit extends Cubit<LeafState> {
  static const _prefsKey = 'last_read_leaf';

  LeafCubit() : super(LeafState(currentLeaf: 0, totalLeaves: 1));

  /// Call this once you know how many leaves there are.
  /// It will load the saved leaf (if any), clamp it in range, and emit.
  Future<void> init(int totalLeaves) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefsKey) ?? 0;
    final clamped = saved.clamp(0, totalLeaves - 1);
    emit(LeafState(currentLeaf: clamped, totalLeaves: totalLeaves));
  }

  /// Updates the current leaf and writes it to prefs.
  void setLeaf(int leafIndex) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_prefsKey, leafIndex);
    });
    emit(LeafState(currentLeaf: leafIndex, totalLeaves: state.totalLeaves));
  }
}
