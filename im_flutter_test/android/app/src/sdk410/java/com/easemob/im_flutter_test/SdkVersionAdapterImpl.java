package com.easemob.im_flutter_test;

import org.json.JSONObject;

import java.util.Collections;
import java.util.Set;

final class SdkVersionAdapterImpl implements SdkVersionAdapter {
    @Override
    public Set<String> capabilities() {
        return Collections.emptySet();
    }

    @Override
    public boolean invokeGroup(
            String method,
            JSONObject arguments,
            NativeSdkBridge.NativeCallback callback
    ) {
        return false;
    }
}
