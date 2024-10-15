#!/usr/bin/env python

import html
import json
import gi
import sys
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib  # noqa: E402

ARTIST = 'xesam:artist'
TITLE = 'xesam:title'
ICONS = {
    'spotify': '阮 ',
    'ncspot': '阮 ',
    'vlc': '嗢 ',
    'firefox': ' ',
    'default': '契 ',
    'paused': ' '
}

last_status = None


def find_active_player(manager, vanished_player):
    for player in manager.props.players:
        if player == vanished_player:
            continue
        if player.props.playback_status != Playerctl.PlaybackStatus.STOPPED:
            return player
    return None


def get_status(manager, vanished_player):
    player = find_active_player(manager, vanished_player)
    if player is None:
        return '', '', 'stopped'
    name = player.props.player_name
    metadata = player.props.metadata
    title = metadata[TITLE] if TITLE in metadata.keys() else None
    artist = metadata[ARTIST][0] if ARTIST in metadata.keys() else None
    if name == 'firefox' and title == 'Firefox' and artist == 'Mozilla':
        title = None
        artist = None
    if player.props.playback_status == Playerctl.PlaybackStatus.PAUSED:
        css_class = 'paused'
    else:
        css_class = 'playing'
    if title is None and artist is None:
        if css_class == 'paused':
            icon = ICONS['paused']
        else:
            icon = ICONS['default']
            app_icon = ICONS.get(name, None)
        if app_icon is None:
            label = icon
        else:
            label = f'{icon} {app_icon}'
        return label, f'{name.title()}: {css_class.title()}', css_class
    if css_class == 'paused':
        icon = ICONS['paused']
    else:
        # Added override for icon
        #icon = ICONS.get(name, ICONS['default'])
        icon = ICONS['default']
    if title is None or title == '':
        song = artist or name.title()
    elif artist is None or artist == '':
        song = f'{title}'
    else:
        song = f'{artist} – {title}'
    html_song = html.escape(song)
    return f'{icon} {html_song}', f'{name.title()}: {song}', css_class


def print_status(manager, vanished_player=None):
    text, tooltip, css_class = get_status(manager, vanished_player)
    status = json.dumps({'text': text, 'tooltip': tooltip, 'class': css_class})
    global last_status
    if last_status != status:
        print(status)
        sys.stdout.flush()
        last_status = status


def on_playback_status(player, status, manager):
    manager.move_player_to_top(player)
    print_status(manager)


def on_metadata(player, metadata, manager):
    manager.move_player_to_top(player)
    print_status(manager)


def init_player(manager, name):
    player = Playerctl.Player.new_from_name(name)
    player.connect('playback-status', on_playback_status, manager)
    player.connect('metadata', on_metadata, manager)
    manager.manage_player(player)


def on_name_appeared(manager, name, _):
    init_player(manager, name)
    print_status(manager)


def on_player_vanished(manager, player, _):
    print_status(manager, player)


def init_manager():
    manager = Playerctl.PlayerManager()
    manager.connect('name-appeared', on_name_appeared, manager)
    manager.connect('player-vanished', on_player_vanished, manager)
    for name in manager.props.player_names:
        init_player(manager, name)
    print_status(manager)


if __name__ == '__main__':
    init_manager()
    main = GLib.MainLoop()
    main.run()
