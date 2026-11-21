import 'package:equatable/equatable.dart';

import 'faction.dart';
import 'slot_state.dart';

class PlayerState extends Equatable {
  const PlayerState({
    required this.faction,
    required this.slots,
    this.kills = 0,
  });

  factory PlayerState.newPlayer(Faction faction) {
    return PlayerState(
      faction: faction,
      slots: List<SlotState>.generate(6, (_) => const SlotState.empty()),
    );
  }

  final Faction faction;
  final List<SlotState> slots;
  final int kills;

  bool get isOut => slots.every((slot) => slot.isDestroyed);

  int get soldiersLost => slots.where((slot) => slot.isDestroyed).length;

  PlayerState withSlot(int index, SlotState slot) {
    final updated = List<SlotState>.of(slots)..[index] = slot;
    return PlayerState(faction: faction, slots: updated, kills: kills);
  }

  PlayerState withKill() {
    return PlayerState(faction: faction, slots: slots, kills: kills + 1);
  }

  @override
  List<Object?> get props => [faction, slots, kills];
}
