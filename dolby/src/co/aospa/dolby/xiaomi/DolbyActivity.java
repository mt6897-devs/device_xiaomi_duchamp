/*
 * Copyright (C) 2023-24 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package co.aospa.dolby.xiaomi;

import android.os.Bundle;

import com.android.settingslib.collapsingtoolbar.CollapsingToolbarBaseActivity;

public class DolbyActivity extends CollapsingToolbarBaseActivity {

    private static final String TAG_DOLBY = "DolbyActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getFragmentManager().beginTransaction().replace(com.android.settingslib.collapsingtoolbar.R.id.content_frame,
                new DolbySettingsFragment(), TAG_DOLBY).commit();
    }
}
