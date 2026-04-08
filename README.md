# Drone_Crop_Swarm

Autonomous drone system for crop monitoring and plant disease diagnosis using multispectral imaging and AI.

## Overview

This project provides an AI-powered plant diagnosis system that uses YOLOv10 fine-tuned on multispectral agricultural datasets to detect plant diseases and recommend variable rate application (VRA) for precision agriculture.

## Features

- **Plant Disease Detection**: Uses YOLOv10 model fine-tuned on multispectral agricultural data
- **Async API**: Non-blocking async/await interface for efficient processing
- **Geolocation Support**: Associate diagnoses with GPS coordinates for mapping
- **VRA Recommendations**: Automatic calculation of variable rate application rates
- **Multiple Disease Classes**: Detects healthy plants, nutrient deficiencies, fungal infections, pest damage, and water stress

## Installation

```bash
pip install -r requirements.txt
```

## Requirements

- Python 3.8+
- PyTorch 2.0+
- Ultralytics YOLO
- YOLOv10 model weights (`yolov10x-plant-2026.pt`)

## Usage

### Basic Example

```python
import asyncio
from src.plant_diagnosis import diagnose_plants

async def main():
    # Diagnose plants from an image
    result = await diagnose_plants(
        image_url="path/to/field_image.jpg",
        geo_coords=(40.7128, -74.0060)  # latitude, longitude
    )

    # Process results
    for plant in result["diagnostics"]:
        print(f"Plant {plant['plant_id']}: {plant['disease']}")
        print(f"  Confidence: {plant['confidence']:.2%}")
        print(f"  VRA Rate: {plant['vra_rate']:.2f}")

asyncio.run(main())
```

### Advanced Usage

```python
# Use custom model path
result = await diagnose_plants(
    image_url="drone_capture.jpg",
    geo_coords=(34.0522, -118.2437),
    model_path="models/custom_model.pt"
)
```

## API Reference

### `diagnose_plants(image_url, geo_coords=None, model_path="yolov10x-plant-2026.pt")`

Diagnose plants from multispectral imagery.

**Parameters:**
- `image_url` (str): Path or URL to the image
- `geo_coords` (tuple, optional): (latitude, longitude) coordinates
- `model_path` (str): Path to YOLO model weights

**Returns:**
- Dictionary containing:
  - `diagnostics`: List of plant diagnostics
  - `image_source`: Source image path/URL
  - `total_plants`: Number of detected plants
  - `geo_coords`: Geographic coordinates (if provided)

**Diagnostic Object:**
Each diagnostic contains:
- `plant_id`: Unique identifier for the plant
- `disease`: Detected condition (e.g., "nutrient_deficiency")
- `confidence`: Model confidence score (0.0 to 1.0)
- `vra_rate`: Recommended variable rate application (0.0 to 1.0)
- `bbox`: Bounding box coordinates [x1, y1, x2, y2]

## Disease Classes

- `healthy`: No issues detected
- `nutrient_deficiency`: Nitrogen, phosphorus, or potassium deficiency
- `fungal_infection`: Fungal disease present
- `pest_damage`: Insect or pest damage
- `water_stress`: Drought or overwatering stress

## VRA (Variable Rate Application)

VRA rates range from 0.0 to 1.0 and indicate the recommended treatment intensity:
- **0.0-0.2**: Minimal or no treatment needed
- **0.2-0.5**: Moderate treatment recommended
- **0.5-0.8**: High treatment intensity
- **0.8-1.0**: Maximum treatment required

## Model Information

The system uses YOLOv10x fine-tuned on multispectral agricultural datasets. Ensure you have the model weights file (`yolov10x-plant-2026.pt`) in the appropriate location.

## Examples

See the `examples/` directory for more detailed usage examples.

## License

MIT License

## Contributing

Contributions welcome! Please submit issues and pull requests.
