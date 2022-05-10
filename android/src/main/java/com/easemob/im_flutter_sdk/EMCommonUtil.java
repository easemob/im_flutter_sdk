package com.easemob.im_flutter_sdk;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class EMCommonUtil {

    static public void putObjectToMap(Map map, String key, Object value) {
        if (value != null)
        {
            map.put(key, value);
        }
    }

    static Object getValueFromMap(Map map, String key) {
        if (map.containsKey(key)) {
            return map.get(key);
        }
        return null;
    }

    static Object getValueFromJsonObject(JSONObject jo, String key) {
        if (jo.has(key)) {
            try {
                return jo.get(key);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

}
