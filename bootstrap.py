#!/usr/bin/env python

from __future__ import print_function

import argparse
import glob
import json
import os
import os.path as path
import shutil
import subprocess
import sys
import time


REPO_DIR = path.dirname(path.abspath(__file__))
CONF_DIR = path.join(REPO_DIR, 'conf')
USER_DIR = path.expanduser('~')
JSON_DIR = path.join(CONF_DIR, 'index.json')
MAX_BACKUPS = 5
ZSHRC_BLOCK_BEGIN = '# >>> dotfiles (managed by bootstrap.py) >>>'
ZSHRC_BLOCK_END = '# <<< dotfiles <<<'


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
        link(source, target, args.preserve_files, backup_extension, now)

    link_zshrc()

    if args.install_vim_plugins:
        plugin_install_result = subprocess.run(["vim", "+PluginInstall", "+qall"])
        if plugin_install_result.returncode != 0:
            print('Error when installing vim plugins - code {}', plugin_install_result.returncode)


def link(source, target, preserve_files, backup_extension, now):
    print()
    print('installing {}'.format(source))

    directory_name = path.dirname(target)
    if not path.exists(directory_name):
        print('  creating directory {}'.format(directory_name))
        os.makedirs(directory_name)

    if path.islink(target) and os.readlink(target) == source:
        print('  {} already linked to {} - skipping'.format(target, source))
        return

    if path.lexists(target):
        if preserve_files:
            backup_name = '{}.{}.{}'.format(target, now, backup_extension)
            print('  backing up {} to {}'.format(target, backup_name))
            os.rename(target, backup_name)
            prune_backups(target, backup_extension)
        else:
            print('  removing {}'.format(target))
            remove(target)

    print('  linking {} to {}'.format(source, target))
    os.symlink(source, target)


def prune_backups(target, backup_extension):
    pattern = '{}.*.{}'.format(target, backup_extension)
    backups = sorted(glob.glob(pattern), reverse=True)
    for old_backup in backups[MAX_BACKUPS:]:
        print('  removing old backup {}'.format(old_backup))
        remove(old_backup)


def remove(target):
    if path.isdir(target) and not path.islink(target):
        shutil.rmtree(target)
    else:
        os.remove(target)


def link_zshrc():
    source = path.join(CONF_DIR, 'base.zshrc')
    target = path.join(USER_DIR, '.zshrc')

    print()

    block = '{}\n[[ -r {source} ]] && source {source}\n{}\n'.format(
        ZSHRC_BLOCK_BEGIN, ZSHRC_BLOCK_END, source=source)

    content = ''
    if path.exists(target):
        with open(target) as zshrc:
            content = zshrc.read()

    start = content.find(ZSHRC_BLOCK_BEGIN)
    end = content.find(ZSHRC_BLOCK_END, start)
    if start != -1 and end != -1:
        before = content[:start]
        after = content[end + len(ZSHRC_BLOCK_END):]
    else:
        before = content
        after = ''

    # Surround the block with exactly one blank line on each side
    before = before.rstrip('\n')
    after = after.lstrip('\n')
    new_content = block
    if before:
        new_content = before + '\n\n' + new_content
    if after:
        new_content = new_content + '\n' + after

    if new_content == content:
        print('{} managed block already up to date'.format(target))
        return

    print('writing managed block to {}'.format(target))
    with open(target, mode='w') as zshrc:
        zshrc.write(new_content)


def read_index():
    with open(JSON_DIR) as j:
        return json.load(j)


def get_args():
    parser = argparse.ArgumentParser('Install dotfiles')
    parser.add_argument('-b', '--backup', type=str,
                        default='bak', help='Extension of backup files')
    parser.add_argument('--preserve-files', dest='preserve_files', action='store_true',
                        help='If true, backs up existing files instead of overwriting them')
    parser.add_argument('--install-vim-plugins', dest='install_vim_plugins', action='store_true', help='If true, installs Vundle plugins')
    return parser.parse_args()


if __name__ == '__main__':
    main()
