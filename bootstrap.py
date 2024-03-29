#!/usr/bin/env python

from __future__ import print_function

import argparse
import json
import os
import os.path as path
import subprocess
import sys
import time


CONF_DIR = path.abspath('conf')
USER_DIR = path.expanduser('~')
JSON_DIR = 'conf/index.json'


def main():
    args = get_args()

    backup_extension = args.backup
    if backup_extension.startswith('.'):
        backup_extension = backup_extension.split('.')[1]

    print('installing dotfiles to', USER_DIR)

    index = read_index()

    if 'dotfiles' not in index:
        sys.exit('could not find field `dotfiles` in index.json')

    dotfiles = index['dotfiles']

    now = int(time.time())

    for dotfile in dotfiles:
        if 'source' not in dotfile:
            print('field `source` not found in {} - skipping'.format(dotfile))
            continue

        if "target" not in dotfile:
            print('field `target` not found in {} - skipping'.format(dotfile))
            continue

        source = path.join(CONF_DIR, dotfile['source'])
        target = path.join(USER_DIR, dotfile['target'])

        print()
        print('installing {}'.format(source))

        directory_name = path.dirname(target)
        if not path.exists(directory_name):
            print('  creating directory {}'.format(directory_name))
            os.makedirs(directory_name)

        if path.lexists(target):
            backup_name = '{}.{}.{}'.format(target, now, backup_extension)
            print('  backing up {} to {}'.format(target, backup_name))
            os.rename(target, backup_name)

        print('  linking {} to {}'.format(source, target))
        os.symlink(source, target)

    link_zshrc()
    link_nickhirakawa_theme()

    if args.install_vim_plugins:
        plugin_install_result = subprocess.run(["vim", "+PluginInstall", "+qall"])
        if plugin_install_result.returncode != 0:
            print('Error when installing vim plugins - code {}', plugin_install_result.returncode)


def link_zshrc():
    source = path.join(CONF_DIR, 'base.zshrc')
    target = path.join(USER_DIR, '.zshrc')

    print()

    with open(target, mode='a+') as zshrc:
        zshrc.seek(0)
        whole_file = zshrc.read()

        source_statement = 'source {}'.format(source)
        if source_statement in whole_file:
            print('{} already contains source'.format(target))
            return

        print('adding source statement to {}'.format(target))
        zshrc.write('{}\n'.format(source_statement))


def read_index():
    with open(JSON_DIR) as j:
        return json.load(j)


def link_nickhirakawa_theme():
    source = path.join(CONF_DIR, 'nickhirakawa.zsh-theme')
    target = path.join(USER_DIR, '.oh-my-zsh', 'themes', 'nickhirakawa.zsh-theme')

    print()

    if path.lexists(target):
        print('theme symlink already exists - skipping')
        return

    print('installing {}'.format(source))
    print('  linking {} to {}'.format(source, target))

    os.symlink(source, target)


def get_args():
    parser = argparse.ArgumentParser('Install dotfiles')
    parser.add_argument('-b', '--backup', type=str,
                        default='bak', help='Extension of backup files')
    parser.add_argument('--install-vim-plugins', dest='install_vim_plugins', action='store_true', help='If true, installs Vundle plugins')
    return parser.parse_args()


if __name__ == '__main__':
    main()
