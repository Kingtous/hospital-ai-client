cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# set(OpenCV_DIR "C:/Users/a1147/Documents/opencv/build/x64/vc16/lib")
find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "alert_controller.cpp"
  "Runner.rc"
  "runner.exe.manifest"
)

add_executable(test_alert 
  "test_alert_model.cpp"
  "alert_controller.cpp"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

target_include_directories(${BINARY_NAME} PRIVATE "includes")
target_include_directories(test_alert PRIVATE "includes")
# Release需要管理員權限
# SET_TARGET_PROPERTIES(${BINARY_NAME} PROPERTIES LINK_FLAGS    "/MANIFESTUAC:\"level='requireAdministrator' uiAccess='false'\" /SUBSYSTEM:WINDOWS" CONFIGURATIONS Release)

set_property(TARGET ${BINARY_NAME} PROPERTY COMPILE_WARNING_AS_ERROR OFF)

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

message(STATUS "found opencv" ${OpenCV_LIBS})

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_link_libraries(${BINARY_NAME} PRIVATE ${OpenCV_LIBS} )
target_link_libraries(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/libs/onnxruntime.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

target_link_libraries(test_alert PRIVATE ${OpenCV_LIBS})
target_link_libraries(test_alert PRIVATE "${CMAKE_SOURCE_DIR}/libs/onnxruntime.lib")