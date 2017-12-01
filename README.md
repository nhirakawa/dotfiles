```
    _______  __   __       _______     _______.
   |   ____||  | |  |     |   ____|   /       |
   |  |__   |  | |  |     |  |__     |   (----`
   |   __|  |  | |  |     |   __|     \   \    
 __|  |     |  | |  `----.|  |____.----)   |   
(__)__|     |__| |_______||_______|_______/    

```

## How it works
Everything in the `conf` folder with a `.symlink` extension will be symlinked to `~`. If the original filename is `conf/file.symlink`, it will be written to `~/.file`. The directory structure in `conf` is also maintained - `conf/files/file.symlink` will be written to `~/.files/.file`.
