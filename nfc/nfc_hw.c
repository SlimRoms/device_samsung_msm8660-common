/*
 * Copyright 2016 The CyanogenMod Project
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
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include <hardware/hardware.h>
#include <hardware/nfc.h>

static uint8_t pn544_eedata_settings[][4] = {
    // DIFFERENTIAL_ANTENNA

    // RF Settings
    {0x00,0x9B,0xD1,0x0D} // Tx consumption higher than 0x0D (average 50mA)
    ,{0x00,0x9B,0xD2,0x24} // GSP setting for this threshold
    ,{0x00,0x9B,0xD3,0x0A} // Tx consumption higher than 0x0A (average 40mA)
    ,{0x00,0x9B,0xD4,0x22} // GSP setting for this threshold
    ,{0x00,0x9B,0xD5,0x08} // Tx consumption higher than 0x08 (average 30mA)
    ,{0x00,0x9B,0xD6,0x1E} // GSP setting for this threshold
    ,{0x00,0x9B,0xDD,0x1C} // GSP setting for this threshold
    ,{0x00,0x9B,0x84,0x13} // ANACM2 setting
    ,{0x00,0x99,0x81,0x7F} // ANAVMID setting PCD
    ,{0x00,0x99,0x31,0x70} // ANAVMID setting PICC

    // Enable PBTF
    ,{0x00,0x98,0x00,0x3F} // SECURE_ELEMENT_CONFIGURATION - No Secure Element
    ,{0x00,0x9F,0x09,0x00} // SWP_PBTF_RFU
    ,{0x00,0x9F,0x0A,0x05} // SWP_PBTF_RFLD  --> RFLEVEL Detector for PBTF
    ,{0x00,0x9E,0xD1,0xA1} //

    // Change RF Level Detector ANARFLDWU
    ,{0x00,0x99,0x23,0x00} // Default Value is 0x01

    // Polling Loop Optimisation Detection  - 0x86 to enable - 0x00 to disable
    ,{0x00,0x9E,0x74,0x00} // Default Value is 0x00, bits 0->2: sensitivity (0==maximal, 6==minimal), bits 3->6: RFU, bit 7: (0 -> disabled, 1 -> enabled)

    // Polling Loop - Card Emulation Timeout
    ,{0x00,0x9F,0x35,0x14} // Time for which PN544 stays in Card Emulation mode after leaving RF field
    ,{0x00,0x9F,0x36,0x60} // Default value 0x0411 = 50 ms ---> New Value : 0x1460 = 250 ms

    //LLC Timer
    ,{0x00,0x9C,0x31,0x00} //
    ,{0x00,0x9C,0x32,0x00} //
    ,{0x00,0x9C,0x0C,0x00} //
    ,{0x00,0x9C,0x0D,0x00} //
    ,{0x00,0x9C,0x12,0x00} //
    ,{0x00,0x9C,0x13,0x00} //

    //WTX for LLCP communication
    ,{0x00,0x98,0xA2,0x0E} // Max value: 14 (default value: 09)

    //Murata Resonator setting
    ,{0x00,0x9C,0x5C,0x06} // default 0x0140 = 1ms
    ,{0x00,0x9C,0x5D,0x81} // 0x0681(= 5ms) is recommended value by Murata
    ,{0x00,0x9F,0x19,0xFF} // nxp test 3sec
    ,{0x00,0x9F,0x1A,0xFF} // nxp test 3sec

    // Set NFCT ATQA
    ,{0x00,0x98,0x7D,0x02}
    ,{0x00,0x98,0x7E,0x00}
};

static int pn544_close(hw_device_t *dev) {
    free(dev);

    return 0;
}

/*
 * Generic device handling
 */

static int nfc_open(const hw_module_t* module, const char* name,
        hw_device_t** device) {
    if (strcmp(name, NFC_PN544_CONTROLLER) == 0) {
        nfc_pn544_device_t *dev = calloc(1, sizeof(nfc_pn544_device_t));

        dev->common.tag = HARDWARE_DEVICE_TAG;
        dev->common.version = 0;
        dev->common.module = (struct hw_module_t*) module;
        dev->common.close = pn544_close;

        dev->num_eeprom_settings = sizeof(pn544_eedata_settings) / 4;
        dev->eeprom_settings = (uint8_t*)pn544_eedata_settings;
        dev->linktype = PN544_LINK_TYPE_I2C;
        dev->device_node = "/dev/pn544";
        dev->enable_i2c_workaround = 0;
        *device = (hw_device_t*) dev;
        return 0;
    } else {
        return -EINVAL;
    }
}

static struct hw_module_methods_t nfc_module_methods = {
    .open = nfc_open,
};

struct nfc_module_t HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .version_major = 1,
        .version_minor = 0,
        .id = NFC_HARDWARE_MODULE_ID,
        .name = "S4 NFC HW HAL",
        .author = "The Android Open Source Project",
        .methods = &nfc_module_methods,
    },
};
