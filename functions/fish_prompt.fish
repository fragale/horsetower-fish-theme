function fish_prompt
  #
  # HorseTower: improve command color contrast (run once per session)
  #
  if not set -q __horsetower_cmdcolors_done
    set -g __horsetower_cmdcolors_done 1

    # Command = bright cyan (universal, so syntax highlighting uses it)
    set -U fish_color_command brcyan

    # Invalid command / errors = bright red bold
    set -U fish_color_error brred --bold
  end


  #
  # HorseTower: force ls directories to bright cyan (run once per session)
  #
  if not set -q __horsetower_lscolors_done
    set -g __horsetower_lscolors_done 1

    # Ensure fish default LS_COLORS exists
    if not set -q LS_COLORS
      __fish_set_lscolors
    end

    # Append directory color override (last one wins)
    set -gx LS_COLORS "$LS_COLORS:di=01;36"
  end

  # Cache exit status
  set -l last_status $status

  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (uname -n|cut -d . -f 1)
  end
  if not set -q __fish_prompt_char
    switch (id -u)
      case 0
        set -g __fish_prompt_char '#'
      case '*'
        set -g __fish_prompt_char 'λ'
    end
  end

  # Setup colors
  if not set -q __horsetower_hostcolor
    set -g __horsetower_hostcolor (uname -n | md5sum | cut -f1 -d' ' | tr -d '\n' | tail -c6)
  end
  set -l hostcolor (set_color $__horsetower_hostcolor)

  set -l normal (set_color normal)
  set -l white (set_color FFFFFF)
  set -l turquoise (set_color 5fdfff)
  set -l orange (set_color df5f00)
  set -l hotpink (set_color df005f)
  set -l blue (set_color blue)
  set -l limegreen (set_color 87ff00)
  set -l purple (set_color af5fff)

  # Configure __fish_git_prompt
  set -g __fish_git_prompt_char_stateseparator ' '
  set -g __fish_git_prompt_color 5fdfff
  set -g __fish_git_prompt_color_flags df5f00
  set -g __fish_git_prompt_color_prefix white
  set -g __fish_git_prompt_color_suffix white
  set -g __fish_git_prompt_showdirtystate true
  set -g __fish_git_prompt_showuntrackedfiles true
  set -g __fish_git_prompt_showstashstate true
  set -g __fish_git_prompt_show_informative_status true

  set -l current_user (whoami)

  set -q THEME_HORSETOWER_VI_MODE; or set -g THEME_HORSETOWER_VI_MODE yes

  ##
  ## Line 1
  ##
  echo -n $hostcolor'╭─'$hotpink$current_user$white' at '$orange$__fish_prompt_hostname$white' in '$limegreen(pwd|sed "s=$HOME=⌁=")$turquoise
  __fish_git_prompt " (%s)"
  echo

  ##
  ## Line 2
  ##
  echo -n $hostcolor'╰'

  # Disable virtualenv's default prompt
  set -g VIRTUAL_ENV_DISABLE_PROMPT true

  # support for virtual env name
  if set -q VIRTUAL_ENV
    echo -n "($turquoise"(basename "$VIRTUAL_ENV")"$white)"
  end

  ##
  ## Support for vi mode
  ##
  set -l htViMode "$THEME_HORSETOWER_VI_MODE"

  if test "$fish_key_bindings" = fish_vi_key_bindings
      or test "$fish_key_bindings" = fish_hybrid_key_bindings
    if test -z (string match -ri '^no|false|0$' $htViMode)
      set_color --bold
      echo -n $white'─['
      switch $fish_bind_mode
        case default
          set_color red
          echo -n 'n'
        case insert
          set_color green
          echo -n 'i'
        case replace_one
          set_color green
          echo -n 'r'
        case replace
          set_color cyan
          echo -n 'r'
        case visual
          set_color magenta
          echo -n 'v'
      end
      echo -n $white']'
    end
  end

  ##
  ## Rest of the prompt
  ##
  echo -n $hostcolor'─'$white$__fish_prompt_char $normal
end
