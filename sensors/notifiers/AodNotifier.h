/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include "SensorNotifier.h"

class AodNotifier : public SensorNotifier {
  public:
    AodNotifier(sp<ISensorManager> manager);
    ~AodNotifier();

  protected:
    void notify();
};
