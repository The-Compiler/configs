#!/usr/bin/python

import herbstclient
import subprocess
import os
import os.path

hc = herbstclient.Client()

def bind(key, *args, ctrl=False, shift=False, alt=False, mouse=False):
    keys = []
    if ctrl:
        keys.append('Control')
    if shift:
        keys.append('Shift')
    if alt:
        keys.append('Mod1')
    keys.append(key)
    if mouse:
        return hc.mousebind('-'.join(keys), *args)
    else:
        return hc.keybind('-'.join(keys), *args)

def chain(*cmds, sep='|'):
    out = ['chain', sep]
    for cmd in cmds:
        out += cmd
        out.append(sep)
    return out

def homebin(path):
    return os.path.join(os.environ['HOME'], 'bin', path)

def call(cmd):
    return subprocess.Popen(cmd, shell=True)

call('feh --no-fehbg --bg-center ~/.config/herbstluftwm/wallpaper.png')

# colors
hc.set('frame_border_active_color', '#afdf5f')
hc.set('frame_border_normal_color', '#afdf87')
hc.set('frame_bg_normal_color', '#00aaee')
hc.set('frame_bg_active_color', '#00aaee')
hc.set('frame_bg_transparent', True)
hc.set('window_border_normal_color', '#afafdf')
hc.set('window_border_active_color', '#df8787')

# Look
hc.set('always_show_frame', False)
hc.set('gapless_grid', True)
hc.set('default_frame_layout', 3)
hc.set('focus_follows_mouse', True)
hc.set('raise_on_focus', False)
hc.set('raise_on_click', True)
hc.set('smart_frame_surroundings', True)
hc.set('smart_window_surroundings', True)
hc.set('tree_style', '╾│ ├╰╼─╮')
hc.set('swap_monitors_to_get_tag', False)
hc.set('frame_transparent_width', False)

# Rules
hc.unrule('-F')
hc.rule('focus=on') # normally focus new clients
# Don't manage docks and notifications
hc.rule('windowtype~_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK)', 'manage=off')
hc.rule('class=Cellwriter', 'manage=off') # Don't manage cellwriter
hc.rule('class=Onboard', 'manage=off')
# Pseudotile dialogs and splashes
hc.rule('windowtype~_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)',
        'pseudotile=on')
# Don't pseudotile file chooser dialogs
hc.rule('windowrole=GtkFileChooserDialog' 'pseudotile=off')

# Settings which draw to the screen finished
hc.unlock()

# Tags

tags = [] # list of (name: key) tuples
for i in range(1, 10):
    tags.append((i, str(i)))

try:
    hc.rename('default', tags[0][0])
except herbstclient.HerbstError:
    pass

for (tag, key) in tags:
    hc.add(tag)
    bind(key, 'use', tag)
    bind(key, 'move', tag, shift=True)

call('~/scripts/autorun.sh')

# keybindings

bind('q', 'quit', shift=True)
bind('r', 'reload', shift=True)
bind('c', 'close', shift=True)
bind('Return', 'spawn', 'urxvtcd')
bind('d', 'spawn', 'bash -c \'DMENU_OPTIONS="-nf #d0d0d0 -nb #4e4e4e -sf '
                   '#b2b2b2 -sb #3a3a3a" dmenu-launch\'')

# layouting

bind('r', 'remove')
bind('space', 'cycle_layout', 1)
bind('u', 'split', 'vertical', 0.5)
bind('s', 'floating', 'toggle')
bind('f', 'fullscreen', 'toggle')
bind('p', 'pseudotile', 'toggle')

# resizing
resizestep = 0.05
bind('h', 'resize', 'left', '+{}'.format(resizestep), ctrl=True)
bind('j', 'resize', 'down', '+{}'.format(resizestep), ctrl=True)
bind('k', 'resize', 'up', '+{}'.format(resizestep), ctrl=True)
bind('l', 'resize', 'right', '+{}'.format(resizestep), ctrl=True)

# mouse
bind('Button1', 'move', mouse=True)
bind('Button2', 'resize', mouse=True)
bind('Button3', 'zoom', mouse=True)

# focus
bind('t', 'raise')
bind('BackSpace', 'cycle_monitor')
bind('Tab', 'cycle_all', '+1')
bind('Tab', 'cycle_all', '-1', shift=True)
bind('c', 'cycle')
bind('h', 'focus', 'left')
bind('j', 'focus', 'down')
bind('k', 'focus', 'up')
bind('l', 'focus', 'right')
bind('h', 'focus', 'shift', 'left', shift=True)
bind('j', 'focus', 'shift', 'down', shift=True)
bind('k', 'focus', 'shift', 'up', shift=True)
bind('l', 'focus', 'shift', 'right', shift=True)

# Utils
bind('y', 'spawn', homebin('utf8select.sh'))
bind('t', 'spawn', homebin('xojtex'))

# Volume keys
hc.keybind('XF86AudioLowerVolume', 'spawn', homebin('volume/vol.sh'),
           'decrease')
hc.keybind('XF86AudioRaiseVolume', 'spawn', homebin('volume/vol.sh'),
           'increase')
hc.keybind('XF86AudioMute', 'spawn', homebin('volume/vol.sh'), 'mute')

# Rotate key
hc.keybind('XF86RotateWindows', 'spawn', homebin('xrotate'), 'toggle')

# Thinkpad back/forward keys
hc.keybind('Shift-XF86Back', 'spawn', homebin('tagswitch'), 'prev')
hc.keybind('Shift-XF86Forward', 'spawn', homebin('tagswitch'), 'next')
hc.keybind('XF86Back', 'use_index', '-1')
hc.keybind('XF86Forward', 'use_index', '+1')

# Fn + F4
hc.keybind('XF86ScreenSaver', *chain(
    ['spawn', 'xset', 'dpms', 'force', 'off'],
    ['spawn', 'xscreensaver-command', '-lock']))
# ThinkVantage-Key
hc.keybind('XF86Launch1', 'spawn', 'urxvtcd')
hc.keybind('XF86Launch2', 'spawn', homebin('onboardctl'), 'toggle')

# Fix java
hc.setenv('_JAVA_AWT_WM_NONREPARENTING', 1)

# Fix xdg-open
hc.setenv('DE', 'gnome')
hc.setenv('BROWSER', 'dwb')

# No beeps
call('xset -b')
