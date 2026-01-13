import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/shardeum_bloc.dart';

/// Shardeum Status Screen
/// 
/// Architecture Role: Displays the status of Shardeum integration
/// and explains its role in the multi-chain architecture.
/// 
/// "Shardeum scales events, Optimism certifies outcomes"

class ShardeumScreen extends StatelessWidget {
  const ShardeumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShardeumBloc()..add(const LoadShardeumStatus()),
      child: const ShardeumScreenView(),
    );
  }
}

class ShardeumScreenView extends StatelessWidget {
  const ShardeumScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shardeum Integration'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () {
              context.read<ShardeumBloc>().add(const RefreshShardeumStatus());
            },
          ),
        ],
      ),
      body: BlocBuilder<ShardeumBloc, ShardeumState>(
        builder: (context, state) {
          if (state is ShardeumInitial || state is ShardeumLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking Shardeum status...'),
                ],
              ),
            );
          }
          
          if (state is ShardeumError) {
            return _buildErrorState(context, state, colorScheme);
          }
          
          if (state is ShardeumLoaded) {
            return _buildLoadedState(context, state, colorScheme);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ShardeumError state,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<ShardeumBloc>().add(const LoadShardeumStatus());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    ShardeumLoaded state,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Banner
          _buildStatusBanner(state, colorScheme),
          const SizedBox(height: 16),
          
          // Architecture Card
          _buildArchitectureCard(context, state, colorScheme),
          const SizedBox(height: 16),
          
          // Network Info (if enabled and connected)
          if (state.isEnabled && state.chainInfo != null)
            _buildNetworkInfoCard(state, colorScheme),
          
          if (state.isEnabled && state.chainInfo != null)
            const SizedBox(height: 16),
          
          // Capabilities & Limitations
          _buildCapabilitiesCard(state, colorScheme),
          const SizedBox(height: 16),
          
          // What Shardeum Does NOT Handle
          _buildLimitationsCard(state, colorScheme),
          const SizedBox(height: 16),
          
          // Transaction Log Button (if enabled)
          if (state.isEnabled)
            _buildTransactionLogButton(context, colorScheme),
          
          if (state.isEnabled)
            const SizedBox(height: 16),
          
          // Info Note
          _buildInfoNote(colorScheme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ShardeumLoaded state, ColorScheme colorScheme) {
    final isEnabled = state.isEnabled;
    final isConnected = state.isConnected;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;
    String subtitleText;
    
    if (!isEnabled) {
      backgroundColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
      icon = Icons.power_off;
      statusText = 'Shardeum Disabled';
      subtitleText = 'Operating in Optimism-only mode';
    } else if (isConnected) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      statusText = 'Connected to Shardeum';
      subtitleText = 'Multi-chain mode active';
    } else {
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.cloud_off;
      statusText = 'Shardeum Enabled';
      subtitleText = 'Network connection pending';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: textColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isEnabled ? 'ON' : 'OFF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureCard(
    BuildContext context,
    ShardeumLoaded state,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.architecture,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Multi-Chain Architecture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '"Shardeum scales events, Optimism certifies outcomes"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Visual Architecture Diagram
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildChainBox(
                        'SHARDEUM',
                        'Scale Layer',
                        state.isEnabled && state.isConnected
                            ? Colors.green
                            : colorScheme.outline,
                        Icons.speed,
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Events',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      _buildChainBox(
                        'OPTIMISM',
                        'Trust Layer',
                        colorScheme.primary,
                        Icons.verified,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainBox(String name, String role, Color color, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoCard(ShardeumLoaded state, ColorScheme colorScheme) {
    final chainInfo = state.chainInfo!;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dns,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Network Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Network', chainInfo.networkName, colorScheme),
            _buildInfoRow('Chain ID', '${chainInfo.chainId}', colorScheme),
            if (chainInfo.latestBlock != null)
              _buildInfoRow(
                'Latest Block',
                '#${chainInfo.latestBlock}',
                colorScheme,
              ),
            if (chainInfo.gasPrice != null)
              _buildInfoRow(
                'Gas Price',
                '${(chainInfo.gasPrice! / 1e9).toStringAsFixed(2)} Gwei',
                colorScheme,
              ),
            _buildInfoRow(
              'Currency',
              chainInfo.currencySymbol ?? 'SHM',
              colorScheme,
            ),
            if (chainInfo.explorerUrl != null)
              _buildInfoRow(
                'Explorer',
                'View on Explorer →',
                colorScheme,
                isLink: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLink ? colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard(ShardeumLoaded state, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 12),
                Text(
                  'What Shardeum Handles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...state.capabilities.map((capability) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 20,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      capability,
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitationsCard(ShardeumLoaded state, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200),
      ),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.do_not_disturb,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 12),
                Text(
                  'What Shardeum Does NOT Handle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '(These go to Optimism)',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ...state.limitations.map((limitation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      limitation,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionLogButton(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/shardeum/transactions'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Transaction Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See real-time blockchain transactions',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoNote(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.tertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Shardeum integration is optional. When disabled, all operations use Optimism (canonical trust layer) directly.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
