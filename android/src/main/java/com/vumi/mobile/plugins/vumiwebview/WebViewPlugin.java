package com.vumi.mobile.plugins.vumiwebview;

import com.getcapacitor.Logger;

public class WebViewPlugin {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
