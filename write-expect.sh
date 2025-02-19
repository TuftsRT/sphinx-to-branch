#!/bin/bash
EXPECT_PATTERNS="${EXPECT_PATTERNS/\$EXPECT_TIMEOUT/$EXPECT_TIMEOUT}"
cat > "$EXPECT_SCRIPT" <<EOF
#!/usr/bin/expect
set timeout $EXPECT_TIMEOUT
spawn $BUILD_CMD $BUILD_ARGS "$SRC_BRANCH/$SRC_DIR" "$OUT_BRANCH/$OUT_DIR"
expect {
EOF
# shellcheck disable=SC2086
grep '\S' <<< $EXPECT_PATTERNS >> "$EXPECT_SCRIPT"
cat >> "$EXPECT_SCRIPT" <<EOF
}
exit [lindex [wait] 3]
EOF
chmod +x "$EXPECT_SCRIPT"
