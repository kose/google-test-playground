#!/bin/bash

# エラーのとこで止まる
# set -e

# 1. ビルド
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(sysctl -n hw.ncpu)

# 2. テスト実行
echo "Running tests..."
./runUnitTests --gtest_output="xml:test_detail.xml"
TEST_RESULT=$?

# 3. カバレッジ抽出
echo "Step 3: Capturing coverage..."

# 「数字とドット」以外の文字を削除してから、最初のドットまでを切り出す
LCOV_VERSION=$(lcov --version | grep -oE '[0-9]+(\.[0-9]+)+' | cut -d. -f1)

# デバッグ用に変数の中身を表示しておくと安心です
echo "Detected LCOV version: $LCOV_VERSION"

# LCOV 2.x 用のオプションを整理
if [ -n "$LCOV_VERSION" ] && [ "$LCOV_VERSION" -ge 2 ]; then
    # 'category' を削除し、'gcov' と 'source' を追加して警告を完全に黙らせる
    # また、一部の環境で弾かれる可能性があるキーワードを除外した安定版セット
    LCOV_OPTS="--ignore-errors format,inconsistent,unsupported,unused,mismatch,gcov,source"
else
    LCOV_OPTS="--rc lcov_branch_coverage=1"
fi

# フィルタリング（lcov --extract / --remove）時にも --ignore-errors を付ける
# これをしないと、フィルタリング中にエラーが出て止まることがあります
lcov --capture --directory . --output-file coverage.info $LCOV_OPTS

# 4. フィルタリング (2ステップに分ける)
echo "Step 4: Filtering coverage..."

# 4-1. まず、src ディレクトリ直下のファイルだけを抽出
lcov --extract coverage.info "*/src/*" \
     --output-file coverage.src.info $LCOV_OPTS

# 4-2. 次に、もし抽出結果に build 内のファイル（自動生成コード等）が混ざっていれば削除
lcov --remove coverage.src.info "*/build/*" \
     --output-file coverage.filtered.info $LCOV_OPTS

SCRIPT_DIR=$(cd $(dirname $0); pwd)

# 5. HTML生成
if [ -s coverage.filtered.info ]; then
    echo "Step 5: Generating HTML reports..."
    genhtml coverage.filtered.info \
	    --output-directory ${SCRIPT_DIR}/build/coverage_html \
	    --ignore-errors source,mismatch

else
    echo "ERROR: フィルタリング後のカバレッジデータが空です。"
    echo "src フォルダ内のソースが正しく抽出されているか確認してください。"
    exit 1
fi

# 6. テスト結果のHTML変換 (uv)
echo "Step 6: Generating Test Detail HTML Report..."
uvx junit2html test_detail.xml test_detail.html

echo "-------------------------------------------------------"
echo "Done!"
echo "-------------------------------------------------------"

# cd /app
# mkdir -p result
# rsync -auv build/test_detail.html result/
# rsync -auv build/coverage_html result/

# end
