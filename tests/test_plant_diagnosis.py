"""Unit tests for plant diagnosis functionality."""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys


# Mock all external dependencies before importing
sys.modules['ultralytics'] = MagicMock()
sys.modules['torch'] = MagicMock()
sys.modules['numpy'] = MagicMock()
sys.modules['cv2'] = MagicMock()
sys.modules['PIL'] = MagicMock()

from src.plant_diagnosis import PlantDiagnosisModel


class TestPlantDiagnosisModel:
    """Test cases for PlantDiagnosisModel class."""

    def test_calculate_vra_rate_healthy(self):
        """Test VRA calculation for healthy plants."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            vra_rate = model._calculate_vra_rate("healthy", 0.9)
            assert 0.0 <= vra_rate <= 0.2  # Low rate for healthy plants

    def test_calculate_vra_rate_nutrient_deficiency(self):
        """Test VRA calculation for nutrient deficiency."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            vra_rate = model._calculate_vra_rate("nutrient_deficiency", 0.98)
            assert 0.4 <= vra_rate <= 0.6  # Moderate to high rate

    def test_calculate_vra_rate_fungal_infection(self):
        """Test VRA calculation for fungal infection."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            vra_rate = model._calculate_vra_rate("fungal_infection", 0.95)
            assert 0.6 <= vra_rate <= 0.8  # High rate for fungal

    def test_calculate_vra_rate_bounds(self):
        """Test that VRA rate is clamped between 0 and 1."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            # Test upper bound
            vra_rate = model._calculate_vra_rate("fungal_infection", 1.5)
            assert vra_rate <= 1.0
            # Test lower bound
            vra_rate = model._calculate_vra_rate("healthy", 0.0)
            assert vra_rate >= 0.0

    def test_calculate_vra_rate_unknown(self):
        """Test VRA calculation for unknown disease."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            vra_rate = model._calculate_vra_rate("unknown", 0.5)
            assert 0.0 <= vra_rate <= 0.2  # Conservative rate

    def test_calculate_vra_rate_no_detection(self):
        """Test VRA calculation when no detection."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            vra_rate = model._calculate_vra_rate("no_detection", 0.0)
            assert vra_rate == 0.0

    def test_process_yolo_results_empty(self):
        """Test processing empty YOLO results."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            mock_result = Mock()
            mock_result.boxes = None
            results = [mock_result]

            diagnostics = model._process_yolo_results(results)

            # Should return no_detection placeholder
            assert len(diagnostics) >= 1
            assert diagnostics[0]["disease"] == "no_detection"
            assert diagnostics[0]["confidence"] == 0.0

    def test_model_path_attribute(self):
        """Test that model path is stored correctly."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel("custom_path.pt")
            assert model.model_path == "custom_path.pt"

    def test_vra_rates_for_all_disease_types(self):
        """Test VRA calculation for all disease types."""
        with patch('src.plant_diagnosis.YOLO'):
            model = PlantDiagnosisModel()
            diseases = [
                ("healthy", 0.1),
                ("nutrient_deficiency", 0.5),
                ("fungal_infection", 0.7),
                ("pest_damage", 0.6),
                ("water_stress", 0.3)
            ]

            for disease, expected_base in diseases:
                vra_rate = model._calculate_vra_rate(disease, 1.0)
                # With confidence 1.0, rate should equal base rate
                assert abs(vra_rate - expected_base) < 0.01


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
