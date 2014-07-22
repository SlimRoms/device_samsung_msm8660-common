/*
 * Copyright (C) 2012 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.cyanogenmod.settings.device;

import android.os.Bundle;
import android.preference.PreferenceFragment;
import android.preference.PreferenceGroup;
import com.cyanogenmod.settings.device.R;
import com.cyanogenmod.settings.device.DisplayColor;
import com.cyanogenmod.settings.device.DisplayGamma;

public class ScreenFragmentActivity extends PreferenceFragment {

    private TouchscreenSensitivity mTouchscreenSensitivity;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        addPreferencesFromResource(R.xml.screen_preferences);

        final PreferenceGroup calibrationCategory =
                (PreferenceGroup) findPreference(DisplaySettings.KEY_DISPLAY_CALIBRATION_CATEGORY);

        if (!DisplayColor.isSupported() && !DisplayGamma.isSupported()) {
            getPreferenceScreen().removePreference(calibrationCategory);
        } else {
            if (!DisplayColor.isSupported()) {
                calibrationCategory.removePreference(findPreference(DisplaySettings.KEY_DISPLAY_COLOR));
            }
            if (!DisplayGamma.isSupported()) {
                calibrationCategory.removePreference(findPreference(DisplaySettings.KEY_DISPLAY_GAMMA));
            }
        }
        mTouchscreenSensitivity = (TouchscreenSensitivity) findPreference(DisplaySettings.KEY_TOUCHSCREEN_SENSITIVITY);
        mTouchscreenSensitivity.setEnabled(mTouchscreenSensitivity.isSupported());
    }

}
