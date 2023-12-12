#include "alert_controller.h"
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <opencv2/core/core.hpp>
#include <onnxruntime/onnxruntime_cxx_api.h>
#include <opencv2/opencv.hpp>
#include <vector>
#include <string>
#include <iostream>
// #include <onnxruntime/core/providers/providers.h>
// #include <onnxruntime/core/providers/cpu/cpu_provider_factory.h>
#include <fstream>

int main() {
    alert_init();
    return 0;
}