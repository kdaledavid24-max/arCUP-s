import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Interactive delivery address selector featuring an interactive map centered on Quiapo, Manila.
/// Supports tapping or dragging the pin, auto-updating address, GPS jump button,
/// and a saved address viewer/manager.
class InteractiveDeliveryMap extends StatefulWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const InteractiveDeliveryMap({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<InteractiveDeliveryMap> createState() => _InteractiveDeliveryMapState();
}

class _InteractiveDeliveryMapState extends State<InteractiveDeliveryMap> {
  static const String _defaultAddress =
      'E-2K Marketing, 678 Ronquillo Street, Quiapo, Manila, 1001 Metro Manila, Philippines';

  // Relative pin position inside the map container (0.0 to 1.0)
  // Default is roughly near the center-top where Ronquillo St is located
  double _pinX = 0.42;
  double _pinY = 0.32;
  double _zoomLevel = 1.0;

  // Preset Quiapo street/building locations based on map coordinates
  final List<_QuiapoLocation> _locations = const [
    _QuiapoLocation(
      x: 0.42,
      y: 0.32,
      address: 'E-2K Marketing, 678 Ronquillo Street, Quiapo, Manila, 1001 Metro Manila, Philippines',
      landmark: 'Ronquillo St / E-2K Marketing',
    ),
    _QuiapoLocation(
      x: 0.40,
      y: 0.76,
      address: 'Minor Basilica of the Black Nazarene, 910 Plaza Miranda, Quiapo, Manila, 1001 Metro Manila',
      landmark: 'Quiapo Church / Plaza Miranda',
    ),
    _QuiapoLocation(
      x: 0.24,
      y: 0.82,
      address: 'Isetann Cinerama Complex, Carriedo cor. Evangelista St, Quiapo, Manila, 1001 Metro Manila',
      landmark: 'Isetann Carriedo',
    ),
    _QuiapoLocation(
      x: 0.16,
      y: 0.62,
      address: 'Santa Cruz Parish Church, Plaza Santa Cruz, Santa Cruz, Manila, 1003 Metro Manila',
      landmark: 'Sta. Cruz Church',
    ),
    _QuiapoLocation(
      x: 0.14,
      y: 0.48,
      address: 'Bustos Street cor. Rizal Ave, Santa Cruz, Manila, 1003 Metro Manila, Philippines',
      landmark: 'Bustos Street',
    ),
    _QuiapoLocation(
      x: 0.72,
      y: 0.26,
      address: 'Calix Bakery, 245 Z.P. De Guzman St, Quiapo, Manila, 1001 Metro Manila, Philippines',
      landmark: 'Calix Bakery',
    ),
    _QuiapoLocation(
      x: 0.76,
      y: 0.50,
      address: 'STI College - Recto, C.M. Recto Ave cor. Quezon Blvd, Quiapo, Manila, 1001 Metro Manila',
      landmark: 'STI College Recto',
    ),
    _QuiapoLocation(
      x: 0.78,
      y: 0.88,
      address: 'St. Rita College, San Rafael St, Quiapo, Manila, 1001 Metro Manila, Philippines',
      landmark: 'St. Rita College',
    ),
    _QuiapoLocation(
      x: 0.54,
      y: 0.45,
      address: 'Quezon Boulevard cor. Gonzalo Puyat St, Quiapo, Manila, 1001 Metro Manila, Philippines',
      landmark: 'Quezon Boulevard',
    ),
    _QuiapoLocation(
      x: 0.90,
      y: 0.78,
      address: 'F. R. Hidalgo Street, Quiapo, Manila, 1001 Metro Manila, Philippines',
      landmark: 'F.R. Hidalgo Street',
    ),
  ];

  List<String> _savedAddresses = [
    'E-2K Marketing, 678 Ronquillo Street, Quiapo, Manila, 1001 Metro Manila, Philippines',
    'Minor Basilica of the Black Nazarene, 910 Plaza Miranda, Quiapo, Manila, 1001 Metro Manila',
    'Isetann Cinerama Complex, Carriedo cor. Evangelista St, Quiapo, Manila, 1001 Metro Manila',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.trim().isEmpty) {
      widget.controller.text = _defaultAddress;
    }
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('aic_saved_addresses');
      if (saved != null && saved.isNotEmpty) {
        setState(() {
          _savedAddresses = saved;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveAddress(String address) async {
    if (address.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_savedAddresses.contains(address)) {
        setState(() {
          _savedAddresses.insert(0, address);
        });
        await prefs.setStringList('aic_saved_addresses', _savedAddresses);
      }
    } catch (_) {}
  }

  void _updateAddressFromCoordinates(double x, double y) {
    // Find closest landmark or interpolate
    _QuiapoLocation? closest;
    double minDistance = double.infinity;

    for (final loc in _locations) {
      final dx = loc.x - x;
      final dy = loc.y - y;
      final dist = dx * dx + dy * dy;
      if (dist < minDistance) {
        minDistance = dist;
        closest = loc;
      }
    }

    if (closest != null) {
      setState(() {
        _pinX = x;
        _pinY = y;
        widget.controller.text = closest!.address;
      });
    }
  }

  void _jumpToCurrentLocation() {
    setState(() {
      _pinX = 0.42;
      _pinY = 0.32;
      widget.controller.text = _defaultAddress;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.my_location_rounded, color: AppTheme.goldAccent, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pinpoint located: Quiapo, Manila',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF142034),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSavedAddressesDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bookmark_outline_rounded, color: AppTheme.goldAccent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Saved Delivery Addresses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_savedAddresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No saved addresses yet.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _savedAddresses.length,
                      separatorBuilder: (_, _) => const Divider(color: AppTheme.cardBorder, height: 1),
                      itemBuilder: (context, index) {
                        final addr = _savedAddresses[index];
                        final isSelected = widget.controller.text == addr;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          leading: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.location_on_outlined,
                            color: isSelected ? AppTheme.goldAccent : AppTheme.textMuted,
                          ),
                          title: Text(
                            addr,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? AppTheme.goldAccent : AppTheme.textWhite,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              widget.controller.text = addr;
                              final match = _locations.firstWhere(
                                (l) => l.address == addr,
                                orElse: () => const _QuiapoLocation(
                                  x: 0.42,
                                  y: 0.32,
                                  address: '',
                                  landmark: '',
                                ),
                              );
                              if (match.address.isNotEmpty) {
                                _pinX = match.x;
                                _pinY = match.y;
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final current = widget.controller.text.trim();
                      if (current.isNotEmpty) {
                        _saveAddress(current);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address saved to your list!'),
                            backgroundColor: AppTheme.successGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                    label: const Text('Save Current Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with Red Asterisk (*)
        RichText(
          text: const TextSpan(
            text: 'Delivery Address ',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Address Field + GPS and Saved List Buttons Row
        Row(
          children: [
            // Full Address Input Field
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText: 'Enter your complete delivery address',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF101927),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
                  ),
                ),
                validator: widget.validator ??
                    (v) => (v == null || v.trim().isEmpty)
                        ? 'Delivery address is mandatory *'
                        : null,
              ),
            ),
            const SizedBox(width: 8),

            // Jump to Current Location Button (White Square)
            InkWell(
              onTap: _jumpToCurrentLocation,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // View/Save Addresses Button (White Square)
            InkWell(
              onTap: _showSavedAddressesDialog,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Interactive Quiapo Map Container
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mapWidth = constraints.maxWidth;
              final mapHeight = constraints.maxHeight;

              return Stack(
                children: [
                  // Interactive Map Area (Tap or Drag anywhere to place pin)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final localPos = details.localPosition;
                      final nx = (localPos.dx / mapWidth).clamp(0.05, 0.95);
                      final ny = (localPos.dy / mapHeight).clamp(0.05, 0.95);
                      _updateAddressFromCoordinates(nx, ny);
                    },
                    onPanUpdate: (details) {
                      final localPos = details.localPosition;
                      final nx = (localPos.dx / mapWidth).clamp(0.05, 0.95);
                      final ny = (localPos.dy / mapHeight).clamp(0.05, 0.95);
                      _updateAddressFromCoordinates(nx, ny);
                    },
                    child: CustomPaint(
                      size: Size(mapWidth, mapHeight),
                      painter: _QuiapoMapPainter(zoom: _zoomLevel),
                    ),
                  ),

                  // Pinpoint Marker (Green Stadium Badge + Orange Pin + Tooltip)
                  Positioned(
                    left: _pinX * mapWidth - 24,
                    top: _pinY * mapHeight - 56,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final newX = ((_pinX * mapWidth + details.delta.dx) / mapWidth)
                            .clamp(0.05, 0.95);
                        final newY = ((_pinY * mapHeight + details.delta.dy) / mapHeight)
                            .clamp(0.05, 0.95);
                        _updateAddressFromCoordinates(newX, newY);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Green Circular Storefront Badge
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.stadium_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),

                          // Orange Pin Head
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFF97316),
                              size: 28,
                            ),
                          ),

                          // Floating Helper Tooltip
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24, width: 0.5),
                              ),
                              child: const Text(
                                'Tap the map to drop your pin',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Left Attribution Badge
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apple, size: 12, color: Colors.black87),
                          SizedBox(width: 2),
                          Text(
                            'Maps',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' | Quiapo',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Right Zoom In/Out Controls
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 1.6);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                '–',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 14, color: Colors.black12),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 1.6);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuiapoLocation {
  final double x;
  final double y;
  final String address;
  final String landmark;

  const _QuiapoLocation({
    required this.x,
    required this.y,
    required this.address,
    required this.landmark,
  });
}

/// Custom painter rendering a clean, high-fidelity vector street map of Quiapo, Manila
/// with river, major avenues (Quezon Blvd, Recto, Ronquillo), and landmarks matching the user's screenshot.
class _QuiapoMapPainter extends CustomPainter {
  final double zoom;

  _QuiapoMapPainter({required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background land color
    final bgPaint = Paint()..color = const Color(0xFFF7F5EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // River / Estero (Pasig River tributary running through Quiapo)
    final riverPaint = Paint()
      ..color = const Color(0xFF90D5EC)
      ..strokeWidth = 14 * zoom
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(w * 0.72, h * 0.35);
    riverPath.quadraticBezierTo(w * 0.55, h * 0.55, w * 0.48, h * 0.90);
    riverPath.quadraticBezierTo(w * 0.46, h * 1.05, w * 0.44, h * 1.15);
    canvas.drawPath(riverPath, riverPaint);

    // Minor streets grid (Light gray)
    final minorStreetPaint = Paint()
      ..color = const Color(0xFFE5E2D6)
      ..strokeWidth = 6 * zoom
      ..style = PaintingStyle.stroke;

    // Diagonal / Grid Street Paths
    final minorGrid = Path()
      ..moveTo(0, h * 0.20)
      ..lineTo(w * 0.40, h * 0.05)
      ..moveTo(0, h * 0.38)
      ..lineTo(w * 0.45, h * 0.20)
      ..moveTo(0, h * 0.58)
      ..lineTo(w * 0.45, h * 0.40)
      ..moveTo(w * 0.10, h * 0.75)
      ..lineTo(w * 0.48, h * 0.58)
      ..moveTo(w * 0.65, h * 0.15)
      ..lineTo(w * 0.95, h * 0.35)
      ..moveTo(w * 0.68, h * 0.42)
      ..lineTo(w, h * 0.65)
      ..moveTo(w * 0.60, h * 0.85)
      ..lineTo(w, h * 0.60);
    canvas.drawPath(minorGrid, minorStreetPaint);

    // Major Avenues (White with subtle borders)
    final majorRoadBorder = Paint()
      ..color = const Color(0xFFD6D1C1)
      ..strokeWidth = 16 * zoom
      ..style = PaintingStyle.stroke;

    final majorRoadFill = Paint()
      ..color = Colors.white
      ..strokeWidth = 13 * zoom
      ..style = PaintingStyle.stroke;

    // Quezon Boulevard (Major vertical avenue)
    final quezonBlvd = Path();
    quezonBlvd.moveTo(w * 0.56, 0);
    quezonBlvd.lineTo(w * 0.46, h);
    canvas.drawPath(quezonBlvd, majorRoadBorder);
    canvas.drawPath(quezonBlvd, majorRoadFill);

    // Recto Avenue / Ronquillo Street (Horizontal arteries)
    final crossRoad = Path();
    crossRoad.moveTo(0, h * 0.44);
    crossRoad.lineTo(w, h * 0.32);
    canvas.drawPath(crossRoad, majorRoadBorder);
    canvas.drawPath(crossRoad, majorRoadFill);

    // Secondary Cross Street (Evangelista / Carriedo)
    final secondaryRoad = Path();
    secondaryRoad.moveTo(w * 0.38, 0);
    secondaryRoad.lineTo(w * 0.30, h);
    canvas.drawPath(secondaryRoad, majorRoadBorder);
    canvas.drawPath(secondaryRoad, majorRoadFill);

    // Street Names and Landmark Labels
    _drawText(canvas, 'QUEZON BOULEVARD', w * 0.53, h * 0.38, rotation: 1.45, isPrimary: true);
    _drawText(canvas, 'BUSTOS STREET', w * 0.14, h * 0.48);
    _drawText(canvas, 'PLAZA SANTA CRUZ', w * 0.08, h * 0.72, rotation: -0.9);
    _drawText(canvas, 'Sta. Cruz Church', w * 0.16, h * 0.62, isIcon: true, icon: Icons.account_balance);
    _drawText(canvas, 'Isetann', w * 0.26, h * 0.82, isIcon: true, icon: Icons.storefront);
    _drawText(canvas, 'Quiapo Church', w * 0.39, h * 0.78, isHighlight: true, icon: Icons.place);
    _drawText(canvas, 'Calix Bakery', w * 0.74, h * 0.26, isIcon: true, icon: Icons.cake);
    _drawText(canvas, 'STI College - Recto', w * 0.78, h * 0.50, isIcon: true, icon: Icons.school);
    _drawText(canvas, 'QUIAPO', w * 0.90, h * 0.58, isPrimary: true);
    _drawText(canvas, 'St. Rita College', w * 0.78, h * 0.88, isIcon: true, icon: Icons.school);
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double rotation = 0.0,
    bool isPrimary = false,
    bool isHighlight = false,
    bool isIcon = false,
    IconData? icon,
  }) {
    canvas.save();
    canvas.translate(x, y);
    if (rotation != 0.0) {
      canvas.rotate(rotation);
    }

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: isHighlight
            ? const Color(0xFF2563EB)
            : isPrimary
                ? const Color(0xFF6B7280)
                : const Color(0xFF4B5563),
        fontSize: isPrimary ? 10.5 : 9.0,
        fontWeight: isHighlight || isPrimary ? FontWeight.bold : FontWeight.w600,
        letterSpacing: isPrimary ? 1.0 : 0.2,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QuiapoMapPainter oldDelegate) =>
      oldDelegate.zoom != zoom;
}
