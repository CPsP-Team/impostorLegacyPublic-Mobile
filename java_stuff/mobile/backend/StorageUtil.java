package mobile.backend;

import android.os.StatFs;
import android.util.Log;

public class StorageUtil {
    public static double getFreeSpaceMB(String path) {
        try {
            StatFs stat = new StatFs(path);
            long bytesAvailable = stat.getAvailableBlocksLong() * stat.getBlockSizeLong();
            return (double) bytesAvailable / (1024.0 * 1024.0);
        } catch (Exception e) {
            Log.e("StorageUtil", "Failed to get free space for " + path + ": " + e.toString());
            return -1.0;
        }
    }
}
