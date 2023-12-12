/// Template class
class Template {
  static const String binary = '''
    {
        "GlobalParameter":{
            "Name":"GP"
        },
        "ImageParameterArray":[
            {
                "Name":"IP-1",
                "NormalizerParameterName":"NP-1",
                "BinarizationModes":[{"Mode":"BM_LOCAL_BLOCK", "ThresholdCompensation":10}],
                "ScaleDownThreshold":2300
            }
        ],
        "NormalizerParameterArray":[
            {
                "Name":"NP-1",
                "ColourMode": "ICM_BINARY" 
            }
        ]
    }
    ''';

  static const String color = '''
    {
        "GlobalParameter":{
            "Name":"GP"
        },
        "ImageParameterArray":[
            {
                "Name":"IP-1",
                "NormalizerParameterName":"NP-1",
                "BinarizationModes":[{"Mode":"BM_LOCAL_BLOCK", "ThresholdCompensation":10}],
                "ScaleDownThreshold":2300
            }
        ],
        "NormalizerParameterArray":[
            {
                "Name":"NP-1",
                "ColourMode": "ICM_COLOUR" 
            }
        ]
    }
    ''';

  static const String grayscale = '''
    {
        "GlobalParameter":{
            "Name":"GP"
        },
        "ImageParameterArray":[
            {
                "Name":"IP-1",
                "NormalizerParameterName":"NP-1",
                "BinarizationModes":[{"Mode":"BM_LOCAL_BLOCK", "ThresholdCompensation":10}],
                "ScaleDownThreshold":2300
            }
        ],
        "NormalizerParameterArray":[
            {
                "Name":"NP-1",
                "ColourMode": "ICM_GRAYSCALE"
            }
        ]
    }
    ''';
}
