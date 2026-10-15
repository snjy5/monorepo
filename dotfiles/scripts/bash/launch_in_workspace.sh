cur_workspace=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
selected_app=$(dmenu_path | dmenu -i)

if [ ! -z "$selected_app" ]; then
    i3-msg "workspace $cur_workspace; exec --no-startup-id $selected_app"
fi
