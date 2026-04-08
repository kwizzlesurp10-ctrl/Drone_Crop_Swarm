"""Plant diagnosis using YOLO and SAM2 for multispectral agricultural analysis."""

from typing import Dict, List, Any, Optional, Tuple
import asyncio
from pathlib import Path
import logging

from ultralytics import YOLO
import torch
import numpy as np

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class PlantDiagnosisModel:
    """Plant diagnosis model using YOLOv10 fine-tuned on multispectral agricultural dataset."""

    def __init__(self, model_path: str = "yolov10x-plant-2026.pt"):
        """
        Initialize the plant diagnosis model.

        Args:
            model_path: Path to the fine-tuned YOLO model weights
        """
        self.model_path = model_path
        self.model: Optional[YOLO] = None
        self._initialize_model()

    def _initialize_model(self) -> None:
        """Load the YOLO model."""
        try:
            self.model = YOLO(self.model_path)
            logger.info(f"Successfully loaded model from {self.model_path}")
        except Exception as e:
            logger.error(f"Failed to load model from {self.model_path}: {e}")
            raise

    def _process_yolo_results(self, results: Any) -> List[Dict[str, Any]]:
        """
        Process YOLO detection results into diagnostic format.

        Args:
            results: YOLO model inference results

        Returns:
            List of plant diagnostics with disease info and VRA rates
        """
        diagnostics = []

        for i, result in enumerate(results):
            # Extract detection boxes and class information
            if hasattr(result, 'boxes') and result.boxes is not None:
                boxes = result.boxes

                for j, box in enumerate(boxes):
                    # Get confidence and class predictions
                    confidence = float(box.conf[0]) if hasattr(box, 'conf') else 0.0
                    cls_id = int(box.cls[0]) if hasattr(box, 'cls') else 0

                    # Map class ID to disease type (this mapping should be based on training data)
                    disease_map = {
                        0: "healthy",
                        1: "nutrient_deficiency",
                        2: "fungal_infection",
                        3: "pest_damage",
                        4: "water_stress"
                    }
                    disease = disease_map.get(cls_id, "unknown")

                    # Calculate variable rate application (VRA) based on disease severity
                    # VRA rate is proportional to confidence for deficiency/disease
                    vra_rate = self._calculate_vra_rate(disease, confidence)

                    diagnostic = {
                        "plant_id": len(diagnostics),
                        "disease": disease,
                        "confidence": round(confidence, 3),
                        "vra_rate": round(vra_rate, 2),
                        "bbox": box.xyxy[0].tolist() if hasattr(box, 'xyxy') else None
                    }
                    diagnostics.append(diagnostic)

            # If no detections, return placeholder for compatibility
            if not diagnostics:
                diagnostics.append({
                    "plant_id": 0,
                    "disease": "no_detection",
                    "confidence": 0.0,
                    "vra_rate": 0.0
                })

        return diagnostics

    def _calculate_vra_rate(self, disease: str, confidence: float) -> float:
        """
        Calculate variable rate application based on disease type and confidence.

        Args:
            disease: Detected disease type
            confidence: Model confidence score

        Returns:
            VRA rate (0.0 to 1.0) for fertilizer/treatment application
        """
        # Base rates for different conditions
        vra_base_rates = {
            "healthy": 0.1,  # Minimal application for healthy plants
            "nutrient_deficiency": 0.5,  # Moderate to high fertilizer
            "fungal_infection": 0.7,  # High fungicide application
            "pest_damage": 0.6,  # High pesticide application
            "water_stress": 0.3,  # Irrigation adjustment
            "unknown": 0.2,  # Conservative rate for unknowns
            "no_detection": 0.0
        }

        base_rate = vra_base_rates.get(disease, 0.2)

        # Scale by confidence - higher confidence means more certain treatment needed
        vra_rate = base_rate * confidence

        return min(max(vra_rate, 0.0), 1.0)  # Clamp between 0 and 1

    async def diagnose(self, image_url: str, geo_coords: Optional[Tuple[float, float]] = None) -> Dict[str, Any]:
        """
        Diagnose plants from an image.

        Args:
            image_url: URL or path to the image
            geo_coords: Optional tuple of (latitude, longitude) for georeferencing

        Returns:
            Dictionary containing diagnostics list and metadata
        """
        if self.model is None:
            raise RuntimeError("Model not initialized")

        try:
            # Run inference asynchronously (YOLO runs in executor to avoid blocking)
            loop = asyncio.get_event_loop()
            results = await loop.run_in_executor(None, self.model, image_url)

            # Process results
            diagnostics = self._process_yolo_results(results)

            # Build response
            response = {
                "diagnostics": diagnostics,
                "image_source": image_url,
                "total_plants": len(diagnostics),
                "geo_coords": geo_coords
            }

            logger.info(f"Diagnosed {len(diagnostics)} plants from {image_url}")
            return response

        except Exception as e:
            logger.error(f"Error during diagnosis: {e}")
            raise


# Global model instance (singleton pattern for efficiency)
_model_instance: Optional[PlantDiagnosisModel] = None


async def diagnose_plants(
    image_url: str,
    geo_coords: Optional[Tuple[float, float]] = None,
    model_path: str = "yolov10x-plant-2026.pt"
) -> Dict[str, Any]:
    """
    Diagnose plants from multispectral imagery using YOLOv10.

    This function uses a fine-tuned YOLOv10 model on multispectral agricultural dataset
    to detect plant diseases and calculate variable rate application (VRA) recommendations.

    Args:
        image_url: URL or local path to the image to analyze
        geo_coords: Optional tuple of (latitude, longitude) for georeferencing results
        model_path: Path to the YOLO model weights (default: "yolov10x-plant-2026.pt")

    Returns:
        Dictionary containing:
            - diagnostics: List of detected plants with disease info and VRA rates
            - image_source: Source image URL/path
            - total_plants: Number of plants detected
            - geo_coords: Geographic coordinates if provided

    Example:
        >>> result = await diagnose_plants(
        ...     "field_image.jpg",
        ...     geo_coords=(40.7128, -74.0060)
        ... )
        >>> for plant in result["diagnostics"]:
        ...     print(f"Plant {plant['plant_id']}: {plant['disease']} "
        ...           f"(confidence: {plant['confidence']}, VRA: {plant['vra_rate']})")
    """
    global _model_instance

    # Initialize model singleton if not already done
    if _model_instance is None:
        _model_instance = PlantDiagnosisModel(model_path)

    # Run diagnosis
    return await _model_instance.diagnose(image_url, geo_coords)
