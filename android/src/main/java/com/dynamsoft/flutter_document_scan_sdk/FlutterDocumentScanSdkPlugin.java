package com.dynamsoft.flutter_document_scan_sdk;

import androidx.annotation.NonNull;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import android.app.Activity;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import android.util.Log;

import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.core.basic_structures.EnumImagePixelFormat;
import com.dynamsoft.ddn.EnhancedImageResultItem;
import com.dynamsoft.ddn.ProcessedDocumentResult;
import com.dynamsoft.ddn.EnumImageColourMode;
import com.dynamsoft.ddn.DetectedQuadResultItem;

import android.graphics.Point;

/** FlutterDocumentScanSdkPlugin */
public class FlutterDocumentScanSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private static String TAG = "DCV";
  private MethodChannel channel;
  private HandlerThread mHandlerThread;
  private Handler mHandler;
  private final Executor mExecutor;
  private FlutterPluginBinding flutterPluginBinding;
  private Activity activity;
  private CaptureVisionRouter mRouter;

  public FlutterDocumentScanSdkPlugin() {
    mHandler = new Handler(Looper.getMainLooper());
    mExecutor = Executors.newSingleThreadExecutor();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_document_scan_sdk");
    channel.setMethodCallHandler(this);
    this.flutterPluginBinding = flutterPluginBinding;
  }

  private void checkInstantce() {
    if (mRouter == null) {
            mRouter = new CaptureVisionRouter(activity);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "init": {
        checkInstantce();

        final String license = call.argument("key");
        LicenseManager.initLicense(
            license, activity,
                (isSuccess, error) -> {
            if (!isSuccess) {
                result.success(-1);
            }
            else {
                result.success(0);
            }
        });
        break;
      }
      case "setParameters": {
        checkInstantce();

        final String params = call.argument("params");
        try {
            mRouter.initSettings(params);
            result.success(0);
        } catch (CaptureVisionRouterException e) {
            result.success(-1);
        }
        break;
      }
      case "getParameters": {
        checkInstantce();

        String parameters = "";
        try {
            parameters = mRouter.outputSettings("", false);
          } catch (Exception e) {
            result.success(e.toString());
            return;
          }
        result.success(parameters);
        break;
      }
      case "detectBuffer": {
        checkInstantce();
        
        List<Map<String, Object>> out = new ArrayList<>();
        final byte[] bytes = call.argument("bytes");
        final int width = call.argument("width");
        final int height = call.argument("height");
        final int stride = call.argument("stride");
        final int format = call.argument("format");
        final int rotation = call.argument("rotation");
        final Result r = result;

        mExecutor.execute(new Runnable() {
          @Override
          public void run() {
            ImageData imageData = new ImageData();
            imageData.bytes = bytes;
            imageData.width = width;
            imageData.height = height;
            imageData.stride = stride;
            imageData.format = format;
            imageData.orientation = rotation;

            List<Map<String, Object>> tmp = new ArrayList<>();
            CapturedResult results = mRouter.capture(imageData, EnumPresetTemplate.PT_DETECT_DOCUMENT_BOUNDARIES);
            tmp = createContourList(results);
            
            final List<Map<String, Object>> out = tmp;
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    r.success(out);
                }
            });
          }
        });
        break;
      }
      case "normalizeBuffer": {

        checkInstantce();

        Map<String, Object> map = new HashMap<>();

        final byte[] bytes = call.argument("bytes");
        final int width = call.argument("width");
        final int height = call.argument("height");
        final int stride = call.argument("stride");
        final int format = call.argument("format");
        final int x1 = call.argument("x1");
        final int y1 = call.argument("y1");
        final int x2 = call.argument("x2");
        final int y2 = call.argument("y2");
        final int x3 = call.argument("x3");
        final int y3 = call.argument("y3");
        final int x4 = call.argument("x4");
        final int y4 = call.argument("y4");
        final int rotation = call.argument("rotation");
        final int mode = call.argument("color");

        ImageData buffer = new ImageData();
        buffer.bytes = bytes;
        buffer.width = width;
        buffer.height = height;
        buffer.stride = stride;
        buffer.format = format;
        buffer.orientation = rotation;

        try {
          Quadrilateral quad = new Quadrilateral();
          quad.points = new Point[4];
          quad.points[0] = new Point(x1, y1);
          quad.points[1] = new Point(x2, y2);
          quad.points[2] = new Point(x3, y3);
          quad.points[3] = new Point(x4, y4);

          SimplifiedCaptureVisionSettings settings = mRouter.getSimplifiedSettings(EnumPresetTemplate.PT_NORMALIZE_DOCUMENT);
          settings.roi = quad;
          settings.roiMeasuredInPercentage = false;
          settings.documentSettings.colourMode = mode;
          mRouter.updateSettings(EnumPresetTemplate.PT_NORMALIZE_DOCUMENT, settings);

          CapturedResult data = mRouter.capture(buffer, EnumPresetTemplate.PT_NORMALIZE_DOCUMENT);

          map = createNormalizedImage(data);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        result.success(map);
        break;
      }
      case "detectFile": {

        checkInstantce();

        final String filename = call.argument("file");
        List<Map<String, Object>> out = new ArrayList<>();
        CapturedResult results = mRouter.capture(filename, EnumPresetTemplate.PT_DETECT_DOCUMENT_BOUNDARIES);
        out = createContourList(results);
        result.success(out);
        break;
      }
      case "normalizeFile": {

        checkInstantce();

        final String filename = call.argument("file");
        final int x1 = call.argument("x1");
        final int y1 = call.argument("y1");
        final int x2 = call.argument("x2");
        final int y2 = call.argument("y2");
        final int x3 = call.argument("x3");
        final int y3 = call.argument("y3");
        final int x4 = call.argument("x4");
        final int y4 = call.argument("y4");
        final int mode = call.argument("color");

        Map<String, Object> map = new HashMap<>();
        try {
          Quadrilateral quad = new Quadrilateral();
          quad.points = new Point[4];
          quad.points[0] = new Point(x1, y1);
          quad.points[1] = new Point(x2, y2);
          quad.points[2] = new Point(x3, y3);
          quad.points[3] = new Point(x4, y4);

          SimplifiedCaptureVisionSettings settings = mRouter.getSimplifiedSettings(EnumPresetTemplate.PT_NORMALIZE_DOCUMENT);
          settings.roi = quad;
          settings.roiMeasuredInPercentage = false;
          settings.documentSettings.colourMode = mode;
          mRouter.updateSettings(EnumPresetTemplate.PT_NORMALIZE_DOCUMENT, settings);

          CapturedResult data = mRouter.capture(filename, EnumPresetTemplate.PT_NORMALIZE_DOCUMENT);

          map = createNormalizedImage(data);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        result.success(map);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  List<Map<String, Object>> createContourList(CapturedResult result) {
    List<Map<String, Object>> out = new ArrayList<>();
    
    if (result != null && result.getItems().length > 0) {
        CapturedResultItem[] items = result.getItems();
        for (CapturedResultItem item : items) {
          if (item instanceof DetectedQuadResultItem) {
            Map<String, Object> map = new HashMap<>();

            DetectedQuadResultItem quadItem = (DetectedQuadResultItem) item;
            int confidence = quadItem.getConfidenceAsDocumentBoundary();
            Point[] points = quadItem.getLocation().points;
            int x1 = points[0].x;
            int y1 = points[0].y;
            int x2 = points[1].x;
            int y2 = points[1].y;
            int x3 = points[2].x;
            int y3 = points[2].y;
            int x4 = points[3].x;
            int y4 = points[3].y;

            map.put("confidence", confidence);
            map.put("x1", x1);
            map.put("y1", y1);
            map.put("x2", x2);
            map.put("y2", y2);
            map.put("x3", x3);
            map.put("y3", y3);
            map.put("x4", x4);
            map.put("y4", y4);
            
            out.add(map);
          }
        }
    }
    return out;
  }

  Map<String, Object> createNormalizedImage(CapturedResult result) {
      ProcessedDocumentResult normalizedImageResult = result.getProcessedDocumentResult();
      Map<String, Object> map = new HashMap<>();

      if (normalizedImageResult != null && normalizedImageResult.getEnhancedImageResultItems().length > 0) {
          EnhancedImageResultItem item = normalizedImageResult.getEnhancedImageResultItems()[0];
          ImageData imageData = item.getImageData();

          int width = imageData.width;
          int height = imageData.height;
          int stride = imageData.stride;
          int format = imageData.format;
          byte[] data = imageData.bytes;
          int length = imageData.bytes.length;
          int orientation = imageData.orientation;

          map.put("width", width);
          map.put("height", height);
          map.put("stride", stride);
          map.put("format", format);
          map.put("orientation", orientation);
          map.put("length", length);

          byte[] rgba = new byte[width * height * 4];

          if (format == EnumImagePixelFormat.IPF_RGB_888) {
              int dataIndex = 0;
              for (int i = 0; i < height; i++)
              {
                  for (int j = 0; j < width; j++)
                  {
                      int index = i * width + j;

                      rgba[index * 4] = data[dataIndex];     // red
                      rgba[index * 4 + 1] = data[dataIndex + 1]; // green
                      rgba[index * 4 + 2] = data[dataIndex + 2];     // blue
                      rgba[index * 4 + 3] = (byte)255;                 // alpha
                      dataIndex += 3;
                  }
              }
          }
          else if (format == EnumImagePixelFormat.IPF_GRAYSCALED | format == EnumImagePixelFormat.IPF_BINARY_8_INVERTED | format == EnumImagePixelFormat.IPF_BINARY_8) {
              int dataIndex = 0;
              for (int i = 0; i < height; i++)
              {
                  for (int j = 0; j < width; j++)
                  {
                      int index = i * width + j;
                      rgba[index * 4] = data[dataIndex];
                      rgba[index * 4 + 1] = data[dataIndex];
                      rgba[index * 4 + 2] = data[dataIndex];
                      rgba[index * 4 + 3] = (byte)255;
                      dataIndex += 1;
                  }
              }
          }
      else if (format == EnumImagePixelFormat.IPF_BINARY) {
        byte[] grayscale = new byte[width * height];
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
                rgba[index * 4 + 3] = (byte)255;
                dataIndex += 1;
            }
        }
      }
          map.put("data", rgba);
      }


      return map;
  }

  void binary2grayscale(byte[] data, byte[] output, int width, int height, int stride, int length) {
    int index = 0;

    int skip = stride * 8 - width;
    int shift = 0;
    int n = 1;

    for (int i = 0; i < length; ++i)
    {
        byte b = data[i];
        int byteCount = 7;
        while (byteCount >= 0)
        {
            int tmp = (b & (1 << byteCount)) >> byteCount;

            if (shift < stride * 8 * n - skip)
            {
                if (tmp == 1)
                    output[index] = (byte)255;
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

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    flutterPluginBinding = null;
  }

  private void bind(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    bind(activityPluginBinding);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    bind(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }
}
