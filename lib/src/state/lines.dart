import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:map_controller_plus/src/controller.dart';
import 'package:map_controller_plus/src/models.dart';

/// State of the lines on the map
class LinesState {
  /// Default contructor
  LinesState({required this.notify});

  /// The notify function
  final FeedNotifyFunction notify;

  final _namedLines = <String, Polyline>{};

  /// The named lines on the map
  Map<String, Polyline> get namedLines => _namedLines;

  /// The lines present on the map
  List<Polyline> get lines => _namedLines.values.toList();

  /// Add a line on the map
  void addLine({required String name, required Polyline line}) {
    _namedLines[name] = line;
    notify(
      "updateLines",
      _namedLines[name],
      addLine,
      MapControllerChangeType.lines,
    );
  }

  /// Remove a line from the map
  void removeLine(String name) {
    if (_namedLines.containsKey(name)) {
      _namedLines.remove(name);
      notify("updateLines", name, removeLine, MapControllerChangeType.lines);
    }
  }

  /// Remove multiple lines from the map
  void removeLines(List<String> names) {
    _namedLines.removeWhere((key, _) => names.contains(key));
    notify("updateLines", names, removeLines, MapControllerChangeType.lines);
  }

  /// Export all lines to a [GeoJsonFeature] with geometry
  /// type [GeoJsonMultiLine]
  GeoJsonFeature<GeoJsonMultiLine>? toGeoJsonFeatures() {
    if (namedLines.isEmpty) return null;

    final multiLine = GeoJsonMultiLine(name: "map_lines");

    for (final entry in namedLines.entries) {
      final polyline = entry.value;

      final line = GeoJsonLine()..name = entry.key;
      final geoSerie = GeoSerie(name: entry.key, type: GeoSerieType.line);

      for (final point in polyline.points) {
        geoSerie.geoPoints.add(
          GeoPoint(latitude: point.latitude, longitude: point.longitude),
        );
      }
      line.geoSerie = geoSerie;
      multiLine.lines.add(line);
    }

    final feature = GeoJsonFeature<GeoJsonMultiLine>()
      ..type = GeoJsonFeatureType.multiline
      ..geometry = multiLine
      ..properties = <String, dynamic>{"name": "map_lines"};

    return feature;
  }
}
