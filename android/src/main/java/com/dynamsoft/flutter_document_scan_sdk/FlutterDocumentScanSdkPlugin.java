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

import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.ddn.NormalizedImageResultItem;

import android.graphics.Point;

/** FlutterDocumentScanSdkPlugin */
public class FlutterDocumentScanSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private HandlerThread mHandlerThread;
  private Handler mHandler;
  private final Executor mExecutor;
  private FlutterPluginBinding flutterPluginBinding;
  private Activity activity;
  private DocumentNormalizer mNormalizer;
  private NormalizedImageResult mNormalizedImage;

  public FlutterDocumentScanSdkPlugin() {
    mHandler = new Handler(Looper.getMainLooper());
    mExecutor = Executors.newSingleThreadExecutor();

    try {
        mNormalizer = new DocumentNormalizer();
    } catch (DocumentNormalizerException e) {
        e.printStackTrace();
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_document_scan_sdk");
    channel.setMethodCallHandler(this);
    this.flutterPluginBinding = flutterPluginBinding;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion": {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      }
      case "init": {
        final String license = call.argument("key");
        LicenseManager.initLicense(
            license, activity,
                new LicenseVerificationListener() {
                    @Override
                    public void licenseVerificationCallback(boolean isSuccessful, CoreException e) {
                        if (isSuccessful)
                        {
                            result.success(0);
                        }
                        else {
                            result.success(-1);
                        }
                    }
                });
        break;
      }
      case "setParameters": {
        final String params = call.argument("params");
        try {
            mNormalizer.initRuntimeSettingsFromString(params);
            result.success(0);
        } catch (DocumentNormalizerException e) {
          result.success(-1);
        }
        
        break;
      }
      case "getParameters": {
        String parameters = "";
        if (mNormalizer != null) {
            try {
              parameters = mNormalizer.outputRuntimeSettings("");
            } catch (Exception e) {
              // TODO: handle exception
            }
        }
        result.success(parameters);
        break;
      }
      case "detectBuffer": {
        List<Map<String, Object>> out = new ArrayList<>();
        final byte[] bytes = call.argument("bytes");
        final int width = call.argument("width");
        final int height = call.argument("height");
        final int stride = call.argument("stride");
        final int format = call.argument("format");
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

            List<Map<String, Object>> tmp = new ArrayList<>();
            try {
                DetectedQuadResult[] detectedResults = mNormalizer.detectQuad(imageData);
                tmp = WrapResults(detectedResults);
            } catch (DocumentNormalizerException e) {
                e.printStackTrace();
            }
            
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

        ImageData buffer = new ImageData();
        buffer.bytes = bytes;
        buffer.width = width;
        buffer.height = height;
        buffer.stride = stride;
        buffer.format = format;

        try {
          Quadrilateral quad = new Quadrilateral();
          quad.points = new Point[4];
          quad.points[0] = new Point(x1, y1);
          quad.points[1] = new Point(x2, y2);
          quad.points[2] = new Point(x3, y3);
          quad.points[3] = new Point(x4, y4);
          mNormalizedImage = mNormalizer.normalize(buffer, quad);

          map = createNormalizedImage();
        } catch (DocumentNormalizerException e) {
            e.printStackTrace();
        }

        result.success(map);
        break;
      }
      case "detectFile": {
        final String filename = call.argument("file");
        List<Map<String, Object>> out = new ArrayList<>();
        try {
            DetectedQuadResult[] detectedResults = mNormalizer.detectQuad(filename);
            out = WrapResults(detectedResults);
        } catch (DocumentNormalizerException e) {
            e.printStackTrace();
        }
        result.success(out);
        break;
      }
      case "normalizeFile": {
        final String filename = call.argument("file");
        final int x1 = call.argument("x1");
        final int y1 = call.argument("y1");
        final int x2 = call.argument("x2");
        final int y2 = call.argument("y2");
        final int x3 = call.argument("x3");
        final int y3 = call.argument("y3");
        final int x4 = call.argument("x4");
        final int y4 = call.argument("y4");

        Map<String, Object> map = new HashMap<>();
        try {
          Quadrilateral quad = new Quadrilateral();
          quad.points = new Point[4];
          quad.points[0] = new Point(x1, y1);
          quad.points[1] = new Point(x2, y2);
          quad.points[2] = new Point(x3, y3);
          quad.points[3] = new Point(x4, y4);
          mNormalizedImage = mNormalizer.normalize(filename, quad);

          map = createNormalizedImage();
        } catch (DocumentNormalizerException e) {
            e.printStackTrace();
        }

        result.success(map);
        break;
      }
      case "save": {
        final String filename = call.argument("filename");
        if (mNormalizedImage != null) {
          try {
            mNormalizedImage.saveToFile(filename);
          } catch (Exception e) {
            
          }
        }
        result.success(0);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  List<Map<String, Object>> WrapResults(DetectedQuadResult[] detectedResults) {
    List<Map<String, Object>> out = new ArrayList<>();
    if (detectedResults != null && detectedResults.length > 0) {
        for (int i = 0; i < detectedResults.length; i++) {
            Map<String, Object> map = new HashMap<>();

            DetectedQuadResult detectedResult = detectedResults[i];
            int confidence = detectedResult.confidenceAsDocumentBoundary;
            Point[] points = detectedResult.location.points;
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
    return out;
  }

  Map<String, Object> createNormalizedImage() {
    Map<String, Object> map = new HashMap<>();

    if (mNormalizedImage != null) {
      ImageData imageData = mNormalizedImage.image;
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
      else if (format == EnumImagePixelFormat.IPF_GRAYSCALED) {
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
