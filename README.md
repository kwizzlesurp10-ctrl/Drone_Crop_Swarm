# AETHERAG-ORBIT API

A FastAPI-based drone telemetry and precision agriculture API with real-time WebSocket communication, AI-powered plant diagnostics, and RTK GPS correction for centimeter-level accuracy.

## Features

- **WebSocket Telemetry Endpoint**: Real-time drone data processing via WebSocket at `/ws/telemetry`
- **AI Plant Diagnostics**: Automated crop health analysis from drone imagery
- **RTK GPS Correction**: Centimeter-level positioning accuracy for precise field mapping
- **Variable Rate Application (VRA)**: Automated prescription map generation for precision agriculture
- **Analytics Integration**: PostHog event tracking for telemetry monitoring
- **Payment Processing**: Stripe integration for subscription and usage-based billing

## Project Structure

```
Drone_Crop_Swarm/
├── main.py                          # FastAPI application entry point
├── ai/
│   ├── __init__.py
│   └── plant_diagnostics.py         # AI-powered plant health analysis
├── geospatial/
│   ├── __init__.py
│   └── rtk.py                       # RTK GPS correction module
├── services/
│   ├── __init__.py
│   └── prescription_map.py          # VRA prescription map generation
├── requirements.txt                 # Python dependencies
├── .env.example                     # Environment configuration template
└── .gitignore
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/kwizzlesurp10-ctrl/Drone_Crop_Swarm.git
cd Drone_Crop_Swarm
```

2. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your actual API keys
```

## Configuration

Create a `.env` file with the following variables:

- `STRIPE_SECRET_KEY`: Your Stripe secret API key
- `POSTHOG_KEY`: Your PostHog project API key
- `API_HOST`: API host address (default: 0.0.0.0)
- `API_PORT`: API port (default: 8000)

## Running the Application

Start the FastAPI server:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at `http://localhost:8000`

API documentation is automatically generated at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## WebSocket Telemetry Endpoint

### Endpoint: `/ws/telemetry`

Connect to the WebSocket endpoint to send real-time telemetry data from drones.

### Expected Input Format

```json
{
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "altitude": 100.5
  },
  "rtk_offset": {
    "lat_offset": 0.00001,
    "lon_offset": -0.00001,
    "alt_offset": 0.02,
    "horizontal_accuracy_cm": 2.0,
    "vertical_accuracy_cm": 3.0
  },
  "image_url": "https://example.com/drone_image.jpg",
  "acres": 12.5
}
```

### Response Format

```json
{
  "status": "processed",
  "xai_contrib": "12% activated"
}
```

### Processing Pipeline

1. **RTK Correction**: Raw GPS coordinates are corrected using RTK offsets for centimeter-level accuracy
2. **Plant Diagnostics**: AI analyzes the drone imagery to identify crop health issues
3. **Prescription Map Generation**: Variable rate application maps are created based on diagnostics
4. **Analytics Tracking**: Telemetry events are logged to PostHog
5. **Response**: Client receives confirmation with processing status

## API Modules

### AI Plant Diagnostics (`ai/plant_diagnostics.py`)

Analyzes drone imagery to diagnose:
- Plant health scores
- Nutrient deficiencies
- Disease detection
- Treatment recommendations

### RTK GPS Correction (`geospatial/rtk.py`)

Applies Real-Time Kinematic corrections to achieve:
- Centimeter-level horizontal accuracy (1-2 cm)
- Centimeter-level vertical accuracy (2-3 cm)
- Improved field boundary mapping

### Prescription Map Generation (`services/prescription_map.py`)

Creates Variable Rate Application (VRA) maps with:
- Zone-based treatment recommendations
- Optimized input application rates
- Cost savings estimates
- Georeferenced prescription zones

## Development

### Running Tests

```bash
pytest
```

### Code Formatting

```bash
black .
```

### Linting

```bash
flake8 .
```

## Technology Stack

- **FastAPI**: Modern, fast web framework for building APIs
- **WebSockets**: Real-time bidirectional communication
- **Stripe**: Payment processing
- **PostHog**: Product analytics and event tracking
- **Uvicorn**: ASGI server implementation

## Future Enhancements

- Database integration (PostgreSQL with PostGIS for geospatial data)
- Fleet management endpoints
- Mission planning and scheduling
- Historical analytics dashboard
- Multi-tenant support with farm-level isolation
- Advanced computer vision models for plant diagnostics
- Integration with agricultural equipment APIs

## License

MIT License

## Support

For issues and questions, please open an issue on GitHub.