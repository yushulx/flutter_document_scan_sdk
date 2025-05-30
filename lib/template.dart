/// Template class
class Template {
  static const String binary = '''
    {
    "CaptureVisionTemplates": [
        {
            "Name": "DetectAndNormalizeDocument_Default",
            "ImageROIProcessingNameArray": [
                "roi-detect-and-normalize-document"
            ]
        },
        {
            "Name": "DetectDocumentBoundaries_Default",
            "ImageROIProcessingNameArray": [
                "roi-detect-document-boundaries"
            ]
        },
        {
            "Name": "NormalizeDocument_Default",
            "ImageROIProcessingNameArray": [
                "roi-normalize-document"
            ]
        }
    ],
    "TargetROIDefOptions": [
        {
            "Name": "roi-detect-and-normalize-document",
            "TaskSettingNameArray": [
                "task-detect-and-normalize-document"
            ]
        },
        {
            "Name": "roi-detect-document-boundaries",
            "TaskSettingNameArray": [
                "task-detect-document-boundaries"
            ]
        },
        {
            "Name": "roi-normalize-document",
            "TaskSettingNameArray": [
                "task-normalize-document"
            ]
        }
    ],
    "DocumentNormalizerTaskSettingOptions": [
        {
            "Name": "task-detect-and-normalize-document",
            "SectionArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_PREDETECT_REGIONS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DETECTION",
                    "ContentType": "CT_DOCUMENT",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ASSEMBLE_LONG_LINES"
                        },
                        {
                            "Stage": "SST_ASSEMBLE_LOGICAL_LINES"
                        },
                        {
                            "Stage": "SST_DETECT_CORNERS"
                        },
                        {
                            "Stage": "SST_DETECT_EDGES"
                        },
                        {
                            "Stage": "SST_DETECT_QUADS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DESKEWING",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_DESKEW_IMAGE"
                        }
                    ]
                },
                {
                    "Section": "ST_IMAGE_ENHANCEMENT",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ENHANCE_IMAGE"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "task-detect-document-boundaries",
            "SectionArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-detect",
                    "StageArray": [
                        {
                            "Stage": "SST_PREDETECT_REGIONS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DETECTION",
                    "ContentType": "CT_DOCUMENT",
                    "ImageParameterName": "ip-detect",
                    "StageArray": [
                        {
                            "Stage": "SST_ASSEMBLE_LONG_LINES"
                        },
                        {
                            "Stage": "SST_ASSEMBLE_LOGICAL_LINES"
                        },
                        {
                            "Stage": "SST_DETECT_CORNERS"
                        },
                        {
                            "Stage": "SST_DETECT_EDGES"
                        },
                        {
                            "Stage": "SST_DETECT_QUADS"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "task-normalize-document",
            "SectionArray": [
                {
                    "Section": "ST_DOCUMENT_DESKEWING",
                    "ImageParameterName": "ip-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_DESKEW_IMAGE"
                        }
                    ]
                },
                {
                    "Section": "ST_IMAGE_ENHANCEMENT",
                    "ImageParameterName": "ip-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ENHANCE_IMAGE",
                            "ColourMode": "ICM_BINARY"
                        }
                    ]
                }
            ]
        }
    ],
    "ImageParameterOptions": [
        {
            "Name": "ip-detect-and-normalize",
            "ApplicableStages": [
                {
                    "Stage": "SST_CONVERT_TO_GRAYSCALE",
                    "ColourConversionModes": [
                        {
                            "Mode": "CICM_GENERAL"
                        },
                        {
                            "Mode": "CICM_EDGE_ENHANCEMENT"
                        },
                        {
                            "Mode": "CICM_HSV",
                            "ReferChannel": "H_CHANNEL"
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                },
                {
                    "Stage": "SST_DETECT_TEXTURE",
                    "TextureDetectionModes": [
                        {
                            "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                            "Sensitivity": 8
                        }
                    ]
                }
            ]
        },
        {
            "Name": "ip-detect",
            "ApplicableStages": [
                {
                    "Stage": "SST_CONVERT_TO_GRAYSCALE",
                    "ColourConversionModes": [
                        {
                            "Mode": "CICM_GENERAL"
                        },
                        {
                            "Mode": "CICM_EDGE_ENHANCEMENT"
                        },
                        {
                            "Mode": "CICM_HSV",
                            "ReferChannel": "H_CHANNEL"
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                },
                {
                    "Stage": "SST_DETECT_TEXTURE",
                    "TextureDetectionModes": [
                        {
                            "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                            "Sensitivity": 8
                        }
                    ]
                }
            ]
        },
        {
            "Name": "ip-normalize",
            "ApplicableStages": [
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 0,
                            "BlockSizeY": 0,
                            "EnableFillBinaryVacancy": 0
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 0,
                            "BlockSizeY": 0,
                            "EnableFillBinaryVacancy": 0
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                }
            ]
        }
    ]
}
    ''';

  static const String color = '''
    {
    "CaptureVisionTemplates": [
        {
            "Name": "DetectAndNormalizeDocument_Default",
            "ImageROIProcessingNameArray": [
                "roi-detect-and-normalize-document"
            ]
        },
        {
            "Name": "DetectDocumentBoundaries_Default",
            "ImageROIProcessingNameArray": [
                "roi-detect-document-boundaries"
            ]
        },
        {
            "Name": "NormalizeDocument_Default",
            "ImageROIProcessingNameArray": [
                "roi-normalize-document"
            ]
        }
    ],
    "TargetROIDefOptions": [
        {
            "Name": "roi-detect-and-normalize-document",
            "TaskSettingNameArray": [
                "task-detect-and-normalize-document"
            ]
        },
        {
            "Name": "roi-detect-document-boundaries",
            "TaskSettingNameArray": [
                "task-detect-document-boundaries"
            ]
        },
        {
            "Name": "roi-normalize-document",
            "TaskSettingNameArray": [
                "task-normalize-document"
            ]
        }
    ],
    "DocumentNormalizerTaskSettingOptions": [
        {
            "Name": "task-detect-and-normalize-document",
            "SectionArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_PREDETECT_REGIONS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DETECTION",
                    "ContentType": "CT_DOCUMENT",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ASSEMBLE_LONG_LINES"
                        },
                        {
                            "Stage": "SST_ASSEMBLE_LOGICAL_LINES"
                        },
                        {
                            "Stage": "SST_DETECT_CORNERS"
                        },
                        {
                            "Stage": "SST_DETECT_EDGES"
                        },
                        {
                            "Stage": "SST_DETECT_QUADS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DESKEWING",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_DESKEW_IMAGE"
                        }
                    ]
                },
                {
                    "Section": "ST_IMAGE_ENHANCEMENT",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ENHANCE_IMAGE"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "task-detect-document-boundaries",
            "SectionArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-detect",
                    "StageArray": [
                        {
                            "Stage": "SST_PREDETECT_REGIONS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DETECTION",
                    "ContentType": "CT_DOCUMENT",
                    "ImageParameterName": "ip-detect",
                    "StageArray": [
                        {
                            "Stage": "SST_ASSEMBLE_LONG_LINES"
                        },
                        {
                            "Stage": "SST_ASSEMBLE_LOGICAL_LINES"
                        },
                        {
                            "Stage": "SST_DETECT_CORNERS"
                        },
                        {
                            "Stage": "SST_DETECT_EDGES"
                        },
                        {
                            "Stage": "SST_DETECT_QUADS"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "task-normalize-document",
            "SectionArray": [
                {
                    "Section": "ST_DOCUMENT_DESKEWING",
                    "ImageParameterName": "ip-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_DESKEW_IMAGE"
                        }
                    ]
                },
                {
                    "Section": "ST_IMAGE_ENHANCEMENT",
                    "ImageParameterName": "ip-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ENHANCE_IMAGE",
                            "ColourMode": "ICM_COLOUR"
                        }
                    ]
                }
            ]
        }
    ],
    "ImageParameterOptions": [
        {
            "Name": "ip-detect-and-normalize",
            "ApplicableStages": [
                {
                    "Stage": "SST_CONVERT_TO_GRAYSCALE",
                    "ColourConversionModes": [
                        {
                            "Mode": "CICM_GENERAL"
                        },
                        {
                            "Mode": "CICM_EDGE_ENHANCEMENT"
                        },
                        {
                            "Mode": "CICM_HSV",
                            "ReferChannel": "H_CHANNEL"
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                },
                {
                    "Stage": "SST_DETECT_TEXTURE",
                    "TextureDetectionModes": [
                        {
                            "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                            "Sensitivity": 8
                        }
                    ]
                }
            ]
        },
        {
            "Name": "ip-detect",
            "ApplicableStages": [
                {
                    "Stage": "SST_CONVERT_TO_GRAYSCALE",
                    "ColourConversionModes": [
                        {
                            "Mode": "CICM_GENERAL"
                        },
                        {
                            "Mode": "CICM_EDGE_ENHANCEMENT"
                        },
                        {
                            "Mode": "CICM_HSV",
                            "ReferChannel": "H_CHANNEL"
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                },
                {
                    "Stage": "SST_DETECT_TEXTURE",
                    "TextureDetectionModes": [
                        {
                            "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                            "Sensitivity": 8
                        }
                    ]
                }
            ]
        },
        {
            "Name": "ip-normalize",
            "ApplicableStages": [
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 0,
                            "BlockSizeY": 0,
                            "EnableFillBinaryVacancy": 0
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 0,
                            "BlockSizeY": 0,
                            "EnableFillBinaryVacancy": 0
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                }
            ]
        }
    ]
}
    ''';

  static const String grayscale = '''
    {
    "CaptureVisionTemplates": [
        {
            "Name": "DetectAndNormalizeDocument_Default",
            "ImageROIProcessingNameArray": [
                "roi-detect-and-normalize-document"
            ]
        },
        {
            "Name": "DetectDocumentBoundaries_Default",
            "ImageROIProcessingNameArray": [
                "roi-detect-document-boundaries"
            ]
        },
        {
            "Name": "NormalizeDocument_Default",
            "ImageROIProcessingNameArray": [
                "roi-normalize-document"
            ]
        }
    ],
    "TargetROIDefOptions": [
        {
            "Name": "roi-detect-and-normalize-document",
            "TaskSettingNameArray": [
                "task-detect-and-normalize-document"
            ]
        },
        {
            "Name": "roi-detect-document-boundaries",
            "TaskSettingNameArray": [
                "task-detect-document-boundaries"
            ]
        },
        {
            "Name": "roi-normalize-document",
            "TaskSettingNameArray": [
                "task-normalize-document"
            ]
        }
    ],
    "DocumentNormalizerTaskSettingOptions": [
        {
            "Name": "task-detect-and-normalize-document",
            "SectionArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_PREDETECT_REGIONS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DETECTION",
                    "ContentType": "CT_DOCUMENT",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ASSEMBLE_LONG_LINES"
                        },
                        {
                            "Stage": "SST_ASSEMBLE_LOGICAL_LINES"
                        },
                        {
                            "Stage": "SST_DETECT_CORNERS"
                        },
                        {
                            "Stage": "SST_DETECT_EDGES"
                        },
                        {
                            "Stage": "SST_DETECT_QUADS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DESKEWING",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_DESKEW_IMAGE"
                        }
                    ]
                },
                {
                    "Section": "ST_IMAGE_ENHANCEMENT",
                    "ImageParameterName": "ip-detect-and-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ENHANCE_IMAGE"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "task-detect-document-boundaries",
            "SectionArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-detect",
                    "StageArray": [
                        {
                            "Stage": "SST_PREDETECT_REGIONS"
                        }
                    ]
                },
                {
                    "Section": "ST_DOCUMENT_DETECTION",
                    "ContentType": "CT_DOCUMENT",
                    "ImageParameterName": "ip-detect",
                    "StageArray": [
                        {
                            "Stage": "SST_ASSEMBLE_LONG_LINES"
                        },
                        {
                            "Stage": "SST_ASSEMBLE_LOGICAL_LINES"
                        },
                        {
                            "Stage": "SST_DETECT_CORNERS"
                        },
                        {
                            "Stage": "SST_DETECT_EDGES"
                        },
                        {
                            "Stage": "SST_DETECT_QUADS"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "task-normalize-document",
            "SectionArray": [
                {
                    "Section": "ST_DOCUMENT_DESKEWING",
                    "ImageParameterName": "ip-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_DESKEW_IMAGE"
                        }
                    ]
                },
                {
                    "Section": "ST_IMAGE_ENHANCEMENT",
                    "ImageParameterName": "ip-normalize",
                    "StageArray": [
                        {
                            "Stage": "SST_ENHANCE_IMAGE",
                            "ColourMode": "ICM_GRAYSCALE"
                        }
                    ]
                }
            ]
        }
    ],
    "ImageParameterOptions": [
        {
            "Name": "ip-detect-and-normalize",
            "ApplicableStages": [
                {
                    "Stage": "SST_CONVERT_TO_GRAYSCALE",
                    "ColourConversionModes": [
                        {
                            "Mode": "CICM_GENERAL"
                        },
                        {
                            "Mode": "CICM_EDGE_ENHANCEMENT"
                        },
                        {
                            "Mode": "CICM_HSV",
                            "ReferChannel": "H_CHANNEL"
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                },
                {
                    "Stage": "SST_DETECT_TEXTURE",
                    "TextureDetectionModes": [
                        {
                            "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                            "Sensitivity": 8
                        }
                    ]
                }
            ]
        },
        {
            "Name": "ip-detect",
            "ApplicableStages": [
                {
                    "Stage": "SST_CONVERT_TO_GRAYSCALE",
                    "ColourConversionModes": [
                        {
                            "Mode": "CICM_GENERAL"
                        },
                        {
                            "Mode": "CICM_EDGE_ENHANCEMENT"
                        },
                        {
                            "Mode": "CICM_HSV",
                            "ReferChannel": "H_CHANNEL"
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 25,
                            "BlockSizeY": 25,
                            "EnableFillBinaryVacancy": 0,
                            "ThresholdCompensation": 5
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                },
                {
                    "Stage": "SST_DETECT_TEXTURE",
                    "TextureDetectionModes": [
                        {
                            "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                            "Sensitivity": 8
                        }
                    ]
                }
            ]
        },
        {
            "Name": "ip-normalize",
            "ApplicableStages": [
                {
                    "Stage": "SST_BINARIZE_IMAGE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 0,
                            "BlockSizeY": 0,
                            "EnableFillBinaryVacancy": 0
                        }
                    ]
                },
                {
                    "Stage": "SST_BINARIZE_TEXTURE_REMOVED_GRAYSCALE",
                    "BinarizationModes": [
                        {
                            "Mode": "BM_LOCAL_BLOCK",
                            "BlockSizeX": 0,
                            "BlockSizeY": 0,
                            "EnableFillBinaryVacancy": 0
                        }
                    ]
                },
                {
                    "Stage": "SST_DETECT_TEXT_ZONES",
                    "TextDetectionMode": {
                        "Mode": "TTDM_WORD",
                        "Direction": "HORIZONTAL",
                        "Sensitivity": 7
                    }
                }
            ]
        }
    ]
}
    ''';
}
