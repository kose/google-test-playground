cmake_minimum_required(VERSION 3.14) # FetchContentには3.14以上を推奨
project(MyProject)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# カバレッジ設定
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-fprofile-arcs -ftest-coverage)
    add_link_options(--coverage)
endif()

# --- GoogleTestの自動ダウンロード設定 ---
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
# For Windows: GTestがランタイムライブラリを上書きしないように設定（macOSでは影響なし）
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)
# ---------------------------------------

# src ディレクトリ内のすべての .cc ファイルを取得
file(GLOB SOURCE_FILES src/*.cc)

# unit-test ディレクトリ内のすべての .cc ファイルを取得
file(GLOB TEST_FILES unit-test/*.cc)

add_executable(runUnitTests ${SOURCE_FILES} ${TEST_FILES})

# 取得されたファイル一覧をログ出力（ビルド時に確認用）
message(STATUS "Source files: ${SOURCE_FILES}")
message(STATUS "Test files: ${TEST_FILES}")

# リンク先を gtest_main にすると、main関数を書かなくても自動実行されます
target_link_libraries(runUnitTests GTest::gtest_main)
target_include_directories(runUnitTests PUBLIC src)

include(GoogleTest)
gtest_discover_tests(runUnitTests)
