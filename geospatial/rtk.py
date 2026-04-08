"""
RTK (Real-Time Kinematic) GPS correction module.
Provides centimeter-level accuracy for drone positioning.
"""
from typing import Dict, Tuple


def apply_rtk_correction(location: Dict[str, float], rtk_offset: Dict[str, float]) -> Dict[str, float]:
    """
    Apply RTK correction to raw GPS coordinates.

    RTK GPS provides centimeter-level accuracy by using a fixed base station
    to calculate corrections for atmospheric errors and other GPS inaccuracies.

    Args:
        location: Raw GPS location with 'latitude' and 'longitude' keys
        rtk_offset: RTK correction offsets with 'lat_offset' and 'lon_offset' keys

    Returns:
        Corrected GPS coordinates with improved accuracy
    """
    corrected_location = {
        "latitude": location["latitude"] + rtk_offset.get("lat_offset", 0.0),
        "longitude": location["longitude"] + rtk_offset.get("lon_offset", 0.0),
        "altitude": location.get("altitude", 0.0) + rtk_offset.get("alt_offset", 0.0),
        "accuracy": "rtk_corrected",  # Typically 1-2 cm accuracy
        "horizontal_accuracy_cm": rtk_offset.get("horizontal_accuracy_cm", 2.0),
        "vertical_accuracy_cm": rtk_offset.get("vertical_accuracy_cm", 3.0)
    }

    return corrected_location
