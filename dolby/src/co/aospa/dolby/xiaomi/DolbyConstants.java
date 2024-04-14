/*
 * Copyright (C) 2023-24 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package co.aospa.dolby.xiaomi;

class DolbyConstants {

    enum DsParam {
        HEADPHONE_VIRTUALIZER(101),
        SPEAKER_VIRTUALIZER(102),
        VOLUME_LEVELER_ENABLE(103),
        DIALOGUE_ENHANCER_ENABLE(105),
        DIALOGUE_ENHANCER_AMOUNT(108),
        GEQ_BAND_GAINS(110, 20),
        BASS_ENHANCER_ENABLE(111),
        STEREO_WIDENING_AMOUNT(113),
        VOLUME_LEVELER_AMOUNT(116);

        public int id, length;

        DsParam(int id, int length) {
            this.id = id;
            this.length = length;
        }

        DsParam(int id) {
            this(id, 1);
        }

        public String toString() {
            return String.format("%s(%s)", name(), id);
        }
    }

}
