"""Tests for plant diagnosis functionality."""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
from src.plant_diagnosis import diagnose_plants, PlantDiagnosisModel


class TestPlantDiagnosisModel:
    """Test cases for PlantDiagnosisModel class."""

    @patch('src.plant_diagnosis.YOLO')
    def test_model_initialization(self, mock_yolo):
        """Test that model initializes correctly."""
        model = PlantDiagnosisModel("test_model.pt")
        mock_yolo.assert_called_once_with("test_model.pt")
        assert model.model_path == "test_model.pt"

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


class TestDiagnosePlantsFunction:
    """Test cases for diagnose_plants async function."""

    @pytest.mark.asyncio
    @patch('src.plant_diagnosis.YOLO')
    async def test_diagnose_plants_basic(self, mock_yolo):
        """Test basic plant diagnosis."""
        # Mock YOLO results
        mock_result = Mock()
        mock_box = Mock()
        mock_box.conf = [0.98]
        mock_box.cls = [1]  # nutrient_deficiency
        mock_box.xyxy = [[10.0, 20.0, 100.0, 200.0]]
        mock_result.boxes = [mock_box]

        mock_model_instance = Mock()
        mock_model_instance.return_value = [mock_result]
        mock_yolo.return_value = mock_model_instance

        # Run diagnosis
        result = await diagnose_plants(
            image_url="test_image.jpg",
            geo_coords=(40.0, -74.0)
        )

        # Verify results
        assert "diagnostics" in result
        assert "image_source" in result
        assert "total_plants" in result
        assert "geo_coords" in result
        assert result["image_source"] == "test_image.jpg"
        assert result["geo_coords"] == (40.0, -74.0)
        assert len(result["diagnostics"]) > 0

    @pytest.mark.asyncio
    @patch('src.plant_diagnosis.YOLO')
    async def test_diagnose_plants_no_coords(self, mock_yolo):
        """Test diagnosis without geo coordinates."""
        mock_result = Mock()
        mock_result.boxes = None

        mock_model_instance = Mock()
        mock_model_instance.return_value = [mock_result]
        mock_yolo.return_value = mock_model_instance

        result = await diagnose_plants(image_url="test_image.jpg")

        assert result["geo_coords"] is None

    @pytest.mark.asyncio
    @patch('src.plant_diagnosis.YOLO')
    async def test_diagnose_plants_custom_model(self, mock_yolo):
        """Test diagnosis with custom model path."""
        mock_result = Mock()
        mock_result.boxes = None

        mock_model_instance = Mock()
        mock_model_instance.return_value = [mock_result]
        mock_yolo.return_value = mock_model_instance

        result = await diagnose_plants(
            image_url="test.jpg",
            model_path="custom_model.pt"
        )

        assert result is not None
        assert "diagnostics" in result


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
