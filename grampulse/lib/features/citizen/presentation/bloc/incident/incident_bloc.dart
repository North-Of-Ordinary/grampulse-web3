import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/citizen/domain/repositories/incident_repository.dart';
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_event.dart';
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository _repository;

  IncidentBloc({IncidentRepository? repository})
      : _repository = repository ?? IncidentRepository(),
        super(IncidentInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadMyIncidents>(_onLoadMyIncidents);
    on<LoadNearbyIncidents>(_onLoadNearbyIncidents);
    on<LoadStatistics>(_onLoadStatistics);
    on<CreateIncident>(_onCreateIncident);
    on<RefreshIncidents>(_onRefreshIncidents);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      if (state is! IncidentLoaded) {
        emit(IncidentLoading());
      }

      final categories = await _repository.getCategories();
      
      if (state is IncidentLoaded) {
        emit((state as IncidentLoaded).copyWith(categories: categories));
      } else {
        emit(IncidentLoaded(categories: categories));
      }
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  Future<void> _onLoadMyIncidents(
    LoadMyIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      if (state is! IncidentLoaded) {
        emit(IncidentLoading());
      }

      final myIncidents = await _repository.getMyIncidents();
      
      if (state is IncidentLoaded) {
        emit((state as IncidentLoaded).copyWith(myIncidents: myIncidents));
      } else {
        emit(IncidentLoaded(myIncidents: myIncidents));
      }
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  Future<void> _onLoadNearbyIncidents(
    LoadNearbyIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      if (state is! IncidentLoaded) {
        emit(IncidentLoading());
      }

      // For citizen dashboard, get ALL incidents (not filtering by location)
      // This ensures nearby issues count matches the statistics
      final nearbyIncidents = await _repository.getNearbyIncidents(
        latitude: event.latitude,  // These are now optional
        longitude: event.longitude,
        radius: event.radius,
      );
      
      if (state is IncidentLoaded) {
        emit((state as IncidentLoaded).copyWith(nearbyIncidents: nearbyIncidents));
      } else {
        emit(IncidentLoaded(nearbyIncidents: nearbyIncidents));
      }
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      if (state is! IncidentLoaded) {
        emit(IncidentLoading());
      }

      final statistics = await _repository.getStatistics();
      
      if (state is IncidentLoaded) {
        emit((state as IncidentLoaded).copyWith(statistics: statistics));
      } else {
        emit(IncidentLoaded(statistics: statistics));
      }
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  Future<void> _onCreateIncident(
    CreateIncident event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      emit(IncidentCreating());

      final incident = await _repository.createIncident(
        title: event.title,
        description: event.description,
        categoryId: event.categoryId,
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
        severity: event.severity,
        isAnonymous: event.isAnonymous,
      );

      emit(IncidentCreated(incident));
      
      // Refresh incidents after creating
      add(LoadMyIncidents());
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  Future<void> _onRefreshIncidents(
    RefreshIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    add(LoadCategories());
    add(LoadMyIncidents());
    add(LoadStatistics());
  }
}
