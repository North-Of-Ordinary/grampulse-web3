import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../shardeum_service.dart';
import '../../shardeum_network_config.dart';

// ═══════════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════════

abstract class ShardeumEvent extends Equatable {
  const ShardeumEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load initial Shardeum status
class LoadShardeumStatus extends ShardeumEvent {
  const LoadShardeumStatus();
}

/// Refresh status (force network check)
class RefreshShardeumStatus extends ShardeumEvent {
  const RefreshShardeumStatus();
}

/// Toggle Shardeum (for demo purposes only)
class ToggleShardeumDemo extends ShardeumEvent {
  const ToggleShardeumDemo();
}

// ═══════════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════════

abstract class ShardeumState extends Equatable {
  const ShardeumState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state before any loading
class ShardeumInitial extends ShardeumState {
  const ShardeumInitial();
}

/// Loading network status
class ShardeumLoading extends ShardeumState {
  const ShardeumLoading();
}

/// Successfully loaded status
class ShardeumLoaded extends ShardeumState {
  final bool isEnabled;
  final bool isConnected;
  final ShardeumChainInfo? chainInfo;
  final ShardeumConnectionStatus? connectionStatus;
  final String architectureExplanation;
  final List<String> capabilities;
  final List<String> limitations;
  
  const ShardeumLoaded({
    required this.isEnabled,
    required this.isConnected,
    this.chainInfo,
    this.connectionStatus,
    required this.architectureExplanation,
    required this.capabilities,
    required this.limitations,
  });
  
  @override
  List<Object?> get props => [
    isEnabled,
    isConnected,
    chainInfo,
    connectionStatus,
    architectureExplanation,
    capabilities,
    limitations,
  ];
  
  ShardeumLoaded copyWith({
    bool? isEnabled,
    bool? isConnected,
    ShardeumChainInfo? chainInfo,
    ShardeumConnectionStatus? connectionStatus,
    String? architectureExplanation,
    List<String>? capabilities,
    List<String>? limitations,
  }) {
    return ShardeumLoaded(
      isEnabled: isEnabled ?? this.isEnabled,
      isConnected: isConnected ?? this.isConnected,
      chainInfo: chainInfo ?? this.chainInfo,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      architectureExplanation: architectureExplanation ?? this.architectureExplanation,
      capabilities: capabilities ?? this.capabilities,
      limitations: limitations ?? this.limitations,
    );
  }
}

/// Error state
class ShardeumError extends ShardeumState {
  final String message;
  final bool isEnabled;
  
  const ShardeumError({
    required this.message,
    this.isEnabled = false,
  });
  
  @override
  List<Object?> get props => [message, isEnabled];
}

// ═══════════════════════════════════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════════════════════════════════

class ShardeumBloc extends Bloc<ShardeumEvent, ShardeumState> {
  final ShardeumService _service = ShardeumService();
  
  ShardeumBloc() : super(const ShardeumInitial()) {
    on<LoadShardeumStatus>(_onLoadStatus);
    on<RefreshShardeumStatus>(_onRefreshStatus);
    on<ToggleShardeumDemo>(_onToggleDemo);
  }
  
  Future<void> _onLoadStatus(
    LoadShardeumStatus event,
    Emitter<ShardeumState> emit,
  ) async {
    emit(const ShardeumLoading());
    
    try {
      // Check if enabled
      final isEnabled = ShardeumNetworkConfig.isEnabled;
      
      if (!isEnabled) {
        // Return disabled state with architecture info
        emit(ShardeumLoaded(
          isEnabled: false,
          isConnected: false,
          architectureExplanation: _service.getArchitectureExplanation(),
          capabilities: ShardeumNetworkConfig.shardeumHandles,
          limitations: ShardeumNetworkConfig.shardeumDoesNotHandle,
        ));
        return;
      }
      
      // Initialize service
      await _service.initialize();
      
      // Check connection
      final connectionStatus = await _service.isConnected();
      
      // Get chain info
      final chainInfo = await _service.getChainInfo();
      
      emit(ShardeumLoaded(
        isEnabled: true,
        isConnected: connectionStatus.isConnected,
        chainInfo: chainInfo,
        connectionStatus: connectionStatus,
        architectureExplanation: _service.getArchitectureExplanation(),
        capabilities: chainInfo.capabilities,
        limitations: chainInfo.limitations ?? ShardeumNetworkConfig.shardeumDoesNotHandle,
      ));
    } catch (e) {
      emit(ShardeumError(
        message: 'Failed to load Shardeum status: $e',
        isEnabled: ShardeumNetworkConfig.isEnabled,
      ));
    }
  }
  
  Future<void> _onRefreshStatus(
    RefreshShardeumStatus event,
    Emitter<ShardeumState> emit,
  ) async {
    // Keep current state visible while refreshing
    final currentState = state;
    
    try {
      final isEnabled = ShardeumNetworkConfig.isEnabled;
      
      if (!isEnabled) {
        emit(ShardeumLoaded(
          isEnabled: false,
          isConnected: false,
          architectureExplanation: _service.getArchitectureExplanation(),
          capabilities: ShardeumNetworkConfig.shardeumHandles,
          limitations: ShardeumNetworkConfig.shardeumDoesNotHandle,
        ));
        return;
      }
      
      // Force refresh connection status
      final connectionStatus = await _service.isConnected(forceCheck: true);
      
      // Get fresh chain info
      final chainInfo = await _service.getChainInfo(useCache: false);
      
      emit(ShardeumLoaded(
        isEnabled: true,
        isConnected: connectionStatus.isConnected,
        chainInfo: chainInfo,
        connectionStatus: connectionStatus,
        architectureExplanation: _service.getArchitectureExplanation(),
        capabilities: chainInfo.capabilities,
        limitations: chainInfo.limitations ?? ShardeumNetworkConfig.shardeumDoesNotHandle,
      ));
    } catch (e) {
      if (currentState is ShardeumLoaded) {
        // Keep current state but show error
        emit(currentState.copyWith(isConnected: false));
      } else {
        emit(ShardeumError(
          message: 'Refresh failed: $e',
          isEnabled: ShardeumNetworkConfig.isEnabled,
        ));
      }
    }
  }
  
  Future<void> _onToggleDemo(
    ToggleShardeumDemo event,
    Emitter<ShardeumState> emit,
  ) async {
    // This is for demo purposes only - shows what UI looks like when toggled
    // In production, this would require env variable change
    final currentState = state;
    
    if (currentState is ShardeumLoaded) {
      emit(currentState.copyWith(
        isEnabled: !currentState.isEnabled,
        isConnected: !currentState.isEnabled ? false : currentState.isConnected,
      ));
    }
  }
}
