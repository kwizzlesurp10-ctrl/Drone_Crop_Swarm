/**
 * AI Package - YOLOv10 + SAM2 Plant Diagnostics
 *
 * This package provides TypeScript types and utilities for interfacing
 * with the Python-based AI models running in the FastAPI backend.
 */

export interface Detection {
  class: string;
  confidence: number;
  bbox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export interface SegmentationMask {
  mask: number[][];
  score: number;
}

export interface PlantDiagnostics {
  detections: Detection[];
  segmentation: SegmentationMask[];
  healthScore: number;
  diseases: string[];
  recommendations: string[];
}

export interface AnalysisRequest {
  imageUrl: string;
  modelType: 'yolov10' | 'sam2' | 'both';
  confidenceThreshold?: number;
}

export interface AnalysisResponse {
  success: boolean;
  diagnostics?: PlantDiagnostics;
  error?: string;
}
