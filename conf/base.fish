# fish counterpart of base.zshrc. bootstrap.py links this into
# ~/.config/fish/conf.d/, so fish loads it before ~/.config/fish/config.fish.

# Homebrew is added to PATH by ~/.zprofile under zsh, which fish doesn't read
if not command -q brew; and test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

# fish_add_path skips entries already in PATH. Prepends use --move so they win
# over existing entries; system dirs are only appended if missing so package
# managers (e.g. Homebrew) take precedence
fish_add_path --path --append /usr/local/bin /usr/bin /bin /usr/sbin /sbin /usr/local/sbin
fish_add_path --path --move ~/.local/bin

if command -q go
    set -gx GOPATH ~/src/golang
    fish_add_path --path --move $GOPATH/bin
end

if test -d ~/.cargo/bin
    fish_add_path --path --move ~/.cargo/bin
end

# Keep only the first occurrence of each entry, like `typeset -U path` (fish
# inherits duplicates when launched from another shell)
set -l unique_path
for dir in $PATH
    contains -- $dir $unique_path; or set -a unique_path $dir
end
set -gx PATH $unique_path
set -e unique_path

status is-interactive; or return

# ssh-agent
# Port of the oh-my-zsh ssh-agent plugin. It uses the same cache file, so zsh
# and fish share one agent.
function _dotfiles_ssh_agent_running
    test -S "$SSH_AUTH_SOCK"; or return 1
    # ssh-add exits 2 when it can't reach the agent
    ssh-add -l >/dev/null 2>&1
    test $status -ne 2
end

function _dotfiles_ssh_agent_load --argument-names cache
    # The cache uses sh syntax: `SSH_AUTH_SOCK=/path; export SSH_AUTH_SOCK;`
    for line in (string match -r '^SSH_\w+=[^;]*' <$cache)
        set -l kv (string split -m1 = -- $line)
        set -gx $kv[1] $kv[2]
    end
end

function _dotfiles_ssh_agent_start
    # Same name as oh-my-zsh's $SHORT_HOST
    set -l host
    command -q scutil; and set host (scutil --get LocalHostName 2>/dev/null)
    test -n "$host"; or set host (prompt_hostname)
    set -l cache ~/.ssh/environment-$host

    if test -f $cache
        _dotfiles_ssh_agent_load $cache
        _dotfiles_ssh_agent_running; and return
    end

    if not test -d ~/.ssh
        echo >&2 "ssh-agent requires ~/.ssh directory"
        return 1
    end

    echo >&2 "Starting ssh-agent ..."
    ssh-agent -s | sed '/^echo/d' >$cache
    chmod 600 $cache
    _dotfiles_ssh_agent_load $cache
end

function _dotfiles_ssh_add_identities
    test -d ~/.ssh; or return

    set -l loaded (ssh-add -l 2>/dev/null)
    set -l not_loaded
    # Default keys from the `ssh-add` man page
    for id in id_rsa id_dsa id_ecdsa id_ed25519 id_ed25519_sk identity
        set -l file ~/.ssh/$id
        test -f $file; or continue
        # Match on filename, then on fingerprint
        string match -q -- "* $file *" $loaded; and continue
        set -l sig (ssh-keygen -lf $file | string split -f2 ' ')
        string match -q -- "* $sig *" $loaded; and continue
        set -a not_loaded $file
    end

    test (count $not_loaded) -gt 0; and ssh-add $not_loaded
end

_dotfiles_ssh_agent_start; and _dotfiles_ssh_add_identities

# nvm
# nvm.sh is bash-only, so it runs in bash and the environment it sets is copied
# back into fish. This shares ~/.nvm (and its installed versions) with zsh.
set -q NVM_DIR; or set -gx NVM_DIR ~/.nvm

if test -f $NVM_DIR/nvm.sh
    # Runs `script` in bash with nvm loaded; extra args become $1, $2, ...
    function _dotfiles_nvm_bash --argument-names script
        set -l env_file (mktemp)
        bash -c '
            env_file=$1 script=$2
            shift 2
            source "$NVM_DIR/nvm.sh" --no-use || exit
            eval "$script"
            s=$?
            printf "PATH=%s\nNVM_BIN=%s\nNVM_INC=%s\n" "$PATH" "${NVM_BIN-}" "${NVM_INC-}" >"$env_file"
            exit $s' bash $env_file $script $argv[2..]
        set -l s $status

        for line in (cat $env_file)
            set -l kv (string split -m1 = -- $line)
            if test -z "$kv[2]"
                set -e $kv[1]
            else if test $kv[1] = PATH
                set -gx PATH (string split : -- $kv[2])
            else
                set -gx $kv[1] $kv[2]
            end
        end
        rm -f $env_file
        return $s
    end

    function nvm --description 'Node Version Manager (runs nvm.sh in bash)'
        _dotfiles_nvm_load
        _dotfiles_nvm_bash 'nvm "$@"' $argv
    end

    # Port of the oh-my-zsh nvm plugin's .nvmrc autoload. Only shells out to
    # bash when entering or leaving a directory tree with an .nvmrc.
    function _dotfiles_nvm_autoload --on-variable PWD
        set -q _dotfiles_nvm_loaded; or return

        set -l nvmrc
        set -l dir $PWD
        while true
            if test -f $dir/.nvmrc
                set nvmrc $dir/.nvmrc
                break
            end
            test $dir = /; and break
            set dir (path dirname $dir)
        end

        test "$nvmrc" = "$_dotfiles_nvmrc"; and return

        if test -n "$nvmrc"
            _dotfiles_nvm_bash '
                v=$(nvm version "$(tr -dc "[:print:]" <"$1")")
                if [ "$v" = N/A ]; then
                    nvm install
                elif [ "$v" != "$(nvm version)" ]; then
                    nvm use --silent
                fi' $nvmrc
        else
            _dotfiles_nvm_bash '[ "$(nvm version)" = "$(nvm version default)" ] || nvm use --silent default'
        end
        set -g _dotfiles_nvmrc $nvmrc
    end

    # Lazy loading, like `zstyle ':omz:plugins:nvm' lazy yes`: nvm is only
    # loaded on first use of one of these commands
    set -g _dotfiles_nvm_lazy_cmds node npm npx pnpm pnpx yarn corepack

    function _dotfiles_nvm_load
        set -q _dotfiles_nvm_loaded; and return
        set -g _dotfiles_nvm_loaded 1
        functions -e $_dotfiles_nvm_lazy_cmds
        # nvm.sh does this itself when sourced without --no-use
        _dotfiles_nvm_bash 'nvm use --silent default >/dev/null 2>&1; true'
        _dotfiles_nvm_autoload
    end

    for cmd in $_dotfiles_nvm_lazy_cmds
        function $cmd --inherit-variable cmd
            _dotfiles_nvm_load
            command $cmd $argv
        end
    end
end

# Aliases are abbreviations in fish: they expand in place as you type

# Directory navigation (oh-my-zsh defaults; fish already provides `ll` and `la`)
abbr --add l ls -lah
abbr --add -- - cd -

function _dotfiles_multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function _dotfiles_multicd

# git (the oh-my-zsh git plugin aliases in regular use, per atuin history)
function _dotfiles_gpsup
    echo git push --set-upstream origin (git branch --show-current)
end

abbr --add gb git branch
abbr --add gc git commit --verbose
abbr --add gcb git checkout -b
abbr --add gcmsg git commit --message
abbr --add gcn git commit --verbose --no-edit
abbr --add gcn! git commit --verbose --no-edit --amend
abbr --add gpf git push --force-with-lease
abbr --add gpsup --function _dotfiles_gpsup
abbr --add grba git rebase --abort
abbr --add grbi git rebase --interactive

# mvn
abbr --add mvnpack mvn clean package
abbr --add mvnda mvn clean dependency:analyze-only
abbr --add mvncc mvn clean compile
abbr --add mvncv mvn clean verify
abbr --add mvnsort mvn sortpom:sort -Dsort.sortDependencies=scope,groupId,artifactId

# tmux (oh-my-zsh tmux plugin aliases)
if command -q tmux
    abbr --add ta tmux attach -t
    abbr --add tad tmux attach -d -t
    abbr --add ts tmux new-session -s
    abbr --add tl tmux list-sessions
    abbr --add tksv tmux kill-server
    abbr --add tkss tmux kill-session -t
end

# Timestamp functions
function date_str
    date +%Y%m%d
end

function time_str
    date +%H%M%S
end

function datetime_str
    date +%Y%m%d-%H%M%S
end

if command -q direnv
    direnv hook fish | source
end

if command -q atuin
    atuin init fish | source
end

if command -q starship
    starship init fish | source
end

if test -e ~/.config/dotfiles.fish
    source ~/.config/dotfiles.fish
end
