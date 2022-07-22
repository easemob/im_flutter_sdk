package com.easemob.im_flutter_sdk;

import java.util.ArrayList;
import java.util.List;

public class EMListenerHandle {

    static private EMListenerHandle handle;

    private List<Runnable> emActionHandle;

    private boolean hasReady;


    public static EMListenerHandle getInstance() {
        if (handle == null) {
            handle = new EMListenerHandle();
        }
        return handle;
    }

    private EMListenerHandle(){
        emActionHandle = new ArrayList<>();
    }

    void addHandle(Runnable runnable) {
        emActionHandle.add(runnable);
        if (hasReady) {
            runHandle();
        }
    }

    void runHandle() {
        synchronized (emActionHandle){
            List<Runnable> tmp = emActionHandle;
            for (Runnable action : tmp) {
                action.run();
            }
            emActionHandle.clear();
        }
    }

    void startCallback(){
        hasReady = true;
        runHandle();
    }

    void clearHandle(){
        hasReady = false;
        synchronized (emActionHandle) {
            emActionHandle.clear();
        }
    }
}
