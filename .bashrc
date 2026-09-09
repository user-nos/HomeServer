# run fastfetch when logging in
fastfetch

# custom command to abbreviate rsync file moving using screen for background prrocessing as default or directly in live terminal
movefiles() {
    SESSION_NAME="movefiles_job"

    # Check if the user passed --status
    if [ "$1" == "--status" ]; then
        if screen -list | grep -q "$SESSION_NAME"; then
            echo "--- Active File Transfer Jobs Found ---"
            screen -list | grep "$SESSION_NAME"
            echo ""
            echo "To view live progress, run: screen -r $SESSION_NAME"
            echo "To detach again without killing it, press: Ctrl+A then D"
        else
            echo "No active file transfers running in the background."
        fi
        return 0
    fi

    # Check if the user passed --live flag
    local LIVE_MODE=0
    if [ "$1" == "--live" ]; then
        LIVE_MODE=1
        # Remove --live from arguments list
        shift
    fi

    # Validate argument count (at least 1 source + 1 destination)
    if [ "$#" -lt 2 ]; then
        echo "Usage:"
        echo "  movefiles <source1> [source2 ...] <destination>          (Runs in background via screen)"
        echo "  movefiles --live <source1> [source2 ...] <destination>   (Runs live in current terminal)"
        echo "  movefiles --status                                      (Checks active background jobs)"
        return 1
    fi

    # Handle LIVE mode (Foreground execution)
    if [ "$LIVE_MODE" -eq 1 ]; then
        echo "Starting transfer live..."
        rsync -ahP --remove-source-files "$@"
        for var in "${@:1:$#-1}"; do
            if [ -d "$var" ]; then
                find "$var" -type d -empty -delete 2>/dev/null
            fi
        done
        echo "Transfer complete."
        return 0
    fi

    # Handle DEFAULT mode (Background via screen)
    echo "Starting transfer in background screen session: $SESSION_NAME..."

    screen -dmS "$SESSION_NAME" bash -c '
        rsync -ahP --remove-source-files "$@"
        for var in "${@:1:$#-1}"; do
            if [ -d "$var" ]; then
                find "$var" -type d -empty -delete 2>/dev/null
            fi
        done
        echo ""
        echo "Done! Press Enter to exit."
        read
    ' _ "$@"

    echo "Transfer started! You can safely close Cockpit or your browser."
    echo "Run 'movefiles --status' to check status, or 'screen -r $SESSION_NAME' to attach."
}
