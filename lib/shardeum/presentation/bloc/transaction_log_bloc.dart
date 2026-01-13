import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../shardeum_transaction_service.dart';

// ═══════════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════════

abstract class TransactionLogEvent extends Equatable {
  const TransactionLogEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTransactionHistory extends TransactionLogEvent {
  const LoadTransactionHistory();
}

class RefreshTransactions extends TransactionLogEvent {
  const RefreshTransactions();
}

class FilterTransactions extends TransactionLogEvent {
  final TransactionStatus? status;
  
  const FilterTransactions({this.status});
  
  @override
  List<Object?> get props => [status];
}

class SendTestTransaction extends TransactionLogEvent {
  const SendTestTransaction();
}

class NewTransactionReceived extends TransactionLogEvent {
  final TransactionLog transaction;
  
  const NewTransactionReceived(this.transaction);
  
  @override
  List<Object?> get props => [transaction];
}

// ═══════════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════════

abstract class TransactionLogState extends Equatable {
  const TransactionLogState();
  
  @override
  List<Object?> get props => [];
}

class TransactionLogInitial extends TransactionLogState {
  const TransactionLogInitial();
}

class TransactionLogLoading extends TransactionLogState {
  const TransactionLogLoading();
}

class TransactionLogLoaded extends TransactionLogState {
  final List<TransactionLog> transactions;
  final TransactionStats stats;
  final TransactionStatus? filter;
  
  const TransactionLogLoaded({
    required this.transactions,
    required this.stats,
    this.filter,
  });
  
  @override
  List<Object?> get props => [transactions, stats, filter];
  
  TransactionLogLoaded copyWith({
    List<TransactionLog>? transactions,
    TransactionStats? stats,
    TransactionStatus? filter,
    bool clearFilter = false,
  }) {
    return TransactionLogLoaded(
      transactions: transactions ?? this.transactions,
      stats: stats ?? this.stats,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }
}

class TransactionLogError extends TransactionLogState {
  final String message;
  
  const TransactionLogError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class TransactionSending extends TransactionLogState {
  const TransactionSending();
}

// ═══════════════════════════════════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════════════════════════════════

class TransactionLogBloc extends Bloc<TransactionLogEvent, TransactionLogState> {
  final ShardeumTransactionService _service = ShardeumTransactionService();
  
  TransactionLogBloc() : super(const TransactionLogInitial()) {
    on<LoadTransactionHistory>(_onLoadHistory);
    on<RefreshTransactions>(_onRefresh);
    on<FilterTransactions>(_onFilter);
    on<SendTestTransaction>(_onSendTest);
    on<NewTransactionReceived>(_onNewTransaction);
    
    // Listen for real-time transaction updates
    _service.addTransactionListener(_onTransactionUpdate);
  }
  
  void _onTransactionUpdate(TransactionLog log) {
    add(NewTransactionReceived(log));
  }
  
  Future<void> _onLoadHistory(
    LoadTransactionHistory event,
    Emitter<TransactionLogState> emit,
  ) async {
    emit(const TransactionLogLoading());
    
    try {
      // Initialize service if not ready
      if (!_service.isReady) {
        await _service.initialize();
      }
      
      final transactions = _service.transactionHistory;
      final stats = _service.getStats();
      
      emit(TransactionLogLoaded(
        transactions: transactions,
        stats: stats,
      ));
    } catch (e) {
      emit(TransactionLogError('Failed to load transactions: $e'));
    }
  }
  
  Future<void> _onRefresh(
    RefreshTransactions event,
    Emitter<TransactionLogState> emit,
  ) async {
    final currentState = state;
    
    try {
      final transactions = _service.transactionHistory;
      final stats = _service.getStats();
      
      if (currentState is TransactionLogLoaded) {
        emit(currentState.copyWith(
          transactions: transactions,
          stats: stats,
        ));
      } else {
        emit(TransactionLogLoaded(
          transactions: transactions,
          stats: stats,
        ));
      }
    } catch (e) {
      if (currentState is TransactionLogLoaded) {
        emit(currentState); // Keep current state on refresh error
      } else {
        emit(TransactionLogError('Refresh failed: $e'));
      }
    }
  }
  
  Future<void> _onFilter(
    FilterTransactions event,
    Emitter<TransactionLogState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is! TransactionLogLoaded) return;
    
    try {
      final allTransactions = _service.transactionHistory;
      final filteredTransactions = event.status == null
          ? allTransactions
          : _service.getTransactionsByStatus(event.status!);
      
      emit(currentState.copyWith(
        transactions: filteredTransactions,
        filter: event.status,
        clearFilter: event.status == null,
      ));
    } catch (e) {
      emit(TransactionLogError('Filter failed: $e'));
    }
  }
  
  Future<void> _onSendTest(
    SendTestTransaction event,
    Emitter<TransactionLogState> emit,
  ) async {
    final currentState = state;
    emit(const TransactionSending());
    
    try {
      if (!_service.isReady) {
        await _service.initialize();
      }
      
      // Send test transaction
      final result = await _service.logCivicEvent(
        eventType: 'test_event',
        villageId: 'TEST_VILLAGE_${DateTime.now().millisecondsSinceEpoch}',
        grievanceId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          'test': true,
          'timestamp': DateTime.now().toIso8601String(),
          'purpose': 'Testing blockchain integration',
        },
      );
      
      // Reload transactions
      final transactions = _service.transactionHistory;
      final stats = _service.getStats();
      
      emit(TransactionLogLoaded(
        transactions: transactions,
        stats: stats,
        filter: currentState is TransactionLogLoaded ? currentState.filter : null,
      ));
      
      if (!result.success) {
        // Show error but keep the loaded state
        debugPrint('⚠️ Test transaction failed: ${result.errorMessage}');
      }
    } catch (e) {
      // On error, try to restore previous state or show error
      if (currentState is TransactionLogLoaded) {
        emit(currentState);
      } else {
        emit(TransactionLogError('Failed to send test transaction: $e'));
      }
    }
  }
  
  Future<void> _onNewTransaction(
    NewTransactionReceived event,
    Emitter<TransactionLogState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is TransactionLogLoaded) {
      final transactions = _service.transactionHistory;
      final stats = _service.getStats();
      
      // Apply current filter if any
      final filteredTransactions = currentState.filter == null
          ? transactions
          : transactions.where((tx) => tx.status == currentState.filter).toList();
      
      emit(currentState.copyWith(
        transactions: filteredTransactions,
        stats: stats,
      ));
    }
  }
  
  @override
  Future<void> close() {
    _service.removeTransactionListener(_onTransactionUpdate);
    return super.close();
  }
}
