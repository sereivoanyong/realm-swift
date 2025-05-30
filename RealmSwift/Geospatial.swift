////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Realm

public extension GeoBox {
    /// Initialize a `GeoBox`, with values for bottom left corner and top right corner.
    ///
    /// - Parameter bottomLeft: The bottom left corner of the rectangle.
    /// - Parameter topRight: The top right corner of the rectangle.
    convenience init?(bottomLeft: (Double, Double), topRight: (Double, Double)) {
        guard let bottomLeftPoint = GeoPoint(latitude: bottomLeft.0, longitude: bottomLeft.1),
              let topRightPoint = GeoPoint(latitude: topRight.0, longitude: topRight.1) else {
            return nil
        }
        self.init(bottomLeft: bottomLeftPoint, topRight: topRightPoint)
    }
}

public extension GeoPolygon {
    /// Initialize a `GeoPolygon`, with values for bottom left corner and top right corner.
    ///
    /// Returns `nil` if the `GeoPoints` representing a polygon (outer ring or holes), don't have at least 4 points.
    /// Returns `nil` if the first and the last `GeoPoint` in a polygon are not the same.
    ///
    /// - Parameter outerRing: The polygon's external (outer) ring.
    /// - Parameter holes: The holes (if any) in the polygon.
    convenience init?(outerRing: [(Double, Double)], holes: [[(Double, Double)]] = []) {
        let outerRingPoints = outerRing.compactMap(GeoPoint.init)
        let holesPoints = holes.map { $0.compactMap(GeoPoint.init) }
        guard outerRing.count == outerRingPoints.count,
              zip(holes, holesPoints).allSatisfy({ $0.count == $1.count }) else {
            return nil
        }
        self.init(outerRing: outerRingPoints, holes: holesPoints)
    }

    /// Initialize a `GeoPolygon`, with values for bottom left corner and top right corner.
    ///
    /// Returns `nil` if the `GeoPoints` representing a polygon (outer ring or holes), don't have at least 4 points.
    /// Returns `nil` if the first and the last `GeoPoint` in a polygon are not the same.
    ///
    /// - Parameter outerRing: The polygon's external (outer) ring.
    /// - Parameter holes: The holes (if any) in the polygon.
    convenience init?(outerRing: [(Double, Double)], holes: [(Double, Double)]...) {
        self.init(outerRing: outerRing, holes: holes.map { $0 })
    }
}

public extension GeoCircle {
    /// Initialize a `GeoCircle`, from its center and radius in radians.
    ///
    /// - Parameter center: Center of the circle.
    /// - Parameter radiusInRadians: The radius of the circle in radians.
    convenience init?(center: (Double, Double), radiusInRadians: Double) {
        guard let centerPoint = GeoPoint(latitude: center.0, longitude: center.1) else {
            return nil
        }
        self.init(center: centerPoint, radiusInRadians: radiusInRadians)
    }

    /// Initialize a `GeoCircle`, from its center and radius.
    ///
    /// - Parameter center: Center of the circle.
    /// - Parameter radius: Radius of the circle.
    convenience init?(center: (Double, Double), radius: Distance) {
        guard let centerPoint = GeoPoint(latitude: center.0, longitude: center.1) else {
            return nil
        }
        self.init(center: centerPoint, radius: radius)
    }
}
