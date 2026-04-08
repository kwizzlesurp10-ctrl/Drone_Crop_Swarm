import type { Feature, Point, Polygon } from 'geojson';
import * as turf from '@turf/turf';

export interface Coordinate {
  latitude: number;
  longitude: number;
}

export function calculateDistance(from: Coordinate, to: Coordinate): number {
  const fromPoint = turf.point([from.longitude, from.latitude]);
  const toPoint = turf.point([to.longitude, to.latitude]);
  return turf.distance(fromPoint, toPoint, { units: 'meters' });
}

export function calculateArea(polygon: Polygon): number {
  const poly = turf.polygon(polygon.coordinates);
  return turf.area(poly);
}

export function isPointInPolygon(point: Coordinate, polygon: Polygon): boolean {
  const pt = turf.point([point.longitude, point.latitude]);
  const poly = turf.polygon(polygon.coordinates);
  return turf.booleanPointInPolygon(pt, poly);
}

export function generateGridPoints(
  bounds: [number, number, number, number],
  cellSide: number
): Feature<Point>[] {
  const [minX, minY, maxX, maxY] = bounds;
  const bbox: turf.BBox = [minX, minY, maxX, maxY];
  const grid = turf.pointGrid(bbox, cellSide, { units: 'meters' });
  return grid.features;
}
