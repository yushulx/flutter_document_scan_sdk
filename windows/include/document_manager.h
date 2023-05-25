#ifndef DOCUMENT_MANAGER_H_
#define DOCUMENT_MANAGER_H_

#include "DynamsoftCore.h"
#include "DynamsoftDocumentNormalizer.h"

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
using namespace dynamsoft::core;

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

class Task
{
public:
    std::function<void()> func;
    unsigned char* buffer;
};

class WorkerThread
{
public:
    std::mutex m;
    std::condition_variable cv;
    std::queue<Task> tasks = {};
    volatile bool running;
    std::thread t;
};

class DocumentManager
{
public:
    ~DocumentManager()
    {
        clear();
        if (normalizer != NULL)
        {
            DDN_DestroyInstance(normalizer);
            normalizer = NULL;
        }

        FreeImage();
    };

    void clearTasks()
    {
        if (worker->tasks.size() > 0)
        {
            for (int i = 0; i < worker->tasks.size(); i++)
            {
                free(worker->tasks.front().buffer);
                worker->tasks.pop();
            }
        }
    }

    void clear()
    {
        if (worker)
        {
            std::unique_lock<std::mutex> lk(worker->m);
            worker->running = false;
            
            clearTasks();

            worker->cv.notify_one();
            lk.unlock();

            worker->t.join();
            delete worker;
            worker = NULL;
            printf("Quit native thread.\n");
        }
    }

    const char *GetVersion()
    {
        return DDN_GetVersion();
    }

    void Init()
    {
        normalizer = DDN_CreateInstance();
        imageResult = NULL;
        worker = new WorkerThread();
        worker->running = true;
        worker->t = thread(&run, this);
    }

    int SetParameters(const char *params)
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

    static void run(DocumentManager *self)
    {
        while (self->worker->running)
        {
            std::function<void()> task;
            std::unique_lock<std::mutex> lk(self->worker->m);
            self->worker->cv.wait(lk, [&]
                                { return !self->worker->tasks.empty() || !self->worker->running; });
            if (!self->worker->running)
            {
                break;
            }
            task = std::move(self->worker->tasks.front().func);
            self->worker->tasks.pop();
            lk.unlock();

            task();
        }
    }

    void queueTask(unsigned char* barcodeBuffer, int width, int height, int stride, int format, int len)
    {    
        unsigned char *data = (unsigned char *)malloc(len);
        memcpy(data, barcodeBuffer, len);

        std::unique_lock<std::mutex> lk(worker->m);
        clearTasks();
        std::function<void()> task_function = std::bind(processBuffer, this, data, width, height, stride, format);
        Task task;
        task.func = task_function;
        task.buffer = data;
        worker->tasks.push(task);
        worker->cv.notify_one();
        lk.unlock();
    }

    ImagePixelFormat getPixelFormat(int format)
    {
        ImagePixelFormat pixelFormat = IPF_BGR_888;
        switch(format) {
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

    static void processBuffer(DocumentManager *self, unsigned char * buffer, int width, int height, int stride, int format)
    {
        

        ImageData data;
        data.bytes = buffer;
        data.width = width;
        data.height = height;
        data.stride = stride;
        data.format = self->getPixelFormat(format);
        data.bytesLength = stride * height;

        DetectedQuadResultArray *pResults = NULL;
        int ret = DDN_DetectQuadFromBuffer(self->normalizer, &data, "", &pResults);
        if (ret)
        {
            printf("Detection error: %s\n", DC_GetErrorString(ret));
        }

        free(buffer);
        EncodableList results = self->WrapResults(pResults);
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result = std::move(self->pendingResults.front());
        self->pendingResults.erase(self->pendingResults.begin());
        result->Success(results);
    }

    static int SetLicense(const char *license)
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

    EncodableList WrapResults(DetectedQuadResultArray *pResults) 
    {
        EncodableList out;
        if (normalizer == NULL)
            return out;

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

    EncodableList DetectFile(const char *filename)
    {
        EncodableList out;
        if (normalizer == NULL)
            return out;

        DetectedQuadResultArray *pResults = NULL;

        int ret = DDN_DetectQuadFromFile(normalizer, filename, "", &pResults);
        if (ret)
        {
            printf("Detection error: %s\n", DC_GetErrorString(ret));
        }

        return WrapResults(pResults);
    }

    EncodableMap createNormalizedImage()
    {
        EncodableMap map;

        if (imageResult)
        {
            ImageData *imageData = imageResult->image;
            int width = imageData->width;
            int height = imageData->height;
            int stride = imageData->stride;
            int format = (int)imageData->format;
            unsigned char *data = imageData->bytes;
            int orientation = imageData->orientation;
            int length = imageData->bytesLength;

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

                        rgba[index * 4] = data[dataIndex + 2];     // red
                        rgba[index * 4 + 1] = data[dataIndex + 1]; // green
                        rgba[index * 4 + 2] = data[dataIndex];     // blue
                        rgba[index * 4 + 3] = 255;                 // alpha
                        dataIndex += 3;
                    }
                }
            }
            else if (format == IPF_GRAYSCALED)
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

    EncodableMap NormalizeFile(const char *filename, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4)
    {
        FreeImage();

        Quadrilateral quad;
        quad.points[0].coordinate[0] = x1;
        quad.points[0].coordinate[1] = y1;
        quad.points[1].coordinate[0] = x2;
        quad.points[1].coordinate[1] = y2;
        quad.points[2].coordinate[0] = x3;
        quad.points[2].coordinate[1] = y3;
        quad.points[3].coordinate[0] = x4;
        quad.points[3].coordinate[1] = y4;

        int errorCode = DDN_NormalizeFile(normalizer, filename, "", &quad, &imageResult);
        if (errorCode != DM_OK)
            printf("%s\r\n", DC_GetErrorString(errorCode));

        return createNormalizedImage();
    }

    EncodableMap NormalizeBuffer(const unsigned char * buffer, int width, int height, int stride, int format, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4)
    {
        FreeImage();

        ImageData data;
        data.bytes = (unsigned char *)buffer;
        data.width = width;
        data.height = height;
        data.stride = stride;
        data.format = getPixelFormat(format);
        data.bytesLength = stride * height;

        Quadrilateral quad;
        quad.points[0].coordinate[0] = x1;
        quad.points[0].coordinate[1] = y1;
        quad.points[1].coordinate[0] = x2;
        quad.points[1].coordinate[1] = y2;
        quad.points[2].coordinate[0] = x3;
        quad.points[2].coordinate[1] = y3;
        quad.points[3].coordinate[0] = x4;
        quad.points[3].coordinate[1] = y4;

        int errorCode = DDN_NormalizeBuffer(normalizer, &data, "", &quad, &imageResult);
        if (errorCode != DM_OK)
            printf("%s\r\n", DC_GetErrorString(errorCode));

        return createNormalizedImage();
    }

    void binary2grayscale(unsigned char *data, unsigned char *output, int width, int height, int stride, int length)
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

    EncodableValue GetParameters()
    {
        if (normalizer == NULL)
            return EncodableValue("");

        char *content = NULL;
        DDN_OutputRuntimeSettingsToString(normalizer, "", &content);
        EncodableValue params = EncodableValue((const char *)content);
        if (content != NULL)
            DDN_FreeString(&content);
        return params;
    }

    int Save(const char *filename)
    {
        if (imageResult == NULL)
            return -1;
        int ret = NormalizedImageResult_SaveToFile(imageResult, filename);
        if (ret != DM_OK)
            printf("NormalizedImageResult_SaveToFile: %s\r\n", DC_GetErrorString(ret));

        return ret;
    }

    void DetectBuffer(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& pendingResult, const unsigned char * buffer, int width, int height, int stride, int format) 
    {
        pendingResults.push_back(std::move(pendingResult));
        queueTask((unsigned char*)buffer, width, height, stride, format, stride * height);
    }

private:
    void *normalizer;
    NormalizedImageResult *imageResult;
    WorkerThread *worker;
    vector<std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>> pendingResults = {};

    void FreeImage()
    {
        if (imageResult != NULL)
        {
            DDN_FreeNormalizedImageResult(&imageResult);
            imageResult = NULL;
        }
    }
};

#endif