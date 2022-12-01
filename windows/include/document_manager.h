#ifndef DOCUMENT_MANAGER_H_
#define DOCUMENT_MANAGER_H_

#include "DynamsoftCore.h"
#include "DynamsoftDocumentNormalizer.h"


#include <vector>
#include <iostream>
#include <map>

#include <flutter/standard_method_codec.h>

using namespace std;
using namespace dynamsoft::ddn;
using namespace dynamsoft::core;

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::EncodableList;

class DocumentManager {
    public:

    ~DocumentManager() 
    {
        if (normalizer != NULL)
        {
            DDN_DestroyInstance(normalizer);
            normalizer = NULL;
        }

        if (imageResult != NULL)
        {
            delete imageResult;
            imageResult = NULL;
        }
    };

    const char* GetVersion() 
    {
        return DDN_GetVersion();
    }

    void Init() 
    {
        normalizer = DDN_CreateInstance();
        imageResult = NULL;
    }

    int SetParameters(const char * params) 
    {
        int ret = 0;

        if (normalizer)
        {
            char errorMsgBuffer[512];
			ret = DDN_InitRuntimeSettingsFromString(normalizer, params, errorMsgBuffer, 512);
            if (ret != DM_OK)
            {
                cout << errorMsgBuffer << endl;
            }
        }

        return ret;
    }

    static int SetLicense(const char * license) 
    {
        char errorMsgBuffer[512];
		// Click https://www.dynamsoft.com/customer/license/trialLicense/?product=ddn to get a trial license.
		int ret = DC_InitLicense(license, errorMsgBuffer, 512);
		if (ret != DM_OK)
        {
            cout << errorMsgBuffer << endl;
        }
        return ret;
    }

    EncodableList Detect(const char * filename) 
    {
        EncodableList out;   
        if (normalizer == NULL) return out;

        DetectedQuadResultArray *pResults = NULL;
    
        int ret = DDN_DetectQuadFromFile(normalizer, filename, "", &pResults);
        if (ret)
        {
            printf("Detection error: %s\n", DC_GetErrorString(ret));
        }

        if (pResults)
        {
            int count = pResults->resultsCount;
        
            for (int i = 0; i < count; i++)
            {
                EncodableMap map;

                DetectedQuadResult *quadResult = pResults->detectedQuadResults[i];
                int confidence = quadResult->confidenceAsDocumentBoundary;
                DM_Point *points = quadResult->location->points;
                int x1 = points[0].coordinate[0];
                int y1 = points[0].coordinate[1];
                int x2 = points[1].coordinate[0];
                int y2 = points[1].coordinate[1];
                int x3 = points[2].coordinate[0];
                int y3 = points[2].coordinate[1];
                int x4 = points[3].coordinate[0];
                int y4 = points[3].coordinate[1];
                
                map[EncodableValue("confidence")] = EncodableValue(confidence);
                map[EncodableValue("x1")] = EncodableValue(x1);
                map[EncodableValue("y1")] = EncodableValue(y1);
                map[EncodableValue("x2")] = EncodableValue(x2);
                map[EncodableValue("y2")] = EncodableValue(y2);
                map[EncodableValue("x3")] = EncodableValue(x3);
                map[EncodableValue("y3")] = EncodableValue(y3);
                map[EncodableValue("x4")] = EncodableValue(x4);
                map[EncodableValue("y4")] = EncodableValue(y4);
                out.push_back(map);
            }
        }

        if (pResults != NULL)
            DDN_FreeDetectedQuadResultArray(&pResults);

        return out;
    }

    EncodableMap Normalize(const char * filename, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4) {
        EncodableMap map;

        return map; 
    }

    EncodableValue GetParameters()
    {
        EncodableValue out;
        if (normalizer == NULL) return out;

        char* content = NULL;
        DDN_OutputRuntimeSettingsToString(normalizer, "", &content);
        EncodableValue params = EncodableValue((const char*)content);
        if (content != NULL)
            DDN_FreeString(&content);
        return out;
    }

    int Save(const char * filename) 
    {
        if (imageResult == NULL) return -1;
        int ret = NormalizedImageResult_SaveToFile(imageResult, filename);
		if (ret != DM_OK)
			printf("NormalizedImageResult_SaveToFile: %s\r\n", DC_GetErrorString(ret));

        return ret;
    }

    private:
        void *normalizer; 
        NormalizedImageResult *imageResult;
};

#endif 