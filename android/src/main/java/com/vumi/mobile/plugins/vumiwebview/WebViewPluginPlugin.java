package com.vumi.mobile.plugins.vumiwebview;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import android.content.Intent;

@CapacitorPlugin(name = "WebViewPlugin")
public class WebViewPluginPlugin extends Plugin {

    private WebViewPlugin implementation = new WebViewPlugin();

    @PluginMethod
    public void openWebview(PluginCall call) {
        String url = call.getString("url");

        if (url == null || url.isEmpty()) {
            call.reject("URL is required");
            return;
        }

        Intent intent = new Intent(getContext(), TelemedicineActivity.class);
        intent.putExtra("url", url);
        getActivity().startActivity(intent);

        call.resolve();
    }
}
