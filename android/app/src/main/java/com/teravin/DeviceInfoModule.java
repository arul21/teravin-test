package com.teravin;
 
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import android.os.Build;
import java.util.Map;
import android.content.pm.PackageInfo;
import java.util.HashMap;
import android.os.StatFs;
import com.facebook.react.bridge.Promise;
import android.os.Environment;
import java.math.BigInteger;
 
public class DeviceInfoModule extends ReactContextBaseJavaModule {
 
    public DeviceInfoModule(ReactApplicationContext reactContext) {
        super(reactContext); 
    }
 
    @Override
    public String getName() { 
        return "DeviceInfoGet";
    }

    @Override
    public Map<String, Object> getConstants() {
      String appVersion, buildNumber, appName;

      try {
        appVersion = getPackageInfo().versionName;
        buildNumber = Integer.toString(getPackageInfo().versionCode);
        appName = getReactApplicationContext().getApplicationInfo().loadLabel(getReactApplicationContext().getPackageManager()).toString();
      } catch (Exception e) {
        appVersion = "unknown";
        buildNumber = "unknown";
        appName = "unknown";
      }

      final Map<String, Object> constants = new HashMap<>();
      constants.put("systemName", "Android");
      constants.put("brand", Build.BRAND);
      constants.put("model", Build.MODEL);
      constants.put("systemVersion", Build.VERSION.RELEASE);
      return constants;
    }

   private PackageInfo getPackageInfo() throws Exception {
    return getReactApplicationContext().getPackageManager().getPackageInfo(getReactApplicationContext().getPackageName(), 0);
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  public double getTotalDiskCapacitySync() {
    try {
      StatFs rootDir = new StatFs(Environment.getRootDirectory().getAbsolutePath());
      StatFs dataDir = new StatFs(Environment.getDataDirectory().getAbsolutePath());

      BigInteger rootDirCapacity = getDirTotalCapacity(rootDir);
      BigInteger dataDirCapacity = getDirTotalCapacity(dataDir);

      return rootDirCapacity.add(dataDirCapacity).doubleValue();
    } catch (Exception e) {
      return -1;
    }
  }
  @ReactMethod
  public void getTotalDiskCapacity(Promise p) { p.resolve(getTotalDiskCapacitySync()); }

  private BigInteger getDirTotalCapacity(StatFs dir) {
    boolean intApiDeprecated = Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2;
    long blockCount = intApiDeprecated ? dir.getBlockCountLong() : dir.getBlockCount();
    long blockSize = intApiDeprecated ? dir.getBlockSizeLong() : dir.getBlockSize();
    return BigInteger.valueOf(blockCount).multiply(BigInteger.valueOf(blockSize));
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  public double getFreeDiskStorageSync() {
    try {
      StatFs rootDir = new StatFs(Environment.getRootDirectory().getAbsolutePath());
      StatFs dataDir = new StatFs(Environment.getDataDirectory().getAbsolutePath());

      Boolean intApiDeprecated = Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2;
      long rootAvailableBlocks = getTotalAvailableBlocks(rootDir, intApiDeprecated);
      long rootBlockSize = getBlockSize(rootDir, intApiDeprecated);
      double rootFree = BigInteger.valueOf(rootAvailableBlocks).multiply(BigInteger.valueOf(rootBlockSize)).doubleValue();

      long dataAvailableBlocks = getTotalAvailableBlocks(dataDir, intApiDeprecated);
      long dataBlockSize = getBlockSize(dataDir, intApiDeprecated);
      double dataFree = BigInteger.valueOf(dataAvailableBlocks).multiply(BigInteger.valueOf(dataBlockSize)).doubleValue();

      return rootFree + dataFree;
    } catch (Exception e) {
      return -1;
    }
  }
  @ReactMethod
  public void getFreeDiskStorage(Promise p) { p.resolve(getFreeDiskStorageSync()); }

  private long getTotalAvailableBlocks(StatFs dir, Boolean intApiDeprecated) {
    return (intApiDeprecated ? dir.getAvailableBlocksLong() : dir.getAvailableBlocks());
  }

  private long getBlockSize(StatFs dir, Boolean intApiDeprecated) {
    return (intApiDeprecated ? dir.getBlockSizeLong() : dir.getBlockSize());
  }

 
}