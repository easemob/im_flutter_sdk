package com.easemob.im_flutter_sdk;

import java.util.ArrayList;
import java.util.List;

public class ListenerHandle {

    static private ListenerHandle handle;

    private List<Runnable> emActionHandle;

    private boolean hasReady;


    public static ListenerHandle getInstance() {
        if (handle == null) {
            handle = new ListenerHandle();
        }
        return handle;
    }

    private ListenerHandle(){
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
