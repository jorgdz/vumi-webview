package com.vumi.mobile.plugins.vumiwebview;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.PermissionRequest;
import android.widget.ImageView;
import android.widget.TextView;
import android.view.View;
import android.content.Intent;

public class TelemedicineActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_telemedicine);

        WebView webView = findViewById(R.id.webview);
        ImageView backButton = findViewById(R.id.back_button);
        TextView title = findViewById(R.id.title_text);

        Intent intent = getIntent();
        String url = intent.getStringExtra("url");

        title.setText("Telemedicine Service");

        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setMediaPlaybackRequiresUserGesture(false);
        webView.getSettings().setAllowContentAccess(true);
        webView.getSettings().setAllowFileAccess(true);
        
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onPermissionRequest(final PermissionRequest request) {
                runOnUiThread(() -> {
                    request.grant(request.getResources());
                });
            }
        });

        webView.setWebViewClient(new WebViewClient());
        webView.loadUrl(url);

        backButton.setOnClickListener(v -> finish());
    }
}
