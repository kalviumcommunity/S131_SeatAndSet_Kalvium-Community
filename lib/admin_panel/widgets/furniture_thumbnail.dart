import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class FurnitureThumbnail extends StatelessWidget {
  final FurnitureType type;
  final double size;

  const FurnitureThumbnail({
    super.key,
    required this.type,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(size * 0.75, size * 0.75),
            painter: _FurniturePainter(type),
          ),
        ),
      ),
    );
  }
}

class _FurniturePainter extends CustomPainter {
  final FurnitureType type;

  _FurniturePainter(this.type);

  // Cached Paint instances to prevent frame-by-frame memory allocations during list scrolling
  static final Paint _sofaPaint = Paint()..color = const Color(0xFFC7B191);
  static final Paint _sofaShadowPaint = Paint()..color = const Color(0xFFB59F80);
  static final Paint _sofaLegPaint = Paint()..color = const Color(0xFF4A453E);

  static final Paint _studyWoodPaint = Paint()..color = const Color(0xFFC99859);
  static final Paint _studyLegPaint = Paint()..color = const Color(0xFF4B4237);
  static final Paint _studyLampPaint = Paint()..color = const Color(0xFF2E6548);
  static final Paint _studyHandlePaint = Paint()..color = const Color(0xFF332D26);
  static final Paint _studyStrokePaint = Paint()
    ..color = const Color(0xFF4B4237)
    ..strokeWidth = 2;

  static final Paint _officeChairPaint = Paint()..color = const Color(0xFF2C3138);
  static final Paint _officeFramePaint = Paint()..color = const Color(0xFF1E2126);
  static final Paint _officeBaseStrokePaint = Paint()
    ..color = const Color(0xFF1E2126)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  static final Paint _bedWoodPaint = Paint()..color = const Color(0xFF7A654E);
  static final Paint _bedMattressPaint = Paint()..color = const Color(0xFF948169);
  static final Paint _bedPillowPaint = Paint()..color = Colors.white;
  static final Paint _bedLegPaint = Paint()..color = const Color(0xFF4A3B2B);

  static final Paint _diningTablePaint = Paint()..color = const Color(0xFFC79E67);
  static final Paint _diningChairPaint = Paint()..color = const Color(0xFF8C6940);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case FurnitureType.sofa:
        _drawSofa(canvas, w, h);
        break;
      case FurnitureType.studyTable:
        _drawStudyTable(canvas, w, h);
        break;
      case FurnitureType.officeChair:
        _drawOfficeChair(canvas, w, h);
        break;
      case FurnitureType.bed:
        _drawBed(canvas, w, h);
        break;
      case FurnitureType.diningTable:
        _drawDiningTable(canvas, w, h);
        break;
    }
  }

  void _drawSofa(Canvas canvas, double w, double h) {
    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.75, w * 0.08, h * 0.18), const Radius.circular(2)),
      _sofaLegPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.74, h * 0.75, w * 0.08, h * 0.18), const Radius.circular(2)),
      _sofaLegPaint,
    );

    // Sofa Backrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.40), const Radius.circular(8)),
      _sofaPaint,
    );

    // Left Armrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.05, h * 0.32, w * 0.16, h * 0.46), const Radius.circular(7)),
      _sofaShadowPaint,
    );

    // Right Armrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.79, h * 0.32, w * 0.16, h * 0.46), const Radius.circular(7)),
      _sofaShadowPaint,
    );

    // Left Cushion
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.19, h * 0.44, w * 0.30, h * 0.32), const Radius.circular(6)),
      _sofaPaint,
    );

    // Right Cushion
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.51, h * 0.44, w * 0.30, h * 0.32), const Radius.circular(6)),
      _sofaPaint,
    );
  }

  void _drawStudyTable(Canvas canvas, double w, double h) {
    // Desk Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.44, w * 0.07, h * 0.48), const Radius.circular(2)),
      _studyLegPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.81, h * 0.44, w * 0.07, h * 0.48), const Radius.circular(2)),
      _studyLegPaint,
    );

    // Desk Top
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.42, w * 0.88, h * 0.10), const Radius.circular(4)),
      _studyWoodPaint,
    );

    // Desk Drawer
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.48, h * 0.52, w * 0.34, h * 0.18), const Radius.circular(3)),
      _studyWoodPaint,
    );
    // Drawer Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.58, h * 0.58, w * 0.14, h * 0.035), const Radius.circular(2)),
      _studyHandlePaint,
    );

    // Desk Lamp Base & Pole & Shade
    canvas.drawCircle(Offset(w * 0.18, h * 0.42), w * 0.05, _studyLampPaint);
    canvas.drawLine(
      Offset(w * 0.18, h * 0.40),
      Offset(w * 0.18, h * 0.22),
      _studyStrokePaint,
    );
    canvas.drawCircle(Offset(w * 0.18, h * 0.20), w * 0.09, _studyLampPaint);
  }

  void _drawOfficeChair(Canvas canvas, double w, double h) {
    // Backrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.36, h * 0.42), const Radius.circular(10)),
      _officeChairPaint,
    );

    // Seat
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.52, w * 0.52, h * 0.12), const Radius.circular(6)),
      _officeChairPaint,
    );

    // Armrests
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.38, w * 0.08, h * 0.16), const Radius.circular(4)),
      _officeFramePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.72, h * 0.38, w * 0.08, h * 0.16), const Radius.circular(4)),
      _officeFramePaint,
    );

    // Stem / Cylinder
    canvas.drawRect(
      Rect.fromLTWH(w * 0.47, h * 0.64, w * 0.06, h * 0.14),
      _officeFramePaint,
    );

    // Base Wheels
    final basePath = Path()
      ..moveTo(w * 0.5, h * 0.78)
      ..lineTo(w * 0.20, h * 0.88)
      ..moveTo(w * 0.5, h * 0.78)
      ..lineTo(w * 0.80, h * 0.88)
      ..moveTo(w * 0.5, h * 0.78)
      ..lineTo(w * 0.50, h * 0.90);
    canvas.drawPath(
      basePath,
      _officeBaseStrokePaint,
    );
  }

  void _drawBed(Canvas canvas, double w, double h) {
    // Headboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.22, w * 0.12, h * 0.62), const Radius.circular(4)),
      _bedWoodPaint,
    );

    // Bed Base & Mattress
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.50, w * 0.70, h * 0.26), const Radius.circular(4)),
      _bedMattressPaint,
    );

    // Pillow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.40, w * 0.20, h * 0.14), const Radius.circular(4)),
      _bedPillowPaint,
    );

    // Bed Legs
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.76, w * 0.08, h * 0.10), _bedLegPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.80, h * 0.76, w * 0.08, h * 0.10), _bedLegPaint);
  }

  void _drawDiningTable(Canvas canvas, double w, double h) {
    // Center Table Top
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.44, w * 0.44, h * 0.08), const Radius.circular(3)),
      _diningTablePaint,
    );
    // Table Legs
    canvas.drawRect(Rect.fromLTWH(w * 0.32, h * 0.52, w * 0.06, h * 0.36), _diningTablePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.52, w * 0.06, h * 0.36), _diningTablePaint);

    // Left Chair
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.10, h * 0.30, w * 0.06, h * 0.58), const Radius.circular(2)),
      _diningChairPaint,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.56, w * 0.14, h * 0.06), _diningChairPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.62, w * 0.05, h * 0.26), _diningChairPaint);

    // Right Chair
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.84, h * 0.30, w * 0.06, h * 0.58), const Radius.circular(2)),
      _diningChairPaint,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.70, h * 0.56, w * 0.14, h * 0.06), _diningChairPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.71, h * 0.62, w * 0.05, h * 0.26), _diningChairPaint);
  }

  @override
  bool shouldRepaint(covariant _FurniturePainter oldDelegate) => oldDelegate.type != type;
}

