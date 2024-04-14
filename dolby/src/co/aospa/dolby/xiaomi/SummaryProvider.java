/*
 * Copyright (C) 2019 The Android Open Source Project
 *           (C) 2023-24 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package co.aospa.dolby.xiaomi;

import static com.android.settingslib.drawer.TileUtils.META_DATA_PREFERENCE_SUMMARY;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;

import co.aospa.dolby.xiaomi.R;

import java.util.Arrays;
import java.util.List;

/** Provide preference summary for injected items. */
public class SummaryProvider extends ContentProvider {

    private static final String KEY_DOLBY = "dolby";

    @Override
    public Bundle call(String method, String uri, Bundle extras) {
        final Bundle bundle = new Bundle();
        String summary;
        switch (method) {
            case KEY_DOLBY:
                summary = getDolbySummary();
                break;
            default:
                throw new IllegalArgumentException("Unknown method: " + method);
        }
        bundle.putString(META_DATA_PREFERENCE_SUMMARY, summary);
        return bundle;
    }

    @Override
    public boolean onCreate() {
        return true;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs,
            String sortOrder) {
        throw new UnsupportedOperationException();
    }

    @Override
    public String getType(Uri uri) {
        throw new UnsupportedOperationException();
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        throw new UnsupportedOperationException();
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException();
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException();
    }

    private String getDolbySummary() {
        final DolbyUtils dolbyUtils = DolbyUtils.getInstance(getContext());
        final boolean dsOn = dolbyUtils.getDsOn();
        if (!dsOn) {
            return getContext().getString(R.string.dolby_off);
        }
        final String profileName = dolbyUtils.getProfileName();
        if (profileName == null) {
            return getContext().getString(R.string.dolby_on);
        } else {
            return getContext().getString(R.string.dolby_on_with_profile, profileName);
        }
    }

}
