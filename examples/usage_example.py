"""Example usage of the plant diagnosis system."""

import asyncio
from src.plant_diagnosis import diagnose_plants


async def main():
    """Demonstrate basic usage of the plant diagnosis function."""

    # Example 1: Diagnose from local image
    print("Example 1: Basic diagnosis")
    result = await diagnose_plants(
        image_url="path/to/field_image.jpg",
        geo_coords=(40.7128, -74.0060)  # Example coordinates (NYC)
    )

    print(f"Total plants detected: {result['total_plants']}")
    print(f"Location: {result['geo_coords']}")
    print("\nDiagnostics:")
    for plant in result["diagnostics"]:
        print(f"  Plant {plant['plant_id']}: {plant['disease']}")
        print(f"    Confidence: {plant['confidence']:.2%}")
        print(f"    VRA Rate: {plant['vra_rate']:.2f}")
        if plant.get('bbox'):
            print(f"    Bounding box: {plant['bbox']}")
    print()

    # Example 2: Diagnose from URL
    print("Example 2: Diagnosis from URL")
    result2 = await diagnose_plants(
        image_url="https://example.com/drone_image.jpg",
        geo_coords=(34.0522, -118.2437)  # Los Angeles
    )

    print(f"Detected {result2['total_plants']} plants")
    print()

    # Example 3: Custom model path
    print("Example 3: Using custom model")
    result3 = await diagnose_plants(
        image_url="field_scan.png",
        model_path="models/custom_yolo_model.pt"
    )

    print(f"Analysis complete: {result3['total_plants']} plants analyzed")


if __name__ == "__main__":
    asyncio.run(main())
