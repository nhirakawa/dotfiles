#!/usr/bin/env python

import argparse
import json
import os
import os.path as path
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

    print 'installing dotfiles to', USER_DIR

    index = read_index()

    if 'dotfiles' not in index:
        sys.exit('could not find field `dotfiles` in index.json')

    dotfiles = index['dotfiles']

    now = int(time.time())

    for dotfile in dotfiles:
        if 'source' not in dotfile:
            print 'field `source` not found in {} - skipping'.format(dotfile)
            continue

        if "target" not in dotfile:
            print 'field `target` not found in {} - skipping'.format(dotfile)
            continue

        source = path.join(CONF_DIR, dotfile['source'])
        target = path.join(USER_DIR, dotfile['target'])

        print
        print 'installing {}'.format(source)

        directory_name = path.dirname(target)
        if not path.exists(directory_name):
            print '  creating directory {}'.format(directory_name)
            os.makedirs(directory_name)

        if path.lexists(target):
            backup_name = '{}.{}.{}'.format(target, now, backup_extension)
            print '  backing up {} to {}'.format(target, backup_name)
            os.rename(target, backup_name)

        print '  linking {} to {}'.format(source, target)
        os.symlink(source, target)


def read_index():
    with open(JSON_DIR) as j:
        return json.load(j)


def get_args():
    parser = argparse.ArgumentParser('Install dotfiles')
    parser.add_argument('-b', '--backup', type=str, default='bak')
    return parser.parse_args()


if __name__ == '__main__':
    main()
