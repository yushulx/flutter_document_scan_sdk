#pragma once

#if !defined(_WIN32) && !defined(_WIN64)
#define DDN_API __attribute__((visibility("default")))
#include <stddef.h>
#else
#ifdef DDN_EXPORTS
#define DDN_API __declspec(dllexport)
#else
#define DDN_API 
#endif
#include <windows.h>
#endif
#ifdef __IOS_WRAPPER__
#include "DynamsoftCore_Inner.h"
#else
#include "DynamsoftCore.h"
#endif
#define DDN_VERSION                  "1.0.10.0929"

#pragma pack(push)
#pragma pack(1)

typedef struct tagDetectedQuadResult
{
	Quadrilateral *location;
	int confidenceAsDocumentBoundary;

}DetectedQuadResult, *PDetectedQuadResult;

typedef struct tagDetectedQuadResultArray
{
	int resultsCount;
	PDetectedQuadResult *detectedQuadResults;
}DetectedQuadResultArray;

typedef struct tagNormalizedImageResult
{
	ImageData *image;
}NormalizedImageResult;

#pragma pack(pop)


#ifdef __cplusplus
extern "C" {
#endif

	DDN_API const char* DDN_GetVersion();

	DDN_API void* DDN_CreateInstance();

	DDN_API void DDN_DestroyInstance(void* normalizer);

	DDN_API int DDN_InitRuntimeSettingsFromString(void* normalizer, const char* content, char errorMsgBuffer[], const int errorMsgBufferLen);

	DDN_API int DDN_InitRuntimeSettingsFromFile(void* normalizer, const char* filePath, char errorMsgBuffer[], const int errorMsgBufferLen);

	DDN_API int DDN_OutputRuntimeSettingsToFile(void* normalizer, const char* templateName,const char* outputFilePath);

	DDN_API int DDN_OutputRuntimeSettingsToString(void* normalizer, const char* templateName, char** content);

	DDN_API void DDN_FreeString(char** content);

	DDN_API int DDN_DetectQuadFromFile(void* normalizer, const char* sourceFilePath, const char* templateName, DetectedQuadResultArray** result);

	DDN_API int DDN_DetectQuadFromBuffer(void* normalizer, const ImageData* sourceImage, const char* templateName, DetectedQuadResultArray** result);

	DDN_API int DDN_NormalizeFile(void* normalizer, const char* sourceFilePath, const char* templateName, const Quadrilateral *quad, NormalizedImageResult** result);

	DDN_API int DDN_NormalizeBuffer(void* normalizer, const ImageData* sourceImage, const char* templateName, const Quadrilateral *quad, NormalizedImageResult** result);

	DDN_API void DDN_FreeNormalizedImageResult(NormalizedImageResult** result);

	DDN_API void DDN_FreeDetectedQuadResultArray(DetectedQuadResultArray** results);

	DDN_API int NormalizedImageResult_SaveToFile(const NormalizedImageResult* normalizedImageResult, const char* filePath);

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

class CDocumentNormalizerInner;

namespace dynamsoft
{
	namespace dir
	{
		class CParameterTree;
	}
	namespace ddn
	{
#pragma pack(push)
#pragma pack(1)
		class DDN_API CDetectedQuadResult
		{
		protected:
			core::CQuadrilateral *location;
			int confidenceAsDocumentBoundary;

		public:
			CDetectedQuadResult(core::CQuadrilateral* loc, int conf);
			~CDetectedQuadResult();

			const core::CQuadrilateral* GetLocation();
			int GetConfidenceAsDocumentBoundary();

		private:
			CDetectedQuadResult(const CDetectedQuadResult&);
			CDetectedQuadResult& operator=(const CDetectedQuadResult&);
		};

		class DDN_API CDetectedQuadResultArray
		{
		protected:
			int resultsCount;
			CDetectedQuadResult** detectedQuadResults;

		public:
			CDetectedQuadResultArray(int count, CDetectedQuadResult** resArray);
			~CDetectedQuadResultArray();

			int GetCount();
			int GetDetectedQuadResult(int index, CDetectedQuadResult** result);

		private:
			CDetectedQuadResultArray(const CDetectedQuadResultArray&);
			CDetectedQuadResultArray& operator=(const CDetectedQuadResultArray&);
		};

		class DDN_API CNormalizedImageResult
		{
		protected:
			core::CImageData* image;

		public:
			CNormalizedImageResult(core::CImageData* img);
			~CNormalizedImageResult();
			int SaveToFile(const char* filePath);
			const core::CImageData* GetImageData();

		private:
			CNormalizedImageResult(const CNormalizedImageResult&);
			CNormalizedImageResult& operator=(const CNormalizedImageResult&);
		};
#pragma pack(pop)

		class DDN_API CDocumentNormalizer
		{
		protected:
			CDocumentNormalizerInner * m_DDNInner;
			
		public:
			CDocumentNormalizer();

			~CDocumentNormalizer();

			static const char* GetVersion();

			int InitRuntimeSettingsFromString(const char* content, char errorMsgBuffer[]=NULL, const int errorMsgBufferLen=0);

			int InitRuntimeSettingsFromFile(const char* filePath, char errorMsgBuffer[]=NULL, const int errorMsgBufferLen=0);

			int OutputRuntimeSettingsToFile(const char* templateName,const char* outputFilePath);

			int OutputRuntimeSettingsToString(const char* templateName,char** content);

			int DetectQuad(const char* sourceFilePath, const char* templateName, CDetectedQuadResultArray** result);

			int DetectQuad(const core::CImageData* sourceImage, const char* templateName, CDetectedQuadResultArray** result);

			int Normalize(const char* sourceFilePath, const char* templateName, const core::CQuadrilateral *quad, CNormalizedImageResult** result);

			int Normalize(const core::CImageData* sourceImage, const char* templateName, const core::CQuadrilateral *quad, CNormalizedImageResult** result);

			static void FreeNormalizedImageResult(CNormalizedImageResult** result);

			static void FreeDetectedQuadResultArray(CDetectedQuadResultArray** results);

			static void FreeString(char** content);


		private:
			CDocumentNormalizer(const CDocumentNormalizer& r);
			CDocumentNormalizer& operator=(const CDocumentNormalizer& r);
		};
	}
}
#endif
