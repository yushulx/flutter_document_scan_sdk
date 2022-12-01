#ifndef __DYNAMSOFT_CORE_H__
#define __DYNAMSOFT_CORE_H__

#define DYNAMSOFT_CORE_VERSION "2.0.1.0929"

/**Successful. */
#define DM_OK								0 

/**Unknown error. */
#define DMERR_UNKNOWN					-10000 

/**Not enough memory to perform the operation. */
#define DMERR_NO_MEMORY				-10001 

/**Null pointer */
#define DMERR_NULL_POINTER				-10002 

/**License invalid*/
#define DMERR_LICENSE_INVALID			-10003 

/**License expired*/
#define DMERR_LICENSE_EXPIRED			-10004

/**File not found*/
#define DMERR_FILE_NOT_FOUND			-10005 

/**The file type is not supported. */
#define DMERR_FILETYPE_NOT_SUPPORTED	-10006 

/**The BPP (Bits Per Pixel) is not supported. */
#define DMERR_BPP_NOT_SUPPORTED		-10007 

/**Failed to read the image. */
#define DMERR_IMAGE_READ_FAILED		-10012

/**Failed to read the TIFF image. */
#define DMERR_TIFF_READ_FAILED			-10013

/**The DIB (Device-Independent Bitmaps) buffer is invalid. */
#define DMERR_DIB_BUFFER_INVALID			-10018

/**Failed to read the PDF image. */
#define DMERR_PDF_READ_FAILED			-10021

/**The PDF DLL is missing. */
#define DMERR_PDF_DLL_MISSING			-10022

/** timeout. */
#define DMERR_TIMEOUT					-10026
/**Recognition timeout. */
#define DMERR_RECOGNITION_TIMEOUT			-10026

/**Json parse failed*/
#define DMERR_JSON_PARSE_FAILED		-10030 

/**Json type invalid*/
#define DMERR_JSON_TYPE_INVALID		-10031 

/**Json key invalid*/
#define DMERR_JSON_KEY_INVALID			-10032 

/**Json value invalid*/
#define DMERR_JSON_VALUE_INVALID		-10033 

/**Json name key missing*/
#define DMERR_JSON_NAME_KEY_MISSING    -10034

/**The value of the key "Name" is duplicated.*/
#define DMERR_JSON_NAME_VALUE_DUPLICATED    -10035

/**Template name invalid*/
#define DMERR_TEMPLATE_NAME_INVALID	-10036

/**Parameter value invalid*/
#define DMERR_PARAMETER_VALUE_INVALID	-10038

/**Failed to set mode's argument.*/
#define DMERR_SET_MODE_ARGUMENT_ERROR  -10051

/**Failed to get mode's argument.*/
#define DMERR_GET_MODE_ARGUMENT_ERROR  -10055

/**No content has been detected.*/
#define DDNERR_CONTENT_NOT_FOUND -50001

/*The quardrilateral is invalid*/
#define DMERR_QUADRILATERAL_INVALID -10057

/**Failed to save file.*/
#define DMERR_FILE_SAVE_FAILED -10058

/**The stage type is invalid.*/
#define DMERR_STAGE_TYPE_INVALID -10059

/**The image orientation is invalid.*/
#define DMERR_IMAGE_ORIENTATION_INVALID -10060

#ifndef _COMMON_PART1_
#define _COMMON_PART1_

/**No license.*/
#define DMERR_NO_LICENSE -20000

/**The Handshake Code is invalid.*/
#define DMERR_HANDSHAKE_CODE_INVALID -20001

/**Failed to read or write license buffer. */
#define DMERR_LICENSE_BUFFER_FAILED	-20002

/**Failed to synchronize license info with license server. */
#define DMERR_LICENSE_SYNC_FAILED	-20003

/**Device dose not match with buffer. */
#define DMERR_DEVICE_NOT_MATCH	-20004

/**Failed to bind device. */
#define DMERR_BIND_DEVICE_FAILED	-20005

/**Interface InitLicenseFromDLS can not be used together with other license initiation interfaces. */
#define DMERR_LICENSE_INTERFACE_CONFLICT -20006

/**License Client dll is missing.*/
#define DMERR_LICENSE_CLIENT_DLL_MISSING -20007

/**Instance count is over limit.*/
#define DMERR_INSTANCE_COUNT_OVER_LIMIT -20008

/**Interface InitLicenseFromDLS has to be called before creating any SDK objects.*/
#define DMERR_LICENSE_INIT_SEQUENCE_FAILED -20009

/**Trial License*/
#define DMERR_TRIAL_LICENSE -20010

/**Failed to reach License Server.*/
#define DMERR_FAILED_TO_REACH_DLS -20200


#endif

#ifndef _COMMON_PART2_
#define _COMMON_PART2_
/**
* @enum ImagePixelFormat
*
* Describes the image pixel format.
*
*/
typedef enum ImagePixelFormat
{
	/**0:Black, 1:White */
	IPF_BINARY,

	/**0:White, 1:Black */
	IPF_BINARYINVERTED,

	/**8bit gray */
	IPF_GRAYSCALED,

	/**NV21 */
	IPF_NV21,

	/**16bit with RGB channel order stored in memory from high to low address*/
	IPF_RGB_565,

	/**16bit with RGB channel order stored in memory from high to low address*/
	IPF_RGB_555,

	/**24bit with RGB channel order stored in memory from high to low address*/
	IPF_RGB_888,

	/**32bit with ARGB channel order stored in memory from high to low address*/
	IPF_ARGB_8888,

	/**48bit with RGB channel order stored in memory from high to low address*/
	IPF_RGB_161616,

	/**64bit with ARGB channel order stored in memory from high to low address*/
	IPF_ARGB_16161616,

	/**32bit with ABGR channel order stored in memory from high to low address*/
	IPF_ABGR_8888,

	/**64bit with ABGR channel order stored in memory from high to low address*/
	IPF_ABGR_16161616,

	/**24bit with BGR channel order stored in memory from high to low address*/
	IPF_BGR_888

}ImagePixelFormat;

/**
* @enum GrayscaleTransformationMode
*
* Describes the grayscale transformation mode.
*/
typedef enum GrayscaleTransformationMode
{
	/**Transforms to inverted grayscale. Recommended for light on dark images. */
	GTM_INVERTED = 0x01,

	/**Keeps the original grayscale. Recommended for dark on light images. */
	GTM_ORIGINAL = 0x02,

	/**Lets the library choose an algorithm automatically for grayscale transformation.*/
	GTM_AUTO = 0x04,

	/**Reserved setting for grayscale transformation mode.*/
#if defined(_WIN32) || defined(_WIN64)
	GTM_REV = 0x80000000,
#else
	GTM_REV = -2147483648,
#endif

	/**Skips grayscale transformation. */
	GTM_SKIP = 0x00

}GrayscaleTransformationMode;

/**
* @enum RegionPredetectionMode
*
* Describes the region predetection mode.
*
*/
typedef enum RegionPredetectionMode
{
	/**Auto*/
	RPM_AUTO = 0x01, 

	/**Takes the whole image as a region*/
	RPM_GENERAL = 0x02,

	/**Detects region using the general algorithm based on RGB colour contrast*/
	RPM_GENERAL_RGB_CONTRAST = 0x04,

	/**Detects region using the general algorithm based on gray contrast*/
	RPM_GENERAL_GRAY_CONTRAST = 0x08,

	/**Detects region using the general algorithm based on HSV colour contrast*/
	RPM_GENERAL_HSV_CONTRAST = 0x10,

	RPM_MANUAL_SPECIFICATION = 0x20,
	/**Reserved setting for region predection mode.*/
#if defined(_WIN32) || defined(_WIN64)
	RPM_REV = 0x80000000,
#else
	RPM_REV = -2147483648,
#endif

	/**Skip*/
	RPM_SKIP = 0
}RegionPredetectionMode;

/**
* @enum BinarizationMode
*
* Describes the binarization mode.
*
*/
typedef enum BinarizationMode
{
	/**Not supported yet. */
	BM_AUTO = 0x01,

	/**Binarizes the image based on the local block. Check @ref BM for available argument settings.*/
	BM_LOCAL_BLOCK = 0x02,

	/**Performs image binarization based on the given threshold. Check @ref BM for available argument settings.*/
	BM_THRESHOLD = 0x04,

	/**Reserved setting for binarization mode.*/
#if defined(_WIN32) || defined(_WIN64)
	BM_REV = 0x80000000,
#else
	BM_REV = -2147483648,
#endif

	/**Skips the binarization. */
	BM_SKIP = 0x00
}BinarizationMode;


/**
* @enum ScaleUpMode
*
* Describes scale up mode.
*
*/
typedef enum ScaleUpMode
{
	/**Skip the scale-up process.*/
	SUM_SKIP = 0x00,

	/**The library chooses an interpolation method automatically to scale up.*/
	SUM_AUTO = 0x01,

	/**Scales up using the linear interpolation method.*/
	SUM_LINEAR_INTERPOLATION = 0x02,

	/**Scales up using the nearest-neighbour interpolation method.*/
	SUM_NEAREST_NEIGHBOUR_INTERPOLATION = 0x04,

	/**Reserved setting for scale up mode.*/
#if defined(_WIN32) || defined(_WIN64)
	SUM_REV = 0x80000000
#else
	SUM_REV = -2147483648
#endif
}ScaleUpMode;

/**
* @enum ColourConversionMode
*
* Describes colour conversion mode.
*
*/
typedef enum ColourConversionMode
{
	/**Skips the colour conversion.*/
	CICM_SKIP = 0x00,

	/**Converts a colour image to a grayscale image using the general RGB converting algorithm.*/
	CICM_GENERAL = 0x01,

	/**Converts a colour image to a grayscale image using one of the HSV channels.*/
	CICM_HSV = 0x02,
	
#if defined(_WIN32) || defined(_WIN64)
	CICM_REV = 0x80000000
#else
	CICM_REV = -2147483648
#endif
	
}ColourConversionMode;

/**
* @enum TextureDetectionMode
*
* Describes the texture detection mode.
*/
typedef enum TextureDetectionMode
{
	/**Not supported yet. */
	TDM_AUTO = 0x01,

	/**Detects texture using the general algorithm. Check @ref TDM for available argument settings.*/
	TDM_GENERAL_WIDTH_CONCENTRATION = 0x02,

	/**Reserved setting for texture detection mode.*/
#if defined(_WIN32) || defined(_WIN64)
	TDM_REV = 0x80000000,
#else
	TDM_REV = -2147483648,
#endif

	/**Skips texture detection. */
	TDM_SKIP = 0x00

}TextureDetectionMode;


/**
* @enum PDFReadingMode
*
* Describes the PDF reading mode.
*/
typedef enum PDFReadingMode
{
	/** Lets the library choose the reading mode automatically. */
	PDFRM_AUTO = 0x01,

	/** Detects barcode from vector data in PDF file.*/
	PDFRM_VECTOR = 0x02,

	/** Converts the PDF file to image(s) first, then perform barcode recognition.*/
	PDFRM_RASTER = 0x04,

	/**Reserved setting for PDF reading mode.*/
#if defined(_WIN32) || defined(_WIN64)
	PDFRM_REV = 0x80000000,
#else
	PDFRM_REV = -2147483648,
#endif
}PDFReadingMode;

/**
* @enum BarcodeFormat
*
* Describes the barcode types in BarcodeFormat group 1. All the formats can be combined, such as BF_CODE_39 | BF_CODE_128.
* Note: The barcode format our library will search for is composed of [BarcodeFormat group 1](@ref BarcodeFormat) and [BarcodeFormat group 2](@ref BarcodeFormat_2), so you need to specify the barcode format in group 1 and group 2 individually.
*/
typedef enum BarcodeFormat
{
	/**All supported formats in BarcodeFormat group 1*/
#if defined(_WIN32) || defined(_WIN64)
	BF_ALL = 0xFE3FFFFF,
#else
	BF_ALL = -29360129,
#endif

	/**Combined value of BF_CODABAR, BF_CODE_128, BF_CODE_39, BF_CODE_39_Extended, BF_CODE_93, BF_EAN_13, BF_EAN_8, INDUSTRIAL_25, BF_ITF, BF_UPC_A, BF_UPC_E, BF_MSI_CODE ,BF_ONED;  */
	BF_ONED = 0x003007FF,

	/**Combined value of BF_GS1_DATABAR_OMNIDIRECTIONAL, BF_GS1_DATABAR_TRUNCATED, BF_GS1_DATABAR_STACKED, BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL, BF_GS1_DATABAR_EXPANDED, BF_GS1_DATABAR_EXPANDED_STACKED, BF_GS1_DATABAR_LIMITED*/
	BF_GS1_DATABAR = 0x0003F800,

	/**Code 39 */
	BF_CODE_39 = 0x1,

	/**Code 128 */
	BF_CODE_128 = 0x2,

	/**Code 93 */
	BF_CODE_93 = 0x4,

	/**Codabar */
	BF_CODABAR = 0x8,

	/**Interleaved 2 of 5 */
	BF_ITF = 0x10,

	/**EAN-13 */
	BF_EAN_13 = 0x20,

	/**EAN-8 */
	BF_EAN_8 = 0x40,

	/**UPC-A */
	BF_UPC_A = 0x80,

	/**UPC-E */
	BF_UPC_E = 0x100,

	/**Industrial 2 of 5 */
	BF_INDUSTRIAL_25 = 0x200,

	/**CODE39 Extended */
	BF_CODE_39_EXTENDED = 0x400,

	/**GS1 Databar Omnidirectional*/
	BF_GS1_DATABAR_OMNIDIRECTIONAL = 0x800,

	/**GS1 Databar Truncated*/
	BF_GS1_DATABAR_TRUNCATED = 0x1000,

	/**GS1 Databar Stacked*/
	BF_GS1_DATABAR_STACKED = 0x2000,

	/**GS1 Databar Stacked Omnidirectional*/
	BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL = 0x4000,

	/**GS1 Databar Expanded*/
	BF_GS1_DATABAR_EXPANDED = 0x8000,

	/**GS1 Databar Expaned Stacked*/
	BF_GS1_DATABAR_EXPANDED_STACKED = 0x10000,

	/**GS1 Databar Limited*/
	BF_GS1_DATABAR_LIMITED = 0x20000,

	/**Patch code. */
	BF_PATCHCODE = 0x00040000,

	/**PDF417 */
	BF_PDF417 = 0x02000000,

	/**QRCode */
	BF_QR_CODE = 0x04000000,

	/**DataMatrix */
	BF_DATAMATRIX = 0x08000000,

	/**AZTEC */
	BF_AZTEC = 0x10000000,

	/**MAXICODE */
	BF_MAXICODE = 0x20000000,

	/**Micro QR Code*/
	BF_MICRO_QR = 0x40000000,

	/**Micro PDF417*/
	BF_MICRO_PDF417 = 0x00080000,

	/**GS1 Composite Code*/
#if defined(_WIN32) || defined(_WIN64)
	BF_GS1_COMPOSITE = 0x80000000,
#else
	BF_GS1_COMPOSITE = -2147483648,
#endif

	/**MSI Code*/
	BF_MSI_CODE = 0x100000,

	/*Code 11*/
	BF_CODE_11 = 0x200000,


	/**No barcode format in BarcodeFormat group 1*/
	BF_NULL = 0x00

}BarcodeFormat;


/**
* @enum BarcodeFormat_2
*
* Describes the barcode types in BarcodeFormat group 2.
* Note: The barcode format our library will search for is composed of [BarcodeFormat group 1](@ref BarcodeFormat) and [BarcodeFormat group 2](@ref BarcodeFormat_2), so you need to specify the barcode format in group 1 and group 2 individually.
*/
typedef enum BarcodeFormat_2
{
	/**No barcode format in BarcodeFormat group 2*/
	BF2_NULL = 0x00,

	/**Combined value of BF2_USPSINTELLIGENTMAIL, BF2_POSTNET, BF2_PLANET, BF2_AUSTRALIANPOST, BF2_RM4SCC.*/
	BF2_POSTALCODE = 0x01F00000,

	/**Nonstandard barcode */
	BF2_NONSTANDARD_BARCODE = 0x01,

	/**USPS Intelligent Mail.*/
	BF2_USPSINTELLIGENTMAIL = 0x00100000,

	/**Postnet.*/
	BF2_POSTNET = 0x00200000,

	/**Planet.*/
	BF2_PLANET = 0x00400000,

	/**Australian Post.*/
	BF2_AUSTRALIANPOST = 0x00800000,

	/**Royal Mail 4-State Customer Barcode.*/
	BF2_RM4SCC = 0x01000000,

	/**DotCode.*/
	BF2_DOTCODE = 0x02,

	/**_PHARMACODE_ONE_TRACK.*/
	BF2_PHARMACODE_ONE_TRACK = 0x04,

	/**PHARMACODE_TWO_TRACK.*/
	BF2_PHARMACODE_TWO_TRACK = 0x08,

	/**PHARMACODE.*/
	BF2_PHARMACODE = 0x0C
}BarcodeFormat_2;



#pragma pack(push)
#pragma pack(1)

typedef struct tagDMPoint
{
	int coordinate[2];
}DM_Point;

typedef struct tagQuadrilateral
{
	/**The four points of the quadrilateral.*/
	DM_Point points[4];

}Quadrilateral,*PQuadrilateral;

/**
* @struct ImageData
*
* Stores the image data.
*
*/
typedef struct tagImageData
{
	/**The length of the image data byte.*/
	int bytesLength;

	/**The image data content in a byte array.*/
	unsigned char* bytes;

	/**The width of the image in pixels.*/
	int width;

	/**The height of the image in pixels.*/
	int height;

	/**The stride(or scan width) of the image.*/
	int stride;

	/**The image pixel format used in the image byte array.*/
	ImagePixelFormat format;

	/**The image orientation.*/
	int orientation;
}ImageData;


#pragma pack(pop)

#endif

/**
* @enum GrayscaleEnhancementMode
*
* Describes the grayscaleEnhancementMode.
*
*/
typedef enum GrayscaleEnhancementMode
{
	/**Not supported yet. */
	GEM_AUTO = 0x01,

	/**Takes the unpreprocessed image for following operations. */
	GEM_GENERAL = 0x02,

	/**Preprocesses the image using the gray equalization algorithm. Check @ref IPM for available argument settings.*/
	GEM_GRAY_EQUALIZE = 0x04,

	/**Preprocesses the image using the gray smoothing algorithm. Check @ref IPM for available argument settings.*/
	GEM_GRAY_SMOOTH = 0x08,

	/**Preprocesses the image using the sharpening and smoothing algorithm. Check @ref IPM for available argument settings.*/
	GEM_SHARPEN_SMOOTH = 0x10,

	/**Reserved setting for image preprocessing mode.*/
#if defined(_WIN32) || defined(_WIN64)
	GEM_REV = 0x80000000,
#else
	GEM_REV = -2147483648,
#endif

	/**Skips image preprocessing. */
	GEM_SKIP = 0x00
}GrayscaleEnhancementMode;


#pragma pack(push)
#pragma pack(1)

typedef struct tagBarcodeResult
{
	BarcodeFormat barcodeFormat;
	BarcodeFormat_2 barcodeFormat_2;
	const char* text;
	unsigned char* bytes;
	int bytesLength;
	Quadrilateral location;
	int moduleSize;
	int pageNumber;
	char reserved[64];
}BarcodeResult;

typedef struct tagBarcodeResultArray
{
	int resultsCount;
	BarcodeResult** results;
}BarcodeResultArray;
#pragma pack(pop)

#if !defined(_WIN32) && !defined(_WIN64)
#define DM_API __attribute__((visibility("default")))
#include <stddef.h>
#else
#ifdef DM_EXPORTS
#define DM_API __declspec(dllexport)
#else
#define DM_API 
#endif
#include <windows.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif
	DM_API  const char* DC_GetErrorString(int errorCode);
	DM_API  int DC_InitLicense(const char* pLicense, char errorMsgBuffer[], const int errorMsgBufferLen);
	DM_API  int DC_IsPointInQuadrilateral(const DM_Point* point, const Quadrilateral* quad);
	DM_API  int DC_GetQuadrilateralArea(const Quadrilateral* quad);
	DM_API  int DC_GetIdleInstanceCount();
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
namespace dynamsoft
{
	namespace core
	{
		class DM_API CLicenseManager
		{
		public:
			static int InitLicense(const char* pLicense,char errorMsgBuffer[] = NULL,const int errorMsgBufferLen = 0);
			static int GetIdleInstanceCount();
		};

#pragma pack(push)
#pragma pack(1)

		class DM_API CPoint
		{
		public:
			int coordinate[2];
		};

		class DM_API CQuadrilateral
		{
		public:
			CPoint points[4];

			bool IsPointInQuadrilateral(const CPoint* point) const;
			int GetArea() const;
		};

		class DM_API CImageData
		{
		protected:
			int bytesLength;
			unsigned char* bytes;
			int width;
			int height;
			int stride;
			ImagePixelFormat format;
			int orientation;
		public:
			CImageData();
			CImageData(int _l, unsigned char* _b, int _w, int _h, int _s, ImagePixelFormat _f, int _o = 0);
			~CImageData();

			const unsigned char* const GetBytes() const;
			int GetBytesLength() const;
			int GetWidth() const;
			int GetHeight() const;
			int GetStride() const;
			ImagePixelFormat GetImagePixelFormat() const;
			int GetOrientation() const;

		private:
			CImageData(const CImageData&) = delete;
			CImageData& operator=(const CImageData&) = delete;
		};

#pragma pack(pop)
	}
}

#endif
#endif