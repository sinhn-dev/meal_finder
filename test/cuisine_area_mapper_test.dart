import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/utils/cuisine_area_mapper.dart';

void main() {
  test('maps Hanoi to Vietnamese', () {
    expect(CuisineAreaMapper.latLngToCuisineArea(21.03, 105.85), 'Vietnamese');
  });

  test('maps Bangkok to Thai', () {
    expect(CuisineAreaMapper.latLngToCuisineArea(13.75, 100.50), 'Thai');
  });

  test('maps Tokyo to Japanese', () {
    expect(CuisineAreaMapper.latLngToCuisineArea(35.68, 139.69), 'Japanese');
  });

  test('maps New York to American', () {
    expect(CuisineAreaMapper.latLngToCuisineArea(40.71, -74.00), 'American');
  });

  test('maps Rome to Italian', () {
    expect(CuisineAreaMapper.latLngToCuisineArea(41.90, 12.50), 'Italian');
  });

  test('falls back to default Italian outside known boxes', () {
    expect(
      CuisineAreaMapper.latLngToCuisineArea(-33.87, 151.21),
      CuisineAreaMapper.defaultArea,
    );
  });
}
