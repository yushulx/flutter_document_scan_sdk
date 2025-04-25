#ifndef DOCUMENT_MANAGER_H_
#define DOCUMENT_MANAGER_H_

#include "DynamsoftCaptureVisionRouter.h"
#include "DynamsoftUtility.h"

#include <vector>
#include <iostream>
#include <map>

#include <flutter/standard_method_codec.h>

#include <thread>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <functional>

using namespace std;
using namespace dynamsoft::ddn;
using namespace dynamsoft::license;
using namespace dynamsoft::cvr;
using namespace dynamsoft::utility;
using namespace dynamsoft::basic_structures;

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// Define as inline to avoid multiple definition errors
inline void printf_to_cerr(const char *format, ...)
{
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    std::cerr << buffer;
}

// Define printf to use our custom function
#define printf printf_to_cerr

class MyCapturedResultReceiver : public CCapturedResultReceiver
{
public:
    vector<CCapturedResult *> results;
    mutex results_mutex;

public:
    void OnCapturedResultReceived(CCapturedResult *pResult) override
    {
        pResult->Retain();
        std::lock_guard<std::mutex> lock(results_mutex);
        results.push_back(pResult);
    }
};

class MyImageSourceStateListener : public CImageSourceStateListener
{
private:
    CCaptureVisionRouter *m_router;
    MyCapturedResultReceiver *m_receiver;

public:
    vector<std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>> pendingResults = {};

    MyImageSourceStateListener(CCaptureVisionRouter *router, MyCapturedResultReceiver *receiver)
    {
        m_router = router;
        m_receiver = receiver;
    }

    void OnImageSourceStateReceived(ImageSourceState state)
    {
        if (state == ISS_EXHAUSTED)
        {
            m_router->StopCapturing();
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> sender = std::move(pendingResults.front());
            pendingResults.erase(pendingResults.begin());
            EncodableValue out;

            for (auto *result : m_receiver->results)
            {
                CProcessedDocumentResult *pResults = result->GetProcessedDocumentResult();
                if (pResults)
                {
                    int contourCount = pResults->GetDetectedQuadResultItemsCount();

                    if (contourCount > 0)
                    {
                        out = CreateContourList(result);
                    }
                    pResults->Release();
                }

                result->Release();
            }

            m_receiver->results.clear();
            sender->Success(out);
        }
    }

    EncodableValue CreateContourList(CCapturedResult *capturedResult)
    {
        EncodableList contours;

        CProcessedDocumentResult *pResults = capturedResult->GetProcessedDocumentResult();

        int count = pResults->GetDetectedQuadResultItemsCount();

        for (int i = 0; i < count; i++)
        {
            EncodableMap map;

            const CDetectedQuadResultItem *quadResult = pResults->GetDetectedQuadResultItem(i);
            int confidence = quadResult->GetConfidenceAsDocumentBoundary();
            CPoint *points = quadResult->GetLocation().points;
            int x1 = points[0][0];
            int y1 = points[0][1];
            int x2 = points[1][0];
            int y2 = points[1][1];
            int x3 = points[2][0];
            int y3 = points[2][1];
            int x4 = points[3][0];
            int y4 = points[3][1];

            map[EncodableValue("confidence")] = EncodableValue(confidence);
            map[EncodableValue("x1")] = EncodableValue(x1);
            map[EncodableValue("y1")] = EncodableValue(y1);
            map[EncodableValue("x2")] = EncodableValue(x2);
            map[EncodableValue("y2")] = EncodableValue(y2);
            map[EncodableValue("x3")] = EncodableValue(x3);
            map[EncodableValue("y3")] = EncodableValue(y3);
            map[EncodableValue("x4")] = EncodableValue(x4);
            map[EncodableValue("y4")] = EncodableValue(y4);
            contours.push_back(map);
        }
        return contours;
    }
};

class DocumentManager
{
public:
    ~DocumentManager()
    {
        if (cvr != NULL)
        {
            delete cvr;
            cvr = NULL;
        }

        if (listener)
        {
            delete listener;
            listener = NULL;
        }

        if (fileFetcher)
        {
            delete fileFetcher;
            fileFetcher = NULL;
        }

        if (capturedReceiver)
        {
            delete capturedReceiver;
            capturedReceiver = NULL;
        }

        if (processor)
        {
            delete processor;
            processor = NULL;
        }
    };

    int SetParameters(const char *params)
    {
        if (!cvr)
            return -1;

        char errorMsgBuffer[512];
        int ret = cvr->InitSettings(params, errorMsgBuffer, 512);
        if (ret != 0)
        {
            printf("SetParameters: %s\n", errorMsgBuffer);
        }

        return ret;
    }

    ImagePixelFormat getPixelFormat(int format)
    {
        ImagePixelFormat pixelFormat = IPF_BGR_888;
        switch (format)
        {
        case 0:
            pixelFormat = IPF_BINARY;
            break;
        case 1:
            pixelFormat = IPF_BINARYINVERTED;
            break;
        case 2:
            pixelFormat = IPF_GRAYSCALED;
            break;
        case 3:
            pixelFormat = IPF_NV21;
            break;
        case 4:
            pixelFormat = IPF_RGB_565;
            break;
        case 5:
            pixelFormat = IPF_RGB_555;
            break;
        case 6:
            pixelFormat = IPF_RGB_888;
            break;
        case 7:
            pixelFormat = IPF_ARGB_8888;
            break;
        case 8:
            pixelFormat = IPF_RGB_161616;
            break;
        case 9:
            pixelFormat = IPF_ARGB_16161616;
            break;
        case 10:
            pixelFormat = IPF_ABGR_8888;
            break;
        case 11:
            pixelFormat = IPF_ABGR_16161616;
            break;
        case 12:
            pixelFormat = IPF_BGR_888;
            break;
        }

        return pixelFormat;
    }

    int SetLicense(const char *license)
    {
        // Click https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform to get a trial license.
        char errorMsgBuffer[512];
        int ret = CLicenseManager::InitLicense(license, errorMsgBuffer, 512);
        printf("InitLicense: %s\n", errorMsgBuffer);

        if (ret)
            return ret;

        cvr = new CCaptureVisionRouter;

        fileFetcher = new CFileFetcher();
        ret = cvr->SetInput(fileFetcher);
        if (ret)
        {
            printf("SetInput error: %d\n", ret);
        }

        capturedReceiver = new MyCapturedResultReceiver;
        ret = cvr->AddResultReceiver(capturedReceiver);
        if (ret)
        {
            printf("AddResultReceiver error: %d\n", ret);
        }

        listener = new MyImageSourceStateListener(cvr, capturedReceiver);
        ret = cvr->AddImageSourceStateListener(listener);
        if (ret)
        {
            printf("AddImageSourceStateListener error: %d\n", ret);
        }

        processor = new CImageProcessor();

        return ret;
    }

    void start(const char *templateName)
    {
        if (!cvr)
            return;

        char errorMsg[512] = {0};
        int errorCode = cvr->StartCapturing(templateName, false, errorMsg, 512);
        if (errorCode != 0)
        {
            printf("StartCapturing: %s\n", errorMsg);
        }
    }

    void binary2grayscale(const unsigned char *data, unsigned char *output, int width, int height, int stride, int length)
    {
        int index = 0;

        int skip = stride * 8 - width;
        int shift = 0;
        int n = 1;

        for (int i = 0; i < length; ++i)
        {
            unsigned char b = data[i];
            int byteCount = 7;
            while (byteCount >= 0)
            {
                int tmp = (b & (1 << byteCount)) >> byteCount;

                if (shift < stride * 8 * n - skip)
                {
                    if (tmp == 1)
                        output[index] = 255;
                    else
                        output[index] = 0;
                    index += 1;
                }

                byteCount -= 1;
                shift += 1;
            }

            if (shift == stride * 8 * n)
            {
                n += 1;
            }
        }
    }

    EncodableMap createNormalizedImage(CCapturedResult *capturedResult)
    {
        EncodableMap map;

        CProcessedDocumentResult *pResults = capturedResult->GetProcessedDocumentResult();

        int count = pResults->GetEnhancedImageResultItemsCount();

        if (count > 0)
        {
            const CEnhancedImageResultItem *imageResult = pResults->GetEnhancedImageResultItem(0);
            const CImageData *imageData = imageResult->GetImageData();
            // CImageData *gray = processor->ConvertToGray(normalizedImage);
            // CImageData *imageData = processor->ConvertToBinaryGlobal(gray, -1, true);
            int width = imageData->GetWidth();
            int height = imageData->GetHeight();
            int stride = imageData->GetStride();
            int format = (int)imageData->GetImagePixelFormat();
            const unsigned char *data = imageData->GetBytes();
            int orientation = imageData->GetOrientation();
            int length = (int)imageData->GetBytesLength();

            map[EncodableValue("width")] = EncodableValue(width);
            map[EncodableValue("height")] = EncodableValue(height);
            map[EncodableValue("stride")] = EncodableValue(stride);
            map[EncodableValue("format")] = EncodableValue(format);
            map[EncodableValue("orientation")] = EncodableValue(orientation);
            map[EncodableValue("length")] = EncodableValue(length);

            unsigned char *rgba = new unsigned char[width * height * 4];
            memset(rgba, 0, width * height * 4);
            if (format == IPF_RGB_888)
            {
                int dataIndex = 0;
                for (int i = 0; i < height; i++)
                {
                    for (int j = 0; j < width; j++)
                    {
                        int index = i * width + j;

                        rgba[index * 4] = data[dataIndex];         // red
                        rgba[index * 4 + 1] = data[dataIndex + 1]; // green
                        rgba[index * 4 + 2] = data[dataIndex + 2]; // blue
                        rgba[index * 4 + 3] = 255;                 // alpha
                        dataIndex += 3;
                    }
                }
            }
            else if (format == IPF_GRAYSCALED || format == IPF_BINARY_8_INVERTED)
            {
                int dataIndex = 0;
                for (int i = 0; i < height; i++)
                {
                    for (int j = 0; j < width; j++)
                    {
                        int index = i * width + j;
                        rgba[index * 4] = data[dataIndex];
                        rgba[index * 4 + 1] = data[dataIndex];
                        rgba[index * 4 + 2] = data[dataIndex];
                        rgba[index * 4 + 3] = 255;
                        dataIndex += 1;
                    }
                }
            }
            else if (format == IPF_BINARY)
            {
                unsigned char *grayscale = new unsigned char[width * height];
                binary2grayscale(data, grayscale, width, height, stride, length);

                int dataIndex = 0;
                for (int i = 0; i < height; i++)
                {
                    for (int j = 0; j < width; j++)
                    {
                        int index = i * width + j;
                        rgba[index * 4] = grayscale[dataIndex];
                        rgba[index * 4 + 1] = grayscale[dataIndex];
                        rgba[index * 4 + 2] = grayscale[dataIndex];
                        rgba[index * 4 + 3] = 255;
                        dataIndex += 1;
                    }
                }

                free(grayscale);
            }

            std::vector<uint8_t> rawBytes(rgba, rgba + width * height * 4);
            map[EncodableValue("data")] = rawBytes;

            free(rgba);
        }

        return map;
    }

    void NormalizeFile(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> &pendingResult, const char *filename, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4)
    {
        EncodableMap map;

        if (!cvr)
        {
            pendingResult->Success(map);
            return;
        }

        SimplifiedCaptureVisionSettings settings = {};
        cvr->GetSimplifiedSettings(CPresetTemplate::PT_NORMALIZE_DOCUMENT, &settings);
        CQuadrilateral quad;
        quad.points[0][0] = x1;
        quad.points[0][1] = y1;
        quad.points[1][0] = x2;
        quad.points[1][1] = y2;
        quad.points[2][0] = x3;
        quad.points[2][1] = y3;
        quad.points[3][0] = x4;
        quad.points[3][1] = y4;
        settings.roi = quad;
        settings.roiMeasuredInPercentage = 0;

        char errorMsgBuffer[512];
        int ret = cvr->UpdateSettings(CPresetTemplate::PT_NORMALIZE_DOCUMENT, &settings, errorMsgBuffer, 512);
        if (ret)
        {
            printf("Error: %s\n", errorMsgBuffer);
        }

        CCapturedResult *capturedResult = cvr->Capture(filename, CPresetTemplate::PT_NORMALIZE_DOCUMENT);
        map = createNormalizedImage(capturedResult);
        pendingResult->Success(map);
    }

    void NormalizeBuffer(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> &pendingResult, const unsigned char *buffer, int width, int height, int stride, int format, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, int rotation)
    {
        EncodableMap map;
        if (!cvr)
        {
            pendingResult->Success(map);
            return;
        }

        SimplifiedCaptureVisionSettings settings = {};
        cvr->GetSimplifiedSettings(CPresetTemplate::PT_NORMALIZE_DOCUMENT, &settings);
        CQuadrilateral quad;
        quad.points[0][0] = x1;
        quad.points[0][1] = y1;
        quad.points[1][0] = x2;
        quad.points[1][1] = y2;
        quad.points[2][0] = x3;
        quad.points[2][1] = y3;
        quad.points[3][0] = x4;
        quad.points[3][1] = y4;
        settings.roi = quad;
        settings.roiMeasuredInPercentage = 0;

        char errorMsgBuffer[512];
        int ret = cvr->UpdateSettings(CPresetTemplate::PT_NORMALIZE_DOCUMENT, &settings, errorMsgBuffer, 512);
        if (ret)
        {
            printf("Error: %s\n", errorMsgBuffer);
        }

        CImageData *imageData = new CImageData(stride * height, buffer, width, height, stride, getPixelFormat(format), rotation);
        CCapturedResult *capturedResult = cvr->Capture(imageData, CPresetTemplate::PT_NORMALIZE_DOCUMENT);
        delete imageData;

        map = createNormalizedImage(capturedResult);
        pendingResult->Success(map);
    }

    EncodableValue GetParameters()
    {
        if (cvr == NULL)
            return EncodableValue("");

        char *content = cvr->OutputSettings("*");
        EncodableValue params = EncodableValue((const char *)content);
        return params;
    }

    void DetectBuffer(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> &pendingResult, const unsigned char *buffer, int width, int height, int stride, int format, int rotation)
    {
        if (!cvr)
        {
            EncodableList out;
            pendingResult->Success(out);
            return;
        }

        listener->pendingResults.push_back(std::move(pendingResult));
        CImageData *imageData = new CImageData(stride * height, buffer, width, height, stride, getPixelFormat(format), rotation);
        fileFetcher->SetFile(imageData);
        delete imageData;

        start(CPresetTemplate::PT_DETECT_DOCUMENT_BOUNDARIES);
    }

    void DetectFile(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> &pendingResult, const char *filename)
    {
        if (!cvr)
        {
            EncodableList out;
            pendingResult->Success(out);
            return;
        }

        listener->pendingResults.push_back(std::move(pendingResult));
        fileFetcher->SetFile(filename);
        start(CPresetTemplate::PT_DETECT_DOCUMENT_BOUNDARIES);
    }

private:
    MyCapturedResultReceiver *capturedReceiver;
    MyImageSourceStateListener *listener;
    CFileFetcher *fileFetcher;
    CCaptureVisionRouter *cvr;
    CImageProcessor *processor;
};

#endif