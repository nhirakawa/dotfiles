```
    _______  __   __       _______     _______.
   |   ____||  | |  |     |   ____|   /       |
   |  |__   |  | |  |     |  |__     |   (----`
   |   __|  |  | |  |     |   __|     \   \    
 __|  |     |  | |  `----.|  |____.----)   |   
(__)__|     |__| |_______||_______|_______/    

```

## How it works
Dotfiles will be symlinked to `~` according to `conf/index.json`.

Both zsh and fish are supported and can be used side by side:
- zsh: a managed block in `~/.zshrc` sources `conf/base.zshrc`
- fish: `conf/base.fish` is linked to `~/.config/fish/conf.d/dotfiles.fish`

Machine-specific config goes in `~/.config/dotfiles.zsh` or
`~/.config/dotfiles.fish`.

## Usage
```
usage: Install dotfiles [-h] [-b BACKUP]

optional arguments:
  -h, --help            show this help message and exit
  -b BACKUP, --backup BACKUP
                        Extension of backup files
```
