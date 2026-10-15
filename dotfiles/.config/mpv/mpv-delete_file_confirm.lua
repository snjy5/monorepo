local deleting = false

function remove_and_delete_current_file()
    local path = mp.get_property("path")
    if path then
        -- Remove from playlist first
        mp.command("playlist-remove")
        mp.command("playlist-next")
        -- Delete from disk safely
        local ok, err = pcall(function()
            os.remove(path)
        end)
        if ok then
            mp.osd_message("Removed and deleted: " .. path, 3)
        else
            mp.osd_message("Removed from playlist but deletion failed: " .. err, 3)
        end
    else
        mp.osd_message("No file to remove/delete", 3)
    end
end

mp.add_key_binding("Ctrl+d", "remove-delete-confirm", function()
    if deleting then return end
    deleting = true
    mp.osd_message("Press Ctrl+x to confirm removal and deletion", 5)

    local confirm_timer = mp.add_timeout(5, function()
        deleting = false
        mp.remove_key_binding("confirm-remove-delete")
    end)

    mp.add_key_binding("Ctrl+x", "confirm-remove-delete", function()
        confirm_timer:kill()
        remove_and_delete_current_file()
        deleting = false
        mp.remove_key_binding("confirm-remove-delete")
    end, {repeatable=false})
end)
