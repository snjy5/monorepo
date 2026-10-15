#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 --source <path> --dest <path> [options]

Required Options:
  -s, --source <path>  Path to legacy source file OR directory
  -d, --dest <path>    Destination target file OR directory

Optional Options:
  -h, --help           Show this help message and exit
EOF
    exit 1
}

PARSED_ARGS=$(getopt -o "s:d:h" --long "source:,dest:,help" -n "$0" -- "$@")
eval set -- "$PARSED_ARGS"

SOURCE_PATH=""
TARGET_PATH=""

while true; do
    case "$1" in
        -s|--source)
            SOURCE_PATH="${2%/}"
            shift 2
            ;;
        -d|--dest)
            TARGET_PATH="${2%/}"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unexpected option: $1" >&2
            usage
            ;;
    esac
done

if [[ -z "$SOURCE_PATH" || -z "$TARGET_PATH" ]]; then
    echo "Error: --source and --dest are required." >&2
    usage
fi

if [[ ! -e "$SOURCE_PATH" ]]; then
    echo "Error: Source '$SOURCE_PATH' does not exist." >&2
    exit 1
fi

export SOURCE_PATH
export TARGET_PATH

echo "=== Configuration ==="
echo "Source: $SOURCE_PATH"
echo "Dest:   $TARGET_PATH"
echo "====================="

# Core processing logic extracted to handle arbitrary files
process_file() {
    local src_file="$1"
    local target_file="$2"
    local display_name="$3"

    mkdir -p "$(dirname "$target_file")"

    if [[ ! -f "$target_file" ]]; then
        echo "[NEW]        -> $display_name"
        cp -p "$src_file" "$target_file"
    elif cmp -s "$src_file" "$target_file"; then
        # Silently skip identical files for speed
        :
    else
        echo "[CONFLICT]   -> $display_name"
        git merge-file -q -L "dest:$display_name" -L "ancestor:none" -L "source:$src_file" \
            "$target_file" /dev/null "$src_file" || true
    fi
}
export -f process_file

if [[ -d "$SOURCE_PATH" ]]; then
    echo "Processing directory..."
    # Blast through directory files 8 at a time
    find "$SOURCE_PATH" -type f -print0 | xargs -0 -n 1 -P 8 bash -c '
        src_file="$1"
        rel_path="${src_file#$SOURCE_PATH/}"
        target_file="$TARGET_PATH/$rel_path"
        process_file "$src_file" "$target_file" "$rel_path"
    ' _
elif [[ -f "$SOURCE_PATH" ]]; then
    echo "Processing single file..."
    if [[ -d "$TARGET_PATH" ]]; then
        # Target is a directory, place file inside it
        final_target="$TARGET_PATH/$(basename "$SOURCE_PATH")"
        display_name="$(basename "$SOURCE_PATH")"
    else
        # Target is an exact file path
        final_target="$TARGET_PATH"
        display_name="$(basename "$TARGET_PATH")"
    fi
    process_file "$SOURCE_PATH" "$final_target" "$display_name"
fi

echo ""
echo "=== Done! ==="
