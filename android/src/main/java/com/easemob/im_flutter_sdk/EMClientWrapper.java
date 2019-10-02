package com.easemob.im_flutter_sdk;

import java.util.Map;
import java.util.HashMap;

import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.EMCallBack;
import com.hyphenate.exceptions.HyphenateException;

public class EMClientWrapper implements MethodCallHandler, EMWrapper{
    EMClientWrapper(Context context) {
        this.context = context;
    }

    private Context context;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (EMSDKMethod.init.equals(call.method)) {
            init(call.arguments, result);
        } else if(EMSDKMethod.login.equals(call.method)){
            login(call.arguments, result);
        } else if(EMSDKMethod.createAccount.equals(call.method)) {
            createAccount(call.arguments, result);
        }
    }

    private void init(Object args, Result result) {
        EMOptions options = new EMOptions();
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        options.setAppKey((String)argMap.get("appKey"));
        EMClient.getInstance().init(context, options);
    }

    private void login(Object args, Result result) {
        assert(args instanceof Map);
        Map argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        EMClient.getInstance().login(userName, password, new EMCallBack(){
            @Override
            public void onSuccess() {
                post((Void)-> {
                        Map<String, Object> data = new HashMap<String, Object>();
                        data.put("success", Boolean.TRUE);
                        result.success(data);
                    });
            }

            @Override
            public void onError(int code, String error) {
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.FALSE);
                    data.put("code", code);
                    data.put("desc", error);
                    result.success(data);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                // not needed
            }
        });
    }

    private void createAccount(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        try{
            EMClient.getInstance().createAccount(userName, password);
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }
}

