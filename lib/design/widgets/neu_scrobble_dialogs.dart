import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Dialog for configuring Last.fm scrobbling
class LastFmScrobbleDialog extends StatefulWidget {
  final RatholePalette palette;
  final bool isEnabled;
  final String? username;
  final Function(bool enabled, String? username, String? password) onSave;

  const LastFmScrobbleDialog({
    super.key,
    required this.palette,
    this.isEnabled = false,
    this.username,
    required this.onSave,
  });

  @override
  State<LastFmScrobbleDialog> createState() => _LastFmScrobbleDialogState();
}

class _LastFmScrobbleDialogState extends State<LastFmScrobbleDialog> {
  late bool _isEnabled;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    if (widget.username != null) {
      _usernameController.text = widget.username!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.palette.background,
          border: Border.all(color: widget.palette.border, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.palette.shadow,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: widget.palette.error,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LAST.FM SCROBBLING',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      color: widget.palette.text,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.palette.text),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Enable toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.palette.surface,
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Last.fm Scrobbling',
                          style: textTheme.titleMedium?.copyWith(
                            color: widget.palette.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Automatically submit your listening history',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: widget.palette.text.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() => _isEnabled = value);
                      HapticFeedback.lightImpact();
                    },
                    activeColor: widget.palette.primary,
                  ),
                ],
              ),
            ),

            if (_isEnabled) ...[
              const SizedBox(height: 16),

              // Username field
              Text(
                'USERNAME',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: widget.palette.text.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Enter your Last.fm username',
                  prefixIcon: Icon(Icons.person, color: widget.palette.primary),
                  filled: true,
                  fillColor: widget.palette.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.primary, width: 3),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password field
              Text(
                'PASSWORD',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: widget.palette.text.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Enter your Last.fm password',
                  prefixIcon: Icon(Icons.lock, color: widget.palette.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                  filled: true,
                  fillColor: widget.palette.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.primary, width: 3),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.palette.primary.withOpacity(0.1),
                  border: Border.all(color: widget.palette.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: widget.palette.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your credentials are stored securely and only used for scrobbling',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: widget.palette.text.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton(
                  'Cancel',
                  () => Navigator.pop(context),
                  widget.palette.surface,
                  textTheme,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  'Save',
                  () {
                    widget.onSave(
                      _isEnabled,
                      _usernameController.text.isEmpty ? null : _usernameController.text,
                      _passwordController.text.isEmpty ? null : _passwordController.text,
                    );
                    Navigator.pop(context);
                  },
                  widget.palette.primary,
                  textTheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color bgColor, TextTheme textTheme) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: widget.palette.border, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: widget.palette.shadow,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 14,
            color: widget.palette.text,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Dialog for configuring ListenBrainz scrobbling
class ListenBrainzScrobbleDialog extends StatefulWidget {
  final RatholePalette palette;
  final bool isEnabled;
  final String? userToken;
  final Function(bool enabled, String? userToken) onSave;

  const ListenBrainzScrobbleDialog({
    super.key,
    required this.palette,
    this.isEnabled = false,
    this.userToken,
    required this.onSave,
  });

  @override
  State<ListenBrainzScrobbleDialog> createState() => _ListenBrainzScrobbleDialogState();
}

class _ListenBrainzScrobbleDialogState extends State<ListenBrainzScrobbleDialog> {
  late bool _isEnabled;
  final TextEditingController _tokenController = TextEditingController();
  bool _isTokenVisible = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    if (widget.userToken != null) {
      _tokenController.text = widget.userToken!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.palette.background,
          border: Border.all(color: widget.palette.border, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.palette.shadow,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.headphones,
                  color: widget.palette.secondary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LISTENBRAINZ SCROBBLING',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      color: widget.palette.text,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.palette.text),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Enable toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.palette.surface,
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable ListenBrainz Scrobbling',
                          style: textTheme.titleMedium?.copyWith(
                            color: widget.palette.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Open-source music listening history',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: widget.palette.text.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() => _isEnabled = value);
                      HapticFeedback.lightImpact();
                    },
                    activeColor: widget.palette.secondary,
                  ),
                ],
              ),
            ),

            if (_isEnabled) ...[
              const SizedBox(height: 16),

              // User token field
              Text(
                'USER TOKEN',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: widget.palette.text.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tokenController,
                obscureText: !_isTokenVisible,
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Paste your ListenBrainz user token',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.key, color: widget.palette.secondary),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: IconButton(
                      icon: Icon(
                        _isTokenVisible ? Icons.visibility_off : Icons.visibility,
                        color: widget.palette.text.withOpacity(0.6),
                      ),
                      onPressed: () {
                        setState(() => _isTokenVisible = !_isTokenVisible);
                      },
                    ),
                  ),
                  filled: true,
                  fillColor: widget.palette.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.secondary, width: 3),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Get token button
              GestureDetector(
                onTap: () {
                  // Open ListenBrainz token page
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.palette.tertiary.withOpacity(0.2),
                    border: Border.all(color: widget.palette.border, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: widget.palette.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Get your user token from listenbrainz.org',
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          color: widget.palette.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.palette.secondary.withOpacity(0.1),
                  border: Border.all(color: widget.palette.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: widget.palette.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your token is stored locally and never shared with third parties',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: widget.palette.text.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton(
                  'Cancel',
                  () => Navigator.pop(context),
                  widget.palette.surface,
                  textTheme,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  'Save',
                  () {
                    widget.onSave(
                      _isEnabled,
                      _tokenController.text.isEmpty ? null : _tokenController.text,
                    );
                    Navigator.pop(context);
                  },
                  widget.palette.secondary,
                  textTheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color bgColor, TextTheme textTheme) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: widget.palette.border, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: widget.palette.shadow,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 14,
            color: widget.palette.text,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
}