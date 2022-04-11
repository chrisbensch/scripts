if [[ $__p9k_sourced != 13 ]]; then
  >&2 print -P ""
  >&2 print -P "[%F{1}ERROR%f]: Corrupted powerlevel10k installation."
  >&2 print -P ""
  if (( ${+functions[antigen]} )); then
    >&2 print -P "If using %Bantigen%b, run the following command to fix:"
    >&2 print -P ""
    >&2 print -P "    %F{2}antigen%f reset"
    if [[ -d ~/.antigen ]]; then
      >&2 print -P ""
      >&2 print -P "If it doesn't help, try this:"
      >&2 print -P ""
      >&2 print -P "    %F{2}rm%f -rf %U~/.antigen%u"
    fi
  else
    >&2 print -P "Try resetting cache in your plugin manager or"
    >&2 print -P "reinstalling powerlevel10k from scratch."
  fi
  >&2 print -P ""
  return 1
fi

if ! autoload -Uz is-at-least || ! is-at-least 5.1; then
  () {
    >&2 echo -E "You are using ZSH version $ZSH_VERSION. The minimum required version for Powerlevel10k is 5.1."
    >&2 echo -E "Type 'echo \$ZSH_VERSION' to see your current zsh version."
    local def=${SHELL:c:A}
    local cur=${${ZSH_ARGZERO#-}:c:A}
    local cur_v="$($cur -c 'echo -E $ZSH_VERSION' 2>/dev/null)"
    if [[ $cur_v == $ZSH_VERSION && $cur != $def ]]; then
      >&2 echo -E "The shell you are currently running is likely $cur."
    fi
    local other=${${:-zsh}:c}
    if [[ -n $other ]] && $other -c 'autoload -Uz is-at-least && is-at-least 5.1' &>/dev/null; then
      local other_v="$($other -c 'echo -E $ZSH_VERSION' 2>/dev/null)"
      if [[ -n $other_v && $other_v != $ZSH_VERSION ]]; then
        >&2 echo -E "You have $other with version $other_v but this is not what you are using."
        if [[ -n $def && $def != ${other:A} ]]; then
          >&2 echo -E "To change your user shell, type the following command:"
          >&2 echo -E ""
          if [[ "$(grep -F $other /etc/shells 2>/dev/null)" != $other ]]; then
            >&2 echo -E "  echo ${(q-)other} | sudo tee -a /etc/shells"
          fi
          >&2 echo -E "  chsh -s ${(q-)other}"
        fi
      fi
    fi
  }
  return 1
fi

builtin source "${__p9k_root_dir}/internal/configure.zsh"
builtin source "${__p9k_root_dir}/internal/worker.zsh"
builtin source "${__p9k_root_dir}/internal/parser.zsh"
builtin source "${__p9k_root_dir}/internal/icons.zsh"

# For compatibility with Powerlevel9k. It's not recommended to use mnemonic color
# names in the configuration except for colors 0-7 as these are standard.
typeset -grA __p9k_colors=(
            black 000               red 001             green 002            yellow 003
             blue 004           magenta 005              cyan 006             white 007
             grey 008            maroon 009              lime 010             olive 011
             navy 012           fuchsia 013              aqua 014              teal 014
           silver 015             grey0 016          navyblue 017          darkblue 018
            blue3 020             blue1 021         darkgreen 022      deepskyblue4 025
      dodgerblue3 026       dodgerblue2 027            green4 028      springgreen4 029
       turquoise4 030      deepskyblue3 032       dodgerblue1 033          darkcyan 036
    lightseagreen 037      deepskyblue2 038      deepskyblue1 039            green3 040
     springgreen3 041             cyan3 043     darkturquoise 044        turquoise2 045
           green1 046      springgreen2 047      springgreen1 048 mediumspringgreen 049
            cyan2 050             cyan1 051           purple4 055           purple3 056
       blueviolet 057            grey37 059     mediumpurple4 060        slateblue3 062
       royalblue1 063       chartreuse4 064    paleturquoise4 066         steelblue 067
       steelblue3 068    cornflowerblue 069     darkseagreen4 071         cadetblue 073
         skyblue3 074       chartreuse3 076         seagreen3 078       aquamarine3 079
  mediumturquoise 080        steelblue1 081         seagreen2 083         seagreen1 085
   darkslategray2 087           darkred 088       darkmagenta 091           orange4 094
       lightpink4 095             plum4 096     mediumpurple3 098        slateblue1 099
           wheat4 101            grey53 102    lightslategrey 103      mediumpurple 104
   lightslateblue 105           yellow4 106      darkseagreen 108     lightskyblue3 110
         skyblue2 111       chartreuse2 112        palegreen3 114    darkslategray3 116
         skyblue1 117       chartreuse1 118        lightgreen 120       aquamarine1 122
   darkslategray1 123         deeppink4 125   mediumvioletred 126        darkviolet 128
           purple 129     mediumorchid3 133      mediumorchid 134     darkgoldenrod 136
        rosybrown 138            grey63 139     mediumpurple2 140     mediumpurple1 141
        darkkhaki 143      navajowhite3 144            grey69 145   lightsteelblue3 146
   lightsteelblue 147   darkolivegreen3 149     darkseagreen3 150        lightcyan3 152
    lightskyblue1 153       greenyellow 154   darkolivegreen2 155        palegreen1 156
    darkseagreen2 157    paleturquoise1 159              red3 160         deeppink3 162
         magenta3 164       darkorange3 166         indianred 167          hotpink3 168
         hotpink2 169            orchid 170           orange3 172      lightsalmon3 173
       lightpink3 174             pink3 175             plum3 176            violet 177
            gold3 178   lightgoldenrod3 179               tan 180        mistyrose3 181
         thistle3 182             plum2 183           yellow3 184            khaki3 185
     lightyellow3 187            grey84 188   lightsteelblue1 189           yellow2 190
  darkolivegreen1 192     darkseagreen1 193         honeydew2 194        lightcyan1 195
             red1 196         deeppink2 197         deeppink1 199          magenta2 200
         magenta1 201        orangered1 202        indianred1 204           hotpink 206
    mediumorchid1 207        darkorange 208           salmon1 209        lightcoral 210
   palevioletred1 211           orchid2 212           orchid1 213           orange1 214
       sandybrown 215      lightsalmon1 216        lightpink1 217             pink1 218
            plum1 219             gold1 220   lightgoldenrod2 222      navajowhite1 223
       mistyrose1 224          thistle1 225           yellow1 226   lightgoldenrod1 227
           khaki1 228            wheat1 229         cornsilk1 230           grey100 231
            grey3 232             grey7 233            grey11 234            grey15 235
           grey19 236            grey23 237            grey27 238            grey30 239
           grey35 240            grey39 241            grey42 242            grey46 243
           grey50 244            grey54 245            grey58 246            grey62 247
           grey66 248            grey70 249            grey74 250            grey78 251
           grey82 252            grey85 253            grey89 254            grey93 255)

# For compatibility with Powerlevel9k.
#
# Type `getColorCode background` or `getColorCode foreground` to see the list of predefined colors.
function getColorCode() {
  eval "$__p9k_intro"
  if (( ARGC == 1 )); then
    case $1 in
      foreground)
        local k
        for k in "${(k@)__p9k_colors}"; do
          local v=${__p9k_colors[$k]}
          print -rP -- "%F{$v}$v - $k%f"
        done
        return 0
        ;;
      background)
        local k
        for k in "${(k@)__p9k_colors}"; do
          local v=${__p9k_colors[$k]}
          print -rP -- "%K{$v}$v - $k%k"
        done
        return 0
        ;;
    esac
  fi
  echo "Usage: getColorCode background|foreground" >&2
  return 1
}

# _p9k_declare <type> <uppercase-name> [default]...
function _p9k_declare() {
  local -i set=$+parameters[$2]
  (( ARGC > 2 || set )) || return 0
  case $1 in
    -b)
      if (( set )); then
        [[ ${(P)2} == true ]] && typeset -gi _$2=1 || typeset -gi _$2=0
      else
        typeset -gi _$2=$3
      fi
      ;;
    -a)
      local -a v=("${(@P)2}")
      if (( set )); then
        eval "typeset -ga _${(q)2}=(${(@qq)v})";
      else
        if [[ $3 != '--' ]]; then
          echo "internal error in _p9k_declare " "${(qqq)@}" >&2
        fi
        eval "typeset -ga _${(q)2}=(${(@qq)*[4,-1]})"
      fi
      ;;
    -i)
      (( set )) && typeset -gi _$2=$2 || typeset -gi _$2=$3
      ;;
    -F)
      (( set )) && typeset -gF _$2=$2 || typeset -gF _$2=$3
      ;;
    -s)
      (( set )) && typeset -g _$2=${(P)2} || typeset -g _$2=$3
      ;;
    -e)
      if (( set )); then
        local v=${(P)2}
        typeset -g _$2=${(g::)v}
      else
        typeset -g _$2=${(g::)3}
      fi
      ;;
    *)
      echo "internal error in _p9k_declare " "${(qqq)@}" >&2
  esac
}

function _p9k_read_word() {
  local -a stat
  zstat -A stat +mtime -- $1 2>/dev/null || stat=(-1)
  local cached=$_p9k__read_word_cache[$1]
  if [[ $cached == $stat[1]:* ]]; then
    _p9k__ret=${cached#*:}
  else
    local rest
    _p9k__ret=
    { read _p9k__ret rest <$1 } 2>/dev/null
    _p9k__ret=${_p9k__ret%$'\r'}
    _p9k__read_word_cache[$1]=$stat[1]:$_p9k__ret
  fi
  [[ -n $_p9k__ret ]]
}

function _p9k_fetch_cwd() {
  if [[ $PWD == /* && $PWD -ef . ]]; then
    _p9k__cwd=$PWD
  else
    _p9k__cwd=${${${:-.}:a}:-.}
  fi
  _p9k__cwd_a=${${_p9k__cwd:A}:-.}

  case $_p9k__cwd in
    /|.)
      _p9k__parent_dirs=()
      _p9k__parent_mtimes=()
      _p9k__parent_mtimes_i=()
      _p9k__parent_mtimes_s=
      return
    ;;
    ~|~/*)
      local parent=${${${:-~/..}:a}%/}/
      local parts=(${(s./.)_p9k__cwd#$parent})
    ;;
    *)
      local parent=/
      local parts=(${(s./.)_p9k__cwd})
    ;;
  esac
  local MATCH
  _p9k__parent_dirs=(${(@)${:-{$#parts..1}}/(#m)*/$parent${(pj./.)parts[1,MATCH]}})
  if ! zstat -A _p9k__parent_mtimes +mtime -- $_p9k__parent_dirs 2>/dev/null; then
    _p9k__parent_mtimes=(${(@)parts/*/-1})
  fi
  _p9k__parent_mtimes_i=(${(@)${:-{1..$#parts}}/(#m)*/$MATCH:$_p9k__parent_mtimes[MATCH]})
  _p9k__parent_mtimes_s="$_p9k__parent_mtimes_i"
}

# Usage: _p9k_glob parent_dir_index pattern
#
# parent_dir_index indexes _p9k__parent_dirs.
#
# Returns the number of matches.
#
# Pattern cannot have slashes.
#
# Example: _p9k_glob 3 '*.csproj'
function _p9k_glob() {
  local dir=$_p9k__parent_dirs[$1]
  local cached=$_p9k__glob_cache[$dir/$2]
  if [[ $cached == $_p9k__parent_mtimes[$1]:* ]]; then
    return ${cached##*:}
  fi
  local -a stat
  zstat -A stat +mtime -- $dir 2>/dev/null || stat=(-1)
  local files=($dir/$~2(N:t))
  _p9k__glob_cache[$dir/$2]="$stat[1]:$#files"
  return $#files
}

# Usage: _p9k_upglob pattern
#
# Returns index within _p9k__parent_dirs or 0 if there is no match.
#
# Search stops before reaching ~/../ or / and never matches in those directories.
#
# Example: _p9k_upglob '*.csproj'
function _p9k_upglob() {
  local cached=$_p9k__upsearch_cache[$_p9k__cwd/$1]
  if [[ -n $cached ]]; then
    if [[ $_p9k__parent_mtimes_s == ${cached% *}(| *) ]]; then
      return ${cached##* }
    fi
    cached=(${(s: :)cached})
    local last_idx=$cached[-1]
    cached[-1]=()
    local -i i
    for i in ${(@)${cached:|_p9k__parent_mtimes_i}%:*}; do
      _p9k_glob $i $1 && continue
      _p9k__upsearch_cache[$_p9k__cwd/$1]="${_p9k__parent_mtimes_i[1,i]} $i"
      return i
    done
    if (( i != last_idx )); then
      _p9k__upsearch_cache[$_p9k__cwd/$1]="${_p9k__parent_mtimes_i[1,$#cached]} $last_idx"
      return last_idx
    fi
    i=$(($#cached + 1))
  else
    local -i i=1
  fi
  for ((; i <= $#_p9k__parent_mtimes; ++i)); do
    _p9k_glob $i $1 && continue
    _p9k__upsearch_cache[$_p9k__cwd/$1]="${_p9k__parent_mtimes_i[1,i]} $i"
    return i
  done
  _p9k__upsearch_cache[$_p9k__cwd/$1]="$_p9k__parent_mtimes_s 0"
  return 0
}

# If we execute `print -P $1`, how many characters will be printed on the last line?
# Assumes that `%{%}` and `%G` don't lie.
#
#   _p9k_prompt_length '' => 0
#   _p9k_prompt_length 'abc' => 3
#   _p9k_prompt_length $'abc\nxy' => 2
#   _p9k_prompt_length $'\t' => 8
#   _p9k_prompt_length '%F{red}abc' => 3
#   _p9k_prompt_length $'%{a\b%Gb%}' => 1
function _p9k_prompt_length() {
  local -i COLUMNS=1024
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  typeset -g _p9k__ret=$x
}

typeset -gr __p9k_byte_suffix=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')

# 512 => 512B
# 1800 => 1.76K
# 18000 => 17.6K
function _p9k_human_readable_bytes() {
  typeset -F n=$1
  local suf
  for suf in $__p9k_byte_suffix; do
    (( n < 1024 )) && break
    (( n /= 1024 ))
  done
  if (( n >= 100 )); then
    printf -v _p9k__ret '%.0f.' $n
  elif (( n >= 10 )); then
    printf -v _p9k__ret '%.1f' $n
  else
    printf -v _p9k__ret '%.2f' $n
  fi
  _p9k__ret=${${_p9k__ret%%0#}%.}$suf
}

if is-at-least 5.4; then
  function _p9k_print_params() { typeset -p -- "$@" }
else
  # Cannot use `typeset -p` unconditionally because of bugs in zsh.
  function _p9k_print_params() {
    local name
    for name; do
      case $parameters[$name] in
        array*)
          print -r -- "$name=(" "${(@q)${(@P)name}}" ")"
        ;;
        association*)
          # Cannot use "${(@q)${(@kvP)name}}" because of bugs in zsh.
          local kv=("${(@kvP)name}")
          print -r -- "$name=(" "${(@q)kv}" ")"
        ;;
        *)
          print -r -- "$name=${(q)${(P)name}}"
        ;;
      esac
    done
  }
fi

# Determine if the passed segment is used in the prompt
#
# Pass the name of the segment to this function to test for its presence in
# either the LEFT or RIGHT prompt arrays.
#    * $1: The segment to be tested.
_p9k_segment_in_use() {
  (( $_POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(I)$1(|_joined)] ||
     $_POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(I)$1(|_joined)] ))
}

# Caching allows storing array-to-array associations. It should be used like this:
#
#   if ! _p9k_cache_get "$key1" "$key2"; then
#     # Compute val1 and val2 and then store them in the cache.
#     _p9k_cache_set "$val1" "$val2"
#   fi
#   # Here ${_p9k__cache_val[1]} and ${_p9k__cache_val[2]} are $val1 and $val2 respectively.
#
# Limitations:
#
#   * Calling _p9k_cache_set without arguments clears the cache entry. Subsequent calls to
#     _p9k_cache_get for the same key will return an error.
#   * There must be no intervening _p9k_cache_get calls between the associated _p9k_cache_get
#     and _p9k_cache_set.
_p9k_cache_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_p9k__cache_key} => (${(q)@})" >&2
  _p9k_cache[$_p9k__cache_key]="${(pj:\0:)*}0"
  _p9k__cache_val=("$@")
  _p9k__state_dump_scheduled=1
}

_p9k_cache_get() {
  _p9k__cache_key="${(pj:\0:)*}"
  local v=$_p9k_cache[$_p9k__cache_key]
  [[ -n $v ]] && _p9k__cache_val=("${(@0)${v[1,-2]}}")
}

_p9k_cache_ephemeral_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_p9k__cache_key} => (${(q)@})" >&2
  _p9k__cache_ephemeral[$_p9k__cache_key]="${(pj:\0:)*}0"
  _p9k__cache_val=("$@")
}

_p9k_cache_ephemeral_get() {
  _p9k__cache_key="${(pj:\0:)*}"
  local v=$_p9k__cache_ephemeral[$_p9k__cache_key]
  [[ -n $v ]] && _p9k__cache_val=("${(@0)${v[1,-2]}}")
}

_p9k_cache_stat_get() {
  local -H stat
  local label=$1 f
  shift

  _p9k__cache_stat_meta=
  _p9k__cache_stat_fprint=

  for f; do
    if zstat -H stat -- $f 2>/dev/null; then
      _p9k__cache_stat_meta+="${(q)f} $stat[inode] $stat[mtime] $stat[size] $stat[mode]; "
    fi
  done

  if _p9k_cache_get $0 $label meta "$@"; then
     if [[ $_p9k__cache_val[1] == $_p9k__cache_stat_meta ]]; then
      _p9k__cache_stat_fprint=$_p9k__cache_val[2]
      local -a key=($0 $label fprint "$@" "$_p9k__cache_stat_fprint")
      _p9k__cache_fprint_key="${(pj:\0:)key}"
      shift 2 _p9k__cache_val
      return 0
    else
      local -a key=($0 $label fprint "$@" "$_p9k__cache_val[2]")
      _p9k__cache_ephemeral[${(pj:\0:)key}]="${(pj:\0:)_p9k__cache_val[3,-1]}0"
    fi
  fi

  if (( $+commands[md5] )); then
    _p9k__cache_stat_fprint="$(md5 -- $* 2>&1)"
  elif (( $+commands[md5sum] )); then
    _p9k__cache_stat_fprint="$(md5sum -b -- $* 2>&1)"
  else
    return 1
  fi

  local meta_key=$_p9k__cache_key
  if _p9k_cache_ephemeral_get $0 $label fprint "$@" "$_p9k__cache_stat_fprint"; then
    _p9k__cache_fprint_key=$_p9k__cache_key
    _p9k__cache_key=$meta_key
    _p9k_cache_set "$_p9k__cache_stat_meta" "$_p9k__cache_stat_fprint" "$_p9k__cache_val[@]"
    shift 2 _p9k__cache_val
    return 0
  fi

  _p9k__cache_fprint_key=$_p9k__cache_key
  _p9k__cache_key=$meta_key
  return 1
}

_p9k_cache_stat_set() {
  _p9k_cache_set "$_p9k__cache_stat_meta" "$_p9k__cache_stat_fprint" "$@"
  _p9k__cache_key=$_p9k__cache_fprint_key
  _p9k_cache_ephemeral_set "$@"
}

# _p9k_param prompt_foo_BAR BACKGROUND red
_p9k_param() {
  local key="_p9k_param ${(pj:\0:)*}"
  _p9k__ret=$_p9k_cache[$key]
  if [[ -n $_p9k__ret ]]; then
    _p9k__ret[-1,-1]=''
  else
    if [[ ${1//-/_} == (#b)prompt_([a-z0-9_]#)(*) ]]; then
      local var=_POWERLEVEL9K_${${(U)match[1]}//0/I}$match[2]_$2
      if (( $+parameters[$var] )); then
        _p9k__ret=${(P)var}
      else
        var=_POWERLEVEL9K_${${(U)match[1]%_}//0/I}_$2
        if (( $+parameters[$var] )); then
          _p9k__ret=${(P)var}
        else
          var=_POWERLEVEL9K_$2
          if (( $+parameters[$var] )); then
            _p9k__ret=${(P)var}
          else
            _p9k__ret=$3
          fi
        fi
      fi
    else
      local var=_POWERLEVEL9K_$2
      if (( $+parameters[$var] )); then
        _p9k__ret=${(P)var}
      else
        _p9k__ret=$3
      fi
    fi
    _p9k_cache[$key]=${_p9k__ret}.
  fi
}

# _p9k_get_icon prompt_foo_BAR BAZ_ICON quix
_p9k_get_icon() {
  local key="_p9k_get_icon ${(pj:\0:)*}"
  _p9k__ret=$_p9k_cache[$key]
  if [[ -n $_p9k__ret ]]; then
    _p9k__ret[-1,-1]=''
  else
    if [[ $2 == $'\1'* ]]; then
      _p9k__ret=${2[2,-1]}
    else
      _p9k_param "$1" "$2" ${icons[$2]-$'\1'$3}
      if [[ $_p9k__ret == $'\1'* ]]; then
        _p9k__ret=${_p9k__ret[2,-1]}
      else
        _p9k__ret=${(g::)_p9k__ret}
        [[ $_p9k__ret != $'\b'? ]] || _p9k__ret="%{$_p9k__ret%}"  # penance for past sins
      fi
    fi
    _p9k_cache[$key]=${_p9k__ret}.
  fi
}

_p9k_translate_color() {
  if [[ $1 == <-> ]]; then                  # decimal color code: 255
    _p9k__ret=${(l.3..0.)1}
  elif [[ $1 == '#'[[:xdigit:]]## ]]; then  # hexademical color code: #ffffff
    _p9k__ret=${${(L)1}//1/i}
  else                                      # named color: red
    # Strip prifixes if there are any.
    _p9k__ret=$__p9k_colors[${${${1#bg-}#fg-}#br}]
  fi
}

# _p9k_color prompt_foo_BAR BACKGROUND red
_p9k_color() {
  local key="_p9k_color ${(pj:\0:)*}"
  _p9k__ret=$_p9k_cache[$key]
  if [[ -n $_p9k__ret ]]; then
    _p9k__ret[-1,-1]=''
  else
    _p9k_param "$@"
    _p9k_translate_color $_p9k__ret
    _p9k_cache[$key]=${_p9k__ret}.
  fi
}

# _p9k_vcs_style CLEAN REMOTE_BRANCH
_p9k_vcs_style() {
  local key="$0 ${(pj:\0:)*}"
  _p9k__ret=$_p9k_cache[$key]
  if [[ -n $_p9k__ret ]]; then
    _p9k__ret[-1,-1]=''
  else
    local style=%b  # TODO: support bold
    _p9k_color prompt_vcs_$1 BACKGROUND "${__p9k_vcs_states[$1]}"
    _p9k_background $_p9k__ret
    style+=$_p9k__ret

    local var=_POWERLEVEL9K_VCS_${1}_${2}FORMAT_FOREGROUND
    if (( $+parameters[$var] )); then
      _p9k_translate_color "${(P)var}"
    else
      var=_POWERLEVEL9K_VCS_${2}FORMAT_FOREGROUND
      if (( $+parameters[$var] )); then
        _p9k_translate_color "${(P)var}"
      else
        _p9k_color prompt_vcs_$1 FOREGROUND "$_p9k_color1"
      fi
    fi

    _p9k_foreground $_p9k__ret
    _p9k__ret=$style$_p9k__ret
    _p9k_cache[$key]=${_p9k__ret}.
  fi
}

_p9k_background() {
  [[ -n $1 ]] && _p9k__ret="%K{$1}" || _p9k__ret="%k"
}

_p9k_foreground() {
  # Note: This code used to produce `%1F` instead of `%F{1}` because it's more efficient.
  # Unfortunately, this triggers a bug in zsh. Namely, `%1F{2}` gets percent-expanded as if
  # it was `%F{2}`.
  [[ -n $1 ]] && _p9k__ret="%F{$1}" || _p9k__ret="%f"
}

_p9k_escape_style() {
  [[ $1 == *'}'* ]] && _p9k__ret='${:-"'$1'"}' || _p9k__ret=$1
}

_p9k_escape() {
  [[ $1 == *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]] && _p9k__ret="\${(Q)\${:-${(qqq)${(q)1}}}}" || _p9k__ret=$1
}

# * $1: Name of the function that was originally invoked.
#       Necessary, to make the dynamic color-overwrite mechanism work.
# * $2: Background color.
# * $3: Foreground color.
# * $4: An identifying icon.
# * $5: 1 to to perform parameter expansion and process substitution.
# * $6: If not empty but becomes empty after parameter expansion and process substitution,
#       the segment isn't rendered.
# * $7: Content.
_p9k_left_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$_p9k__segment_index"; then
    _p9k_color $1 BACKGROUND $2
    local bg_color=$_p9k__ret
    _p9k_background $bg_color
    local bg=$_p9k__ret

    _p9k_color $1 FOREGROUND $3
    local fg_color=$_p9k__ret
    _p9k_foreground $fg_color
    local fg=$_p9k__ret

    local style=%b$bg$fg
    local style_=${style//\}/\\\}}

    _p9k_get_icon $1 LEFT_SEGMENT_SEPARATOR
    local sep=$_p9k__ret
    _p9k_escape $_p9k__ret
    local sep_=$_p9k__ret

    _p9k_get_icon $1 LEFT_SUBSEGMENT_SEPARATOR
    _p9k_escape $_p9k__ret
    local subsep_=$_p9k__ret

    local icon_
    if [[ -n $4 ]]; then
      _p9k_get_icon $1 $4
      _p9k_escape $_p9k__ret
      icon_=$_p9k__ret
    fi

    _p9k_get_icon $1 LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL
    local start_sep=$_p9k__ret
    [[ -n $start_sep ]] && start_sep="%b%k%F{$bg_color}$start_sep"

    _p9k_get_icon $1 LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL $sep
    _p9k_escape $_p9k__ret
    local end_sep_=$_p9k__ret

    _p9k_get_icon $1 WHITESPACE_BETWEEN_LEFT_SEGMENTS ' '
    local space=$_p9k__ret

    _p9k_get_icon $1 LEFT_LEFT_WHITESPACE $space
    local left_space=$_p9k__ret
    [[ $left_space == *%* ]] && left_space+=$style

    _p9k_get_icon $1 LEFT_RIGHT_WHITESPACE $space
    _p9k_escape $_p9k__ret
    local right_space_=$_p9k__ret
    [[ $right_space_ == *%* ]] && right_space_+=$style_

    local s='<_p9k__s>' ss='<_p9k__ss>'

    local -i non_hermetic=0

    # Segment separator logic:
    #
    #   if [[ $_p9k__bg == NONE ]]; then
    #     1
    #   elif (( joined )); then
    #     2
    #   elif [[ $bg_color == (${_p9k__bg}|${_p9k__bg:-0}) ]]; then
    #     3
    #   else
    #     4
    #   fi

    local t=$(($#_p9k_t - __p9k_ksh_arrays))
    _p9k_t+=$start_sep$style$left_space              # 1
    _p9k_t+=$style                                   # 2
    if [[ -n $fg_color && $fg_color == $bg_color ]]; then
      if [[ $fg_color == $_p9k_color1 ]]; then
        _p9k_foreground $_p9k_color2
      else
        _p9k_foreground $_p9k_color1
      fi
      _p9k_t+=%b$bg$_p9k__ret$ss$style$left_space    # 3
    else
      _p9k_t+=%b$bg$ss$style$left_space              # 3
    fi
    _p9k_t+=%b$bg$s$style$left_space                 # 4

    local join="_p9k__i>=$_p9k_left_join[$_p9k__segment_index]"
    _p9k_param $1 SELF_JOINED false
    if [[ $_p9k__ret == false ]]; then
      if (( _p9k__segment_index > $_p9k_left_join[$_p9k__segment_index] )); then
        join+="&&_p9k__i<$_p9k__segment_index"
      else
        join=
      fi
    fi

    local p=
    p+="\${_p9k__n::=}"
    p+="\${\${\${_p9k__bg:-0}:#NONE}:-\${_p9k__n::=$((t+1))}}"                                # 1
    if [[ -n $join ]]; then
      p+="\${_p9k__n:=\${\${\$(($join)):#0}:+$((t+2))}}"                                      # 2
    fi
    if (( __p9k_sh_glob )); then
      p+="\${_p9k__n:=\${\${(M)\${:-x$bg_color}:#x\$_p9k__bg}:+$((t+3))}}"                    # 3
      p+="\${_p9k__n:=\${\${(M)\${:-x$bg_color}:#x\$${_p9k__bg:-0}}:+$((t+3))}}"              # 3
    else
      p+="\${_p9k__n:=\${\${(M)\${:-x$bg_color}:#x(\$_p9k__bg|\${_p9k__bg:-0})}:+$((t+3))}}"  # 3
    fi
    p+="\${_p9k__n:=$((t+4))}"                                                                # 4

    _p9k_param $1 VISUAL_IDENTIFIER_EXPANSION '${P9K_VISUAL_IDENTIFIER}'
    [[ $_p9k__ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local icon_exp_=${_p9k__ret:+\"$_p9k__ret\"}

    _p9k_param $1 CONTENT_EXPANSION '${P9K_CONTENT}'
    [[ $_p9k__ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local content_exp_=${_p9k__ret:+\"$_p9k__ret\"}

    if [[ ( $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ) ||
          ( $content_exp_ != '"${P9K_CONTENT}"' && $content_exp_ == *'$'* ) ]]; then
      p+="\${P9K_VISUAL_IDENTIFIER::=$icon_}"
    fi

    local -i has_icon=-1  # maybe

    if [[ $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ]]; then
      p+='${_p9k__v::='$icon_exp_$style_'}'
    else
      [[ $icon_exp_ == '"${P9K_VISUAL_IDENTIFIER}"' ]] && _p9k__ret=$icon_ || _p9k__ret=$icon_exp_
      if [[ -n $_p9k__ret ]]; then
        p+="\${_p9k__v::=$_p9k__ret"
        [[ $_p9k__ret == *%* ]] && p+=$style_
        p+="}"
        has_icon=1  # definitely yes
      else
        has_icon=0  # definitely no
      fi
    fi

    p+='${_p9k__c::='$content_exp_'}${_p9k__c::=${_p9k__c//'$'\r''}}'
    p+='${_p9k__e::=${${_p9k__'${_p9k__line_index}l${${1#prompt_}%%[A-Z0-9_]#}'+00}:-'
    if (( has_icon == -1 )); then
      p+='${${(%):-$_p9k__c%1(l.1.0)}[-1]}${${(%):-$_p9k__v%1(l.1.0)}[-1]}}'
    else
      p+='${${(%):-$_p9k__c%1(l.1.0)}[-1]}'$has_icon'}'
    fi

    p+='}}+}'

    p+='${${_p9k__e:#00}:+${${_p9k_t[$_p9k__n]/'$ss'/$_p9k__ss}/'$s'/$_p9k__s}'

    _p9k_param $1 ICON_BEFORE_CONTENT ''
    if [[ $_p9k__ret != false ]]; then
      _p9k_param $1 PREFIX ''
      _p9k__ret=${(g::)_p9k__ret}
      _p9k_escape $_p9k__ret
      p+=$_p9k__ret
      [[ $_p9k__ret == *%* ]] && local -i need_style=1 || local -i need_style=0

      if (( has_icon != 0 )); then
        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k__ret
        _p9k__ret=%b$bg$_p9k__ret
        _p9k__ret=${_p9k__ret//\}/\\\}}
        if [[ $_p9k__ret != $style_ ]]; then
          p+=$_p9k__ret'${_p9k__v}'$style_
        else
          (( need_style )) && p+=$style_
          p+='${_p9k__v}'
        fi

        _p9k_get_icon $1 LEFT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k__ret ]]; then
          _p9k_escape $_p9k__ret
          [[ _p9k__ret == *%* ]] && _p9k__ret+=$style_
          p+='${${(M)_p9k__e:#11}:+'$_p9k__ret'}'
        fi
      elif (( need_style )); then
        p+=$style_
      fi

      p+='${_p9k__c}'$style_
    else
      _p9k_param $1 PREFIX ''
      _p9k__ret=${(g::)_p9k__ret}
      _p9k_escape $_p9k__ret
      p+=$_p9k__ret
      [[ $_p9k__ret == *%* ]] && p+=$style_

      p+='${_p9k__c}'$style_

      if (( has_icon != 0 )); then
        local -i need_style=0
        _p9k_get_icon $1 LEFT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k__ret ]]; then
          _p9k_escape $_p9k__ret
          [[ $_p9k__ret == *%* ]] && need_style=1
          p+='${${(M)_p9k__e:#11}:+'$_p9k__ret'}'
        fi

        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k__ret
        _p9k__ret=%b$bg$_p9k__ret
        _p9k__ret=${_p9k__ret//\}/\\\}}
        [[ $_p9k__ret != $style_ || $need_style == 1 ]] && p+=$_p9k__ret
        p+='$_p9k__v'
      fi
    fi

    _p9k_param $1 SUFFIX ''
    _p9k__ret=${(g::)_p9k__ret}
    _p9k_escape $_p9k__ret
    p+=$_p9k__ret
    [[ $_p9k__ret == *%* && -n $right_space_ ]] && p+=$style_
    p+=$right_space_

    p+='${${:-'
    p+="\${_p9k__s::=%F{$bg_color\}$sep_}\${_p9k__ss::=$subsep_}\${_p9k__sss::=%F{$bg_color\}$end_sep_}"
    p+="\${_p9k__i::=$_p9k__segment_index}\${_p9k__bg::=$bg_color}"
    p+='}+}'

    p+='}'

    _p9k_param $1 SHOW_ON_UPGLOB ''
    _p9k_cache_set "$p" $non_hermetic $_p9k__ret
  fi

  if [[ -n $_p9k__cache_val[3] ]]; then
    _p9k__has_upglob=1
    _p9k_upglob $_p9k__cache_val[3] && return
  fi

  _p9k__non_hermetic_expansion=$_p9k__cache_val[2]

  (( $5 )) && _p9k__ret=\"$7\" || _p9k_escape $7
  if [[ -z $6 ]]; then
    _p9k__prompt+="\${\${:-\${P9K_CONTENT::=$_p9k__ret}$_p9k__cache_val[1]"
  else
    _p9k__prompt+="\${\${:-\"$6\"}:+\${\${:-\${P9K_CONTENT::=$_p9k__ret}$_p9k__cache_val[1]}"
  fi
}

# The same as _p9k_left_prompt_segment above but for the right prompt.
_p9k_right_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$_p9k__segment_index"; then
    _p9k_color $1 BACKGROUND $2
    local bg_color=$_p9k__ret
    _p9k_background $bg_color
    local bg=$_p9k__ret
    local bg_=${_p9k__ret//\}/\\\}}

    _p9k_color $1 FOREGROUND $3
    local fg_color=$_p9k__ret
    _p9k_foreground $fg_color
    local fg=$_p9k__ret

    local style=%b$bg$fg
    local style_=${style//\}/\\\}}

    _p9k_get_icon $1 RIGHT_SEGMENT_SEPARATOR
    local sep=$_p9k__ret
    _p9k_escape $_p9k__ret
    local sep_=$_p9k__ret

    _p9k_get_icon $1 RIGHT_SUBSEGMENT_SEPARATOR
    local subsep=$_p9k__ret
    [[ $subsep == *%* ]] && subsep+=$style

    local icon_
    if [[ -n $4 ]]; then
      _p9k_get_icon $1 $4
      _p9k_escape $_p9k__ret
      icon_=$_p9k__ret
    fi

    _p9k_get_icon $1 RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL $sep
    local start_sep=$_p9k__ret
    [[ -n $start_sep ]] && start_sep="%b%k%F{$bg_color}$start_sep"

    _p9k_get_icon $1 RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL
    _p9k_escape $_p9k__ret
    local end_sep_=$_p9k__ret

    _p9k_get_icon $1 WHITESPACE_BETWEEN_RIGHT_SEGMENTS ' '
    local space=$_p9k__ret

    _p9k_get_icon $1 RIGHT_LEFT_WHITESPACE $space
    local left_space=$_p9k__ret
    [[ $left_space == *%* ]] && left_space+=$style

    _p9k_get_icon $1 RIGHT_RIGHT_WHITESPACE $space
    _p9k_escape $_p9k__ret
    local right_space_=$_p9k__ret
    [[ $right_space_ == *%* ]] && right_space_+=$style_

    local w='<_p9k__w>' s='<_p9k__s>'

    local -i non_hermetic=0

    # Segment separator logic:
    #
    #   if [[ $_p9k__bg == NONE ]]; then
    #     1
    #   elif (( joined )); then
    #     2
    #   elif [[ $_p9k__bg == (${bg_color}|${bg_color:-0}) ]]; then
    #     3
    #   else
    #     4
    #   fi

    local t=$(($#_p9k_t - __p9k_ksh_arrays))
    _p9k_t+=$start_sep$style$left_space           # 1
    _p9k_t+=$w$style                              # 2
    _p9k_t+=$w$style$subsep$left_space            # 3
    _p9k_t+=$w%F{$bg_color}$sep$style$left_space  # 4

    local join="_p9k__i>=$_p9k_right_join[$_p9k__segment_index]"
    _p9k_param $1 SELF_JOINED false
    if [[ $_p9k__ret == false ]]; then
      if (( _p9k__segment_index > $_p9k_right_join[$_p9k__segment_index] )); then
        join+="&&_p9k__i<$_p9k__segment_index"
      else
        join=
      fi
    fi

    local p=
    p+="\${_p9k__n::=}"
    p+="\${\${\${_p9k__bg:-0}:#NONE}:-\${_p9k__n::=$((t+1))}}"                                      # 1
    if [[ -n $join ]]; then
      p+="\${_p9k__n:=\${\${\$(($join)):#0}:+$((t+2))}}"                                            # 2
    fi
    if (( __p9k_sh_glob )); then
      p+="\${_p9k__n:=\${\${(M)\${:-x\$_p9k__bg}:#x${(b)bg_color}}:+$((t+3))}}"                     # 3
      p+="\${_p9k__n:=\${\${(M)\${:-x\$_p9k__bg}:#x${(b)bg_color:-0}}:+$((t+3))}}"                  # 3
    else
      p+="\${_p9k__n:=\${\${(M)\${:-x\$_p9k__bg}:#x(${(b)bg_color}|${(b)bg_color:-0})}:+$((t+3))}}" # 3
    fi
    p+="\${_p9k__n:=$((t+4))}"                                                                      # 4

    _p9k_param $1 VISUAL_IDENTIFIER_EXPANSION '${P9K_VISUAL_IDENTIFIER}'
    [[ $_p9k__ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local icon_exp_=${_p9k__ret:+\"$_p9k__ret\"}

    _p9k_param $1 CONTENT_EXPANSION '${P9K_CONTENT}'
    [[ $_p9k__ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local content_exp_=${_p9k__ret:+\"$_p9k__ret\"}

    if [[ ( $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ) ||
          ( $content_exp_ != '"${P9K_CONTENT}"' && $content_exp_ == *'$'* ) ]]; then
      p+="\${P9K_VISUAL_IDENTIFIER::=$icon_}"
    fi

    local -i has_icon=-1  # maybe

    if [[ $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ]]; then
      p+="\${_p9k__v::=$icon_exp_$style_}"
    else
      [[ $icon_exp_ == '"${P9K_VISUAL_IDENTIFIER}"' ]] && _p9k__ret=$icon_ || _p9k__ret=$icon_exp_
      if [[ -n $_p9k__ret ]]; then
        p+="\${_p9k__v::=$_p9k__ret"
        [[ $_p9k__ret == *%* ]] && p+=$style_
        p+="}"
        has_icon=1  # definitely yes
      else
        has_icon=0  # definitely no
      fi
    fi

    p+='${_p9k__c::='$content_exp_'}${_p9k__c::=${_p9k__c//'$'\r''}}'
    p+='${_p9k__e::=${${_p9k__'${_p9k__line_index}r${${1#prompt_}%%[A-Z0-9_]#}'+00}:-'
    if (( has_icon == -1 )); then
      p+='${${(%):-$_p9k__c%1(l.1.0)}[-1]}${${(%):-$_p9k__v%1(l.1.0)}[-1]}}'
    else
      p+='${${(%):-$_p9k__c%1(l.1.0)}[-1]}'$has_icon'}'
    fi

    p+='}}+}'

    p+='${${_p9k__e:#00}:+${_p9k_t[$_p9k__n]/'$w'/$_p9k__w}'

    _p9k_param $1 ICON_BEFORE_CONTENT ''
    if [[ $_p9k__ret != true ]]; then
      _p9k_param $1 PREFIX ''
      _p9k__ret=${(g::)_p9k__ret}
      _p9k_escape $_p9k__ret
      p+=$_p9k__ret
      [[ $_p9k__ret == *%* ]] && p+=$style_

      p+='${_p9k__c}'$style_

      if (( has_icon != 0 )); then
        local -i need_style=0
        _p9k_get_icon $1 RIGHT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k__ret ]]; then
          _p9k_escape $_p9k__ret
          [[ $_p9k__ret == *%* ]] && need_style=1
          p+='${${(M)_p9k__e:#11}:+'$_p9k__ret'}'
        fi

        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k__ret
        _p9k__ret=%b$bg$_p9k__ret
        _p9k__ret=${_p9k__ret//\}/\\\}}
        [[ $_p9k__ret != $style_ || $need_style == 1 ]] && p+=$_p9k__ret
        p+='$_p9k__v'
      fi
    else
      _p9k_param $1 PREFIX ''
      _p9k__ret=${(g::)_p9k__ret}
      _p9k_escape $_p9k__ret
      p+=$_p9k__ret
      [[ $_p9k__ret == *%* ]] && local -i need_style=1 || local -i need_style=0

      if (( has_icon != 0 )); then
        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k__ret
        _p9k__ret=%b$bg$_p9k__ret
        _p9k__ret=${_p9k__ret//\}/\\\}}
        if [[ $_p9k__ret != $style_ ]]; then
          p+=$_p9k__ret'${_p9k__v}'$style_
        else
          (( need_style )) && p+=$style_
          p+='${_p9k__v}'
        fi

        _p9k_get_icon $1 RIGHT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k__ret ]]; then
          _p9k_escape $_p9k__ret
          [[ _p9k__ret == *%* ]] && _p9k__ret+=$style_
          p+='${${(M)_p9k__e:#11}:+'$_p9k__ret'}'
        fi
      elif (( need_style )); then
        p+=$style_
      fi

      p+='${_p9k__c}'$style_
    fi

    _p9k_param $1 SUFFIX ''
    _p9k__ret=${(g::)_p9k__ret}
    _p9k_escape $_p9k__ret
    p+=$_p9k__ret

    p+='${${:-'

    if [[ -n $fg_color && $fg_color == $bg_color ]]; then
      if [[ $fg_color == $_p9k_color1 ]]; then
        _p9k_foreground $_p9k_color2
      else
        _p9k_foreground $_p9k_color1
      fi
    else
      _p9k__ret=$fg
    fi
    _p9k__ret=${_p9k__ret//\}/\\\}}
    p+="\${_p9k__w::=${right_space_:+$style_}$right_space_%b$bg_$_p9k__ret}"

    p+='${_p9k__sss::='
    p+=$style_$right_space_
    [[ $right_space_ == *%* ]] && p+=$style_
    if [[ -n $end_sep_ ]]; then
      p+="%k%F{$bg_color\}$end_sep_$style_"
    fi
    p+='}'

    p+="\${_p9k__i::=$_p9k__segment_index}\${_p9k__bg::=$bg_color}"

    p+='}+}'
    p+='}'

    _p9k_param $1 SHOW_ON_UPGLOB ''
    _p9k_cache_set "$p" $non_hermetic $_p9k__ret
  fi

  if [[ -n $_p9k__cache_val[3] ]]; then
    _p9k__has_upglob=1
    _p9k_upglob $_p9k__cache_val[3] && return
  fi

  _p9k__non_hermetic_expansion=$_p9k__cache_val[2]

  (( $5 )) && _p9k__ret=\"$7\" || _p9k_escape $7
  if [[ -z $6 ]]; then
    _p9k__prompt+="\${\${:-\${P9K_CONTENT::=$_p9k__ret}$_p9k__cache_val[1]"
  else
    _p9k__prompt+="\${\${:-\"$6\"}:+\${\${:-\${P9K_CONTENT::=$_p9k__ret}$_p9k__cache_val[1]}"
  fi
}

function _p9k_prompt_segment() { "_p9k_${_p9k__prompt_side}_prompt_segment" "$@" }
function p9k_prompt_segment() { p10k segment "$@" }

function _p9k_python_version() {
  case $commands[python] in
    "")
      return 1
    ;;
    ${PYENV_ROOT:-~/.pyenv}/shims/python)
      local P9K_PYENV_PYTHON_VERSION _p9k__pyenv_version
      local -i _POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=1 _POWERLEVEL9K_PYENV_SHOW_SYSTEM=1
      local _POWERLEVEL9K_PYENV_SOURCES=(shell local global)
      if _p9k_pyenv_compute && [[ $P9K_PYENV_PYTHON_VERSION == ([[:digit:].]##)* ]]; then
        _p9k__ret=$P9K_PYENV_PYTHON_VERSION
        return 0
      fi
    ;&  # fall through
    *)
      _p9k_cached_cmd 1 '' python --version || return
      [[ $_p9k__ret == (#b)Python\ ([[:digit:].]##)* ]] && _p9k__ret=$match[1]
    ;;
  esac
}

################################################################
# Prompt Segment Definitions
################################################################

################################################################
# Anaconda Environment
prompt_anaconda() {
  local msg
  if _p9k_python_version; then
    P9K_ANACONDA_PYTHON_VERSION=$_p9k__ret
    if (( _POWERLEVEL9K_ANACONDA_SHOW_PYTHON_VERSION )); then
      msg="${P9K_ANACONDA_PYTHON_VERSION//\%/%%} "
    fi
  else
    unset P9K_ANACONDA_PYTHON_VERSION
  fi
  local p=${CONDA_PREFIX:-$CONDA_ENV_PATH}
  msg+="$_POWERLEVEL9K_ANACONDA_LEFT_DELIMITER${${p:t}//\%/%%}$_POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER"
  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "$msg"
}

_p9k_prompt_anaconda_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${CONDA_PREFIX:-$CONDA_ENV_PATH}'
}

# Populates array `reply` with "$#profile:$profile:$region" where $profile and $region
# come from the AWS config (~/.aws/config).
function _p9k_parse_aws_config() {
  local cfg=$1
  typeset -ga reply=()
  [[ -f $cfg && -r $cfg ]] || return

  local -a lines
  lines=(${(f)"$(<$cfg)"}) || return

  local line profile
  local -a match mbegin mend
  for line in $lines; do
    if [[ $line == [[:space:]]#'[default]'[[:space:]]#(|'#'*) ]]; then
      # example: [default]
      profile=default
    elif [[ $line == (#b)'[profile'[[:space:]]##([^[:space:]]|[^[:space:]]*[^[:space:]])[[:space:]]#']'[[:space:]]#(|'#'*) ]]; then
      # example: [profile prod]
      profile=${(Q)match[1]}
    elif [[ $line == (#b)[[:space:]]#region[[:space:]]#=[[:space:]]#([^[:space:]]|[^[:space:]]*[^[:space:]])[[:space:]]# ]]; then
      # example: region = eu-west-1
      if [[ -n $profile ]]; then
        reply+=$#profile:$profile:$match[1]
        profile=
      fi
    fi
  done
}

################################################################
# AWS Profile
prompt_aws() {
  typeset -g P9K_AWS_PROFILE="${AWS_VAULT:-${AWSUME_PROFILE:-${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}}}"
  local pat class state
  for pat class in "${_POWERLEVEL9K_AWS_CLASSES[@]}"; do
    if [[ $P9K_AWS_PROFILE == ${~pat} ]]; then
      [[ -n $class ]] && state=_${${(U)class}//0/I}
      break
    fi
  done

  if [[ -n ${AWS_REGION:-$AWS_DEFAULT_REGION} ]]; then
    typeset -g P9K_AWS_REGION=${AWS_REGION:-$AWS_DEFAULT_REGION}
  else
    local cfg=${AWS_CONFIG_FILE:-~/.aws/config}
    if ! _p9k_cache_stat_get $0 $cfg; then
      local -a reply
      _p9k_parse_aws_config $cfg
      _p9k_cache_stat_set $reply
    fi
    local prefix=$#P9K_AWS_PROFILE:$P9K_AWS_PROFILE:
    local kv=$_p9k__cache_val[(r)${(b)prefix}*]
    typeset -g P9K_AWS_REGION=${kv#$prefix}
  fi

  _p9k_prompt_segment "$0$state" red white 'AWS_ICON' 0 '' "${P9K_AWS_PROFILE//\%/%%}"
}

_p9k_prompt_aws_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${AWS_VAULT:-${AWSUME_PROFILE:-${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}}}'
}

################################################################
# Current Elastic Beanstalk environment
prompt_aws_eb_env() {
  _p9k_upglob .elasticbeanstalk && return
  local dir=$_p9k__parent_dirs[$?]

  if ! _p9k_cache_stat_get $0 $dir/.elasticbeanstalk/config.yml; then
    local env
    env="$(command eb list 2>/dev/null)" || env=
    env="${${(@M)${(@f)env}:#\* *}#\* }"
    _p9k_cache_stat_set "$env"
  fi
  [[ -n $_p9k__cache_val[1] ]] || return
  _p9k_prompt_segment "$0" black green 'AWS_EB_ICON' 0 '' "${_p9k__cache_val[1]//\%/%%}"
}

_p9k_prompt_aws_eb_env_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[eb]'
}

################################################################
# Segment to indicate background jobs with an icon.
prompt_background_jobs() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  local msg
  if (( _POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE )); then
    if (( _POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS )); then
      msg='${(%):-%j}'
    else
      msg='${${(%):-%j}:#1}'
    fi
  fi
  _p9k_prompt_segment $0 "$_p9k_color1" cyan BACKGROUND_JOBS_ICON 1 '${${(%):-%j}:#0}' "$msg"
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

################################################################
# Segment that indicates usage level of current partition.
prompt_disk_usage() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment $0_CRITICAL red    white        DISK_ICON 1 '$_p9k__disk_usage_critical' '$_p9k__disk_usage_pct%%'
  _p9k_prompt_segment $0_WARNING  yellow $_p9k_color1 DISK_ICON 1 '$_p9k__disk_usage_warning'  '$_p9k__disk_usage_pct%%'
  if (( ! _POWERLEVEL9K_DISK_USAGE_ONLY_WARNING )); then
    _p9k_prompt_segment $0_NORMAL $_p9k_color1 yellow   DISK_ICON 1 '$_p9k__disk_usage_normal'   '$_p9k__disk_usage_pct%%'
  fi
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

_p9k_prompt_disk_usage_init() {
  typeset -g _p9k__disk_usage_pct=
  typeset -g _p9k__disk_usage_normal=
  typeset -g _p9k__disk_usage_warning=
  typeset -g _p9k__disk_usage_critical=
  _p9k__async_segments_compute+='_p9k_worker_invoke disk_usage "_p9k_prompt_disk_usage_compute ${(q)_p9k__cwd_a}"'
}

_p9k_prompt_disk_usage_compute() {
  (( $+commands[df] )) || return
  _p9k_worker_async "_p9k_prompt_disk_usage_async ${(q)1}" _p9k_prompt_disk_usage_sync
}

_p9k_prompt_disk_usage_async() {
  local pct=${${=${(f)"$(df -P $1 2>/dev/null)"}[2]}[5]%%%}
  [[ $pct == <0-100> && $pct != $_p9k__disk_usage_pct ]] || return
  _p9k__disk_usage_pct=$pct
  _p9k__disk_usage_normal=
  _p9k__disk_usage_warning=
  _p9k__disk_usage_critical=
  if (( _p9k__disk_usage_pct >= _POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL )); then
    _p9k__disk_usage_critical=1
  elif (( _p9k__disk_usage_pct >= _POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL )); then
    _p9k__disk_usage_warning=1
  elif (( ! _POWERLEVEL9K_DISK_USAGE_ONLY_WARNING )); then
    _p9k__disk_usage_normal=1
  fi
  _p9k_print_params          \
    _p9k__disk_usage_pct     \
    _p9k__disk_usage_normal  \
    _p9k__disk_usage_warning \
    _p9k__disk_usage_critical
  echo -E - 'reset=1'
}

_p9k_prompt_disk_usage_sync() {
  eval $REPLY
  _p9k_worker_reply $REPLY
}

function _p9k_read_file() {
  _p9k__ret=''
  [[ -n $1 ]] && IFS='' read -r _p9k__ret <$1
  [[ -n $_p9k__ret ]]
}

function _p9k_fvm_old() {
  _p9k_upglob fvm && return 1
  local fvm=$_p9k__parent_dirs[$?]/fvm
  if [[ -L $fvm ]]; then
    if [[ ${fvm:A} == (#b)*/versions/([^/]##)/bin/flutter ]]; then
      _p9k_prompt_segment prompt_fvm blue $_p9k_color1 FLUTTER_ICON 0 '' ${match[1]//\%/%%}
      return 0
    fi
  fi
  return 1
}

function _p9k_fvm_new() {
  _p9k_upglob .fvm && return 1
  local sdk=$_p9k__parent_dirs[$?]/.fvm/flutter_sdk
  if [[ -L $sdk ]]; then
    if [[ ${sdk:A} == (#b)*/versions/([^/]##) ]]; then
      _p9k_prompt_segment prompt_fvm blue $_p9k_color1 FLUTTER_ICON 0 '' ${match[1]//\%/%%}
      return 0
    fi
  fi
  return 1
}

prompt_fvm() {
  _p9k_fvm_new || _p9k_fvm_old
}

_p9k_prompt_fvm_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[fvm]'
}

################################################################
# Segment that displays the battery status in levels and colors
prompt_battery() {
  [[ $_p9k_os == (Linux|Android) ]] && _p9k_prompt_battery_set_args
  (( $#_p9k__battery_args )) && _p9k_prompt_segment "${_p9k__battery_args[@]}"
}

_p9k_prompt_battery_init() {
  typeset -ga _p9k__battery_args=()
  if [[ $_p9k_os == OSX && $+commands[pmset] == 1 ]]; then
    _p9k__async_segments_compute+='_p9k_worker_invoke battery _p9k_prompt_battery_compute'
    return
  fi
  if [[ $_p9k_os != (Linux|Android) ||
        -z /sys/class/power_supply/(CMB*|BAT*|battery)/(energy_full|charge_full|charge_counter)(#qN) ]]; then
    typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
  fi
}

_p9k_prompt_battery_compute() {
  _p9k_worker_async _p9k_prompt_battery_async _p9k_prompt_battery_sync
}

_p9k_prompt_battery_async() {
  local prev="${(pj:\0:)_p9k__battery_args}"
  _p9k_prompt_battery_set_args
  [[ "${(pj:\0:)_p9k__battery_args}" == $prev ]] && return 1
  _p9k_print_params _p9k__battery_args
  echo -E - 'reset=2'
}

_p9k_prompt_battery_sync() {
  eval $REPLY
  _p9k_worker_reply $REPLY
}

_p9k_prompt_battery_set_args() {
  _p9k__battery_args=()

  local state remain
  local -i bat_percent

  case $_p9k_os in
    OSX)
      (( $+commands[pmset] )) || return
      local raw_data=${${(Af)"$(pmset -g batt 2>/dev/null)"}[2]}
      [[ $raw_data == *InternalBattery* ]] || return
      remain=${${(s: :)${${(s:; :)raw_data}[3]}}[1]}
      [[ $remain == *no* ]] && remain="..."
      [[ $raw_data =~ '([0-9]+)%' ]] && bat_percent=$match[1]

      case "${${(s:; :)raw_data}[2]}" in
        'charging'|'finishing charge'|'AC attached')
          if (( bat_percent == 100 )); then
            state=CHARGED
            remain=''
          else
            state=CHARGING
          fi
        ;;
        'discharging')
          (( bat_percent < _POWERLEVEL9K_BATTERY_LOW_THRESHOLD )) && state=LOW || state=DISCONNECTED
        ;;
        *)
          state=CHARGED
          remain=''
        ;;
      esac
    ;;

    Linux|Android)
      # See https://sourceforge.net/projects/acpiclient.
      local -a bats=( /sys/class/power_supply/(CMB*|BAT*|battery)/(FN) )
      (( $#bats )) || return

      local -i energy_now energy_full power_now
      local -i is_full=1 is_calculating is_charching
      local dir
      for dir in $bats; do
        local -i pow=0 full=0
        if _p9k_read_file $dir/(energy_full|charge_full|charge_counter)(N); then
          (( energy_full += ${full::=_p9k__ret} ))
        fi
        if _p9k_read_file $dir/(power|current)_now(N) && (( $#_p9k__ret < 9 )); then
          (( power_now += ${pow::=$_p9k__ret} ))
        fi
        if _p9k_read_file $dir/capacity(N); then
          (( energy_now += _p9k__ret * full / 100. + 0.5 ))
        elif _p9k_read_file $dir/(energy|charge)_now(N); then
          (( energy_now += _p9k__ret ))
        fi
        _p9k_read_file $dir/status(N) && local bat_status=$_p9k__ret || continue
        [[ $bat_status != Full                                ]] && is_full=0
        [[ $bat_status == Charging                            ]] && is_charching=1
        [[ $bat_status == (Charging|Discharging) && $pow == 0 ]] && is_calculating=1
      done

      (( energy_full )) || return

      bat_percent=$(( 100. * energy_now / energy_full + 0.5 ))
      (( bat_percent > 100 )) && bat_percent=100

      if (( is_full || (bat_percent == 100 && is_charching) )); then
        state=CHARGED
      else
        if (( is_charching )); then
          state=CHARGING
        elif (( bat_percent < _POWERLEVEL9K_BATTERY_LOW_THRESHOLD )); then
          state=LOW
        else
          state=DISCONNECTED
        fi

        if (( power_now > 0 )); then
          (( is_charching )) && local -i e=$((energy_full - energy_now)) || local -i e=energy_now
          local -i minutes=$(( 60 * e / power_now ))
          (( minutes > 0 )) && remain=$((minutes/60)):${(l#2##0#)$((minutes%60))}
        elif (( is_calculating )); then
          remain="..."
        fi
      fi
    ;;

    *)
      return 0
    ;;
  esac

  (( bat_percent >= _POWERLEVEL9K_BATTERY_${state}_HIDE_ABOVE_THRESHOLD )) && return

  local msg="$bat_percent%%"
  [[ $_POWERLEVEL9K_BATTERY_VERBOSE == 1 && -n $remain ]] && msg+=" ($remain)"

  local icon=BATTERY_ICON
  local var=_POWERLEVEL9K_BATTERY_${state}_STAGES
  local -i idx="${#${(@P)var}}"
  if (( idx )); then
    (( bat_percent < 100 )) && idx=$((bat_percent * idx / 100 + 1))
    icon=$'\1'"${${(@P)var}[idx]}"
  fi

  local bg=$_p9k_color1
  local var=_POWERLEVEL9K_BATTERY_${state}_LEVEL_BACKGROUND
  local -i idx="${#${(@P)var}}"
  if (( idx )); then
    (( bat_percent < 100 )) && idx=$((bat_percent * idx / 100 + 1))
    bg="${${(@P)var}[idx]}"
  fi

  local fg=$_p9k_battery_states[$state]
  local var=_POWERLEVEL9K_BATTERY_${state}_LEVEL_FOREGROUND
  local -i idx="${#${(@P)var}}"
  if (( idx )); then
    (( bat_percent < 100 )) && idx=$((bat_percent * idx / 100 + 1))
    fg="${${(@P)var}[idx]}"
  fi

  _p9k__battery_args=(prompt_battery_$state "$bg" "$fg" $icon 0 '' $msg)
}

################################################################
# Public IP segment
prompt_public_ip() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  local ip='${_p9k__public_ip:-$_POWERLEVEL9K_PUBLIC_IP_NONE}'
  if [[ -n $_POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ]]; then
    _p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" PUBLIC_IP_ICON 1 '${_p9k__public_ip_not_vpn:+'$ip'}' $ip
    _p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" VPN_ICON 1 '${_p9k__public_ip_vpn:+'$ip'}' $ip
  else
    _p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" PUBLIC_IP_ICON 1 $ip $ip
  fi
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

_p9k_prompt_public_ip_init() {
  typeset -g _p9k__public_ip=
  typeset -gF _p9k__public_ip_next_time=0
  _p9k__async_segments_compute+='_p9k_worker_invoke public_ip _p9k_prompt_public_ip_compute'
}

_p9k_prompt_public_ip_compute() {
  (( EPOCHREALTIME >= _p9k__public_ip_next_time )) || return
  _p9k_worker_async _p9k_prompt_public_ip_async _p9k_prompt_public_ip_sync
}

_p9k_prompt_public_ip_async() {
  local ip method
  local -F start=EPOCHREALTIME
  local -F next='start + 5'
  for method in $_POWERLEVEL9K_PUBLIC_IP_METHODS $_POWERLEVEL9K_PUBLIC_IP_METHODS; do
    case $method in
      dig)
        if (( $+commands[dig] )); then
          ip="$(dig +tries=1 +short -4 A myip.opendns.com @resolver1.opendns.com 2>/dev/null)"
          [[ $ip == ';'* ]] && ip=
          if [[ -z $ip ]]; then
            ip="$(dig +tries=1 +short -6 AAAA myip.opendns.com @resolver1.opendns.com 2>/dev/null)"
            [[ $ip == ';'* ]] && ip=
          fi
        fi
      ;;
      curl)
        if (( $+commands[curl] )); then
          ip="$(curl --max-time 5 -w '\n' "$_POWERLEVEL9K_PUBLIC_IP_HOST" 2>/dev/null)"
        fi
      ;;
      wget)
        if (( $+commands[wget] )); then
          ip="$(wget -T 5 -qO- "$_POWERLEVEL9K_PUBLIC_IP_HOST" 2>/dev/null)"
        fi
      ;;
    esac
    [[ $ip =~ '^[0-9a-f.:]+$' ]] || ip=''
    if [[ -n $ip ]]; then
      next=$((start + _POWERLEVEL9K_PUBLIC_IP_TIMEOUT))
      break
    fi
  done
  _p9k__public_ip_next_time=$next
  _p9k_print_params _p9k__public_ip_next_time
  [[ $_p9k__public_ip == $ip ]] && return
  _p9k__public_ip=$ip
  _p9k_print_params _p9k__public_ip
  echo -E - 'reset=1'
}

_p9k_prompt_public_ip_sync() {
  eval $REPLY
  _p9k_worker_reply $REPLY
}

################################################################
# Context: user@hostname (who am I and where am I)
prompt_context() {
  local -i len=$#_p9k__prompt _p9k__has_upglob

  local content
  if [[ $_POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == 0 && -n $DEFAULT_USER && $P9K_SSH == 0 ]]; then
    local user="${(%):-%n}"
    if [[ $user == $DEFAULT_USER ]]; then
      content="${user//\%/%%}"
    fi
  fi

  local state
  if (( P9K_SSH )); then
    if [[ -n "$SUDO_COMMAND" ]]; then
      state="REMOTE_SUDO"
    else
      state="REMOTE"
    fi
  elif [[ -n "$SUDO_COMMAND" ]]; then
    state="SUDO"
  else
    state="DEFAULT"
  fi

  local cond
  for state cond in $state '${${(%):-%#}:#\#}' ROOT '${${(%):-%#}:#\%}'; do
    local text=$content
    if [[ -z $text ]]; then
      local var=_POWERLEVEL9K_CONTEXT_${state}_TEMPLATE
      if (( $+parameters[$var] )); then
        text=${(P)var}
        text=${(g::)text}
      else
        text=$_POWERLEVEL9K_CONTEXT_TEMPLATE
      fi
    fi
    _p9k_prompt_segment "$0_$state" "$_p9k_color1" yellow '' 0 "$cond" "$text"
  done

  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

instant_prompt_context() {
  if [[ $_POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == 0 && -n $DEFAULT_USER && $P9K_SSH == 0 ]]; then
    if [[ ${(%):-%n} == $DEFAULT_USER ]]; then
      if (( ! _POWERLEVEL9K_ALWAYS_SHOW_USER )); then
        return
      fi
    fi
  fi
  prompt_context
}

_p9k_prompt_context_init() {
  if [[ $_POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == 0 && -n $DEFAULT_USER && $P9K_SSH == 0 ]]; then
    if [[ ${(%):-%n} == $DEFAULT_USER ]]; then
      if (( ! _POWERLEVEL9K_ALWAYS_SHOW_USER )); then
        typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
      fi
    fi
  fi
}

################################################################
# User: user (who am I)
prompt_user() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment "${0}_ROOT" "${_p9k_color1}" yellow ROOT_ICON 0 '${${(%):-%#}:#\%}' "$_POWERLEVEL9K_USER_TEMPLATE"
  if [[ -n "$SUDO_COMMAND" ]]; then
    _p9k_prompt_segment "${0}_SUDO" "${_p9k_color1}" yellow SUDO_ICON 0 '${${(%):-%#}:#\#}' "$_POWERLEVEL9K_USER_TEMPLATE"
  else
    _p9k_prompt_segment "${0}_DEFAULT" "${_p9k_color1}" yellow USER_ICON 0 '${${(%):-%#}:#\#}' "%n"
  fi
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

instant_prompt_user() {
  if [[ $_POWERLEVEL9K_ALWAYS_SHOW_USER == 0 && "${(%):-%n}" == $DEFAULT_USER ]]; then
    return
  fi
  prompt_user
}

_p9k_prompt_user_init() {
  if [[ $_POWERLEVEL9K_ALWAYS_SHOW_USER == 0 && "${(%):-%n}" == $DEFAULT_USER ]]; then
    typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
  fi
}

################################################################
# Host: machine (where am I)
prompt_host() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  if (( P9K_SSH )); then
    _p9k_prompt_segment "$0_REMOTE" "${_p9k_color1}" yellow SSH_ICON 0 '' "$_POWERLEVEL9K_HOST_TEMPLATE"
  else
    _p9k_prompt_segment "$0_LOCAL" "${_p9k_color1}" yellow HOST_ICON 0 '' "$_POWERLEVEL9K_HOST_TEMPLATE"
  fi
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

instant_prompt_host() { prompt_host; }

################################################################
# Toolbox: https://github.com/containers/toolbox
function prompt_toolbox() {
  _p9k_prompt_segment $0 $_p9k_color1 yellow TOOLBOX_ICON 0 '' $P9K_TOOLBOX_NAME
}

_p9k_prompt_toolbox_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$P9K_TOOLBOX_NAME'
}

function instant_prompt_toolbox() {
  _p9k_prompt_segment prompt_toolbox $_p9k_color1 yellow TOOLBOX_ICON 1 '$P9K_TOOLBOX_NAME' '$P9K_TOOLBOX_NAME'
}

################################################################
# The 'custom` prompt provides a way for users to invoke commands and display
# the output in a segment.
_p9k_custom_prompt() {
  local segment_name=${1:u}
  local command=_POWERLEVEL9K_CUSTOM_${segment_name}
  command=${(P)command}
  local parts=("${(@z)command}")
  local cmd="${(Q)parts[1]}"
  (( $+functions[$cmd] || $+commands[$cmd] )) || return
  local content="$(eval $command)"
  [[ -n $content ]] || return
  _p9k_prompt_segment "prompt_custom_$1" $_p9k_color2 $_p9k_color1 "CUSTOM_${segment_name}_ICON" 0 '' "$content"
}

################################################################
# Display the duration the command needed to run.
prompt_command_execution_time() {
  (( $+P9K_COMMAND_DURATION_SECONDS )) || return
  (( P9K_COMMAND_DURATION_SECONDS >= _POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD )) || return

  if (( P9K_COMMAND_DURATION_SECONDS < 60 )); then
    if (( !_POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION )); then
      local -i sec=$((P9K_COMMAND_DURATION_SECONDS + 0.5))
    else
      local -F $_POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION sec=P9K_COMMAND_DURATION_SECONDS
    fi
    local text=${sec}s
  else
    local -i d=$((P9K_COMMAND_DURATION_SECONDS + 0.5))
    if [[ $_POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT == "H:M:S" ]]; then
      local text=${(l.2..0.)$((d % 60))}
      if (( d >= 60 )); then
        text=${(l.2..0.)$((d / 60 % 60))}:$text
        if (( d >= 36000 )); then
          text=$((d / 3600)):$text
        elif (( d >= 3600 )); then
          text=0$((d / 3600)):$text
        fi
      fi
    else
      local text="$((d % 60))s"
      if (( d >= 60 )); then
        text="$((d / 60 % 60))m $text"
        if (( d >= 3600 )); then
          text="$((d / 3600 % 24))h $text"
          if (( d >= 86400 )); then
            text="$((d / 86400))d $text"
          fi
        fi
      fi
    fi
  fi

  _p9k_prompt_segment "$0" "red" "yellow1" 'EXECUTION_TIME_ICON' 0 '' $text
}

function _p9k_shorten_delim_len() {
  local def=$1
  _p9k__ret=${_POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1}
  (( _p9k__ret >= 0 )) || _p9k_prompt_length $1
}

# Percents are duplicated because this function is currently used only
# where the result is going to be percent-expanded.
function _p9k_url_escape() {
  if [[ $1 == [a-zA-Z0-9"/:_.-!'()~ "]# ]]; then
    _p9k__ret=${1// /%%20}
  else
    local c
    _p9k__ret=
    for c in ${(s::)1}; do
      [[ $c == [a-zA-Z0-9"/:_.-!'()~"] ]] || printf -v c '%%%%%02X' $(( #c ))
      _p9k__ret+=$c
    done
  fi
}

################################################################
# Dir: current working directory
prompt_dir() {
  if (( _POWERLEVEL9K_DIR_PATH_ABSOLUTE )); then
    local p=${(V)_p9k__cwd}
    local -a parts=("${(s:/:)p}")
  elif [[ -o auto_name_dirs ]]; then
    local p=${(V)${_p9k__cwd/#(#b)$HOME(|\/*)/'~'$match[1]}}
    local -a parts=("${(s:/:)p}")
  else
    local p=${(%):-%~}
    if [[ $p == '~['* ]]; then
      # If "${(%):-%~}" expands to "~[a]/]/b", is the first component "~[a]" or "~[a]/]"?
      # One would expect "${(%):-%-1~}" to give the right answer but alas it always simply
      # gives the segment before the first slash, which would be "~[a]" in this case. Worse,
      # for "~[a/b]" it'll give the nonsensical "~[a". To solve this problem we have to
      # repeat what "${(%):-%~}" does and hope that it produces the same result.
      local func=''
      local -a parts=()
      for func in zsh_directory_name $zsh_directory_name_functions; do
        local reply=()
        if (( $+functions[$func] )) && $func d $_p9k__cwd && [[ $p == '~['${(V)reply[1]}']'* ]]; then
          parts+='~['${(V)reply[1]}']'
          break
        fi
      done
      if (( $#parts )); then
        parts+=(${(s:/:)${p#$parts[1]}})
      else
        p=${(V)_p9k__cwd}
        parts=("${(s:/:)p}")
      fi
    else
      local -a parts=("${(s:/:)p}")
    fi
  fi

  local -i fake_first=0 expand=0 shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:--1}

  if (( $+_POWERLEVEL9K_SHORTEN_DELIMITER )); then
    local delim=$_POWERLEVEL9K_SHORTEN_DELIMITER
  else
    if [[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]]; then
      local delim=$'\u2026'
    else
      local delim='..'
    fi
  fi

  case $_POWERLEVEL9K_SHORTEN_STRATEGY in
    truncate_absolute|truncate_absolute_chars)
      if (( shortenlen > 0 && $#p > shortenlen )); then
        _p9k_shorten_delim_len $delim
        if (( $#p > shortenlen + $_p9k__ret )); then
          local -i n=shortenlen
          local -i i=$#parts
          while true; do
            local dir=$parts[i]
            local -i len=$(( $#dir + (i > 1) ))
            if (( len <= n )); then
              (( n -= len ))
              (( --i ))
            else
              parts[i]=$'\1'$dir[-n,-1]
              parts[1,i-1]=()
              break
            fi
          done
        fi
      fi
    ;;
    truncate_with_package_name|truncate_middle|truncate_from_right)
      () {
        [[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_with_package_name &&
           $+commands[jq] == 1 && $#_POWERLEVEL9K_DIR_PACKAGE_FILES > 0 ]] || return
        local pats="(${(j:|:)_POWERLEVEL9K_DIR_PACKAGE_FILES})"
        local -i i=$#parts
        local dir=$_p9k__cwd
        for (( ; i > 0; --i )); do
          local markers=($dir/${~pats}(N))
          if (( $#markers )); then
            local pat= pkg_file=
            for pat in $_POWERLEVEL9K_DIR_PACKAGE_FILES; do
              for pkg_file in $markers; do
                [[ $pkg_file == $dir/${~pat} ]] || continue
                if ! _p9k_cache_stat_get $0_pkg $pkg_file; then
                  local pkg_name=''
                  pkg_name="$(jq -j '.name | select(. != null)' <$pkg_file 2>/dev/null)" || pkg_name=''
                  _p9k_cache_stat_set "$pkg_name"
                fi
                [[ -n $_p9k__cache_val[1] ]] || continue
                parts[1,i]=($_p9k__cache_val[1])
                fake_first=1
                return 0
              done
            done
          fi
          dir=${dir:h}
        done
      }
      if (( shortenlen > 0 )); then
        _p9k_shorten_delim_len $delim
        local -i d=_p9k__ret pref=shortenlen suf=0 i=2
        [[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_middle ]] && suf=pref
        for (( ; i < $#parts; ++i )); do
          local dir=$parts[i]
          if (( $#dir > pref + suf + d )); then
            dir[pref+1,-suf-1]=$'\1'
            parts[i]=$dir
          fi
        done
      fi
    ;;
    truncate_to_last)
      shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:-1}
      (( shortenlen > 0 )) || shortenlen=1
      local -i i='shortenlen+1'
      if [[ $#parts -gt i || $p[1] != / && $#parts -gt shortenlen ]]; then
        fake_first=1
        parts[1,-i]=()
      fi
    ;;
    truncate_to_first_and_last)
      if (( shortenlen > 0 )); then
        local -i i=$(( shortenlen + 1 ))
        [[ $p == /* ]] && (( ++i ))
        for (( ; i <= $#parts - shortenlen; ++i )); do
          parts[i]=$'\1'
        done
      fi
    ;;
    truncate_to_unique)
      expand=1
      delim=${_POWERLEVEL9K_SHORTEN_DELIMITER-'*'}
      shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:-1}
      (( shortenlen >= 0 )) || shortenlen=1
      local rp=${(g:oce:)p}
      local rparts=("${(@s:/:)rp}")

      local -i i=2 e=$(($#parts - shortenlen))
      if [[ -n $_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER ]]; then
        (( e += shortenlen ))
        local orig=("$parts[2]" "${(@)parts[$((shortenlen > $#parts ? -$#parts : -shortenlen)),-1]}")
      elif [[ $p[1] == / ]]; then
        (( ++i ))
      fi
      if (( i <= e )); then
        local mtimes=(${(Oa)_p9k__parent_mtimes:$(($#parts-e)):$((e-i+1))})
        local key="${(pj.:.)mtimes}"
      else
        local key=
      fi
      if ! _p9k_cache_ephemeral_get $0 $e $i $_p9k__cwd || [[ $key != $_p9k__cache_val[1] ]]; then
        local rtail=${(j./.)rparts[i,-1]}
        local parent=$_p9k__cwd[1,-2-$#rtail]
        _p9k_prompt_length $delim
        local -i real_delim_len=_p9k__ret
        [[ -n $parts[i-1] ]] && parts[i-1]="\${(Q)\${:-${(qqq)${(q)parts[i-1]}}}}"$'\2'
        local -i d=${_POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1}
        (( d >= 0 )) || d=real_delim_len
        local -i m=1
        for (( ; i <= e; ++i, ++m )); do
          local sub=$parts[i]
          local rsub=$rparts[i]
          local dir=$parent/$rsub mtime=$mtimes[m]
          local pair=$_p9k__dir_stat_cache[$dir]
          if [[ $pair == ${mtime:-x}:* ]]; then
            parts[i]=${pair#*:}
          else
            [[ $sub != *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]]
            local -i q=$?
            if [[ -n $_POWERLEVEL9K_SHORTEN_FOLDER_MARKER &&
                  -n $dir/${~_POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]]; then
              (( q )) && parts[i]="\${(Q)\${:-${(qqq)${(q)sub}}}}"
              parts[i]+=$'\2'
            else
              local -i j=$rsub[(i)[^.]]
              for (( ; j + d < $#rsub; ++j )); do
                local -a matching=($parent/$rsub[1,j]*/(N))
                (( $#matching == 1 )) && break
              done
              local -i saved=$((${(m)#${(V)${rsub:$j}}} - d))
              if (( saved > 0 )); then
                if (( q )); then
                  parts[i]='${${${_p9k__d:#-*}:+${(Q)${:-'${(qqq)${(q)sub}}'}}}:-${(Q)${:-'
                  parts[i]+=$'\3'${(qqq)${(q)${(V)${rsub[1,j]}}}}$'}}\1\3''${$((_p9k__d+='$saved'))+}}'
                else
                  parts[i]='${${${_p9k__d:#-*}:+'$sub$'}:-\3'${(V)${rsub[1,j]}}$'\1\3''${$((_p9k__d+='$saved'))+}}'
                fi
              else
                (( q )) && parts[i]="\${(Q)\${:-${(qqq)${(q)sub}}}}"
              fi
            fi
            [[ -n $mtime ]] && _p9k__dir_stat_cache[$dir]="$mtime:$parts[i]"
          fi
          parent+=/$rsub
        done
        if [[ -n $_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER ]]; then
          local _2=$'\2'
          if [[ $_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER == last* ]]; then
            (( e = ${parts[(I)*$_2]} + ${_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER#*:} ))
          else
            (( e = ${parts[(ib:2:)*$_2]} + ${_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER#*:} ))
          fi
          if (( e > 1 && e <= $#parts )); then
            parts[1,e-1]=()
            fake_first=1
          elif [[ $p == /?* ]]; then
            parts[2]="\${(Q)\${:-${(qqq)${(q)orig[1]}}}}"$'\2'
          fi
          for ((i = $#parts < shortenlen ? $#parts : shortenlen; i > 0; --i)); do
            [[ $#parts[-i] == *$'\2' ]] && continue
            if [[ $orig[-i] == *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]]; then
              parts[-i]='${(Q)${:-'${(qqq)${(q)orig[-i]}}'}}'$'\2'
            else
              parts[-i]=${orig[-i]}$'\2'
            fi
          done
        else
          for ((; i <= $#parts; ++i)); do
            [[ $parts[i] == *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]] && parts[i]='${(Q)${:-'${(qqq)${(q)parts[i]}}'}}'
            parts[i]+=$'\2'
          done
        fi
        _p9k_cache_ephemeral_set "$key" "${parts[@]}"
      fi
      parts=("${(@)_p9k__cache_val[2,-1]}")
    ;;
    truncate_with_folder_marker)
      if [[ -n $_POWERLEVEL9K_SHORTEN_FOLDER_MARKER ]]; then
        local dir=$_p9k__cwd
        local -a m=()
        local -i i=$(($#parts - 1))
        for (( ; i > 1; --i )); do
          dir=${dir:h}
          [[ -n $dir/${~_POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]] && m+=$i
        done
        m+=1
        for (( i=1; i < $#m; ++i )); do
          (( m[i] - m[i+1] > 2 )) && parts[m[i+1]+1,m[i]-1]=($'\1')
        done
      fi
    ;;
    *)
      if (( shortenlen > 0 )); then
        local -i len=$#parts
        [[ -z $parts[1] ]] && (( --len ))
        if (( len > shortenlen )); then
          parts[1,-shortenlen-1]=($'\1')
        fi
      fi
    ;;
  esac

  # w=0: writable
  # w=1: not writable
  # w=2: does not exist
  (( !_POWERLEVEL9K_DIR_SHOW_WRITABLE )) || [[ -w $_p9k__cwd ]]
  local -i w=$?
  (( w && _POWERLEVEL9K_DIR_SHOW_WRITABLE > 2 )) && [[ ! -e $_p9k__cwd ]] && w=2
  if ! _p9k_cache_ephemeral_get $0 $_p9k__cwd $p $w $fake_first "${parts[@]}"; then
    local state=$0
    local icon=''
    local a='' b='' c=''
    for a b c in "${_POWERLEVEL9K_DIR_CLASSES[@]}"; do
      if [[ $_p9k__cwd == ${~a} ]]; then
        [[ -n $b ]] && state+=_${${(U)b}//0/I}
        icon=$'\1'$c
        break
      fi
    done
    if (( w )); then
      if (( _POWERLEVEL9K_DIR_SHOW_WRITABLE == 1 )); then
        state=${0}_NOT_WRITABLE
      elif (( w == 2 )); then
        state+=_NON_EXISTENT
      else
        state+=_NOT_WRITABLE
      fi
      icon=LOCK_ICON
    fi

    local state_u=${${(U)state}//0/I}

    local style=%b
    _p9k_color $state BACKGROUND blue
    _p9k_background $_p9k__ret
    style+=$_p9k__ret
    _p9k_color $state FOREGROUND "$_p9k_color1"
    _p9k_foreground $_p9k__ret
    style+=$_p9k__ret
    if (( expand )); then
      _p9k_escape_style $style
      style=$_p9k__ret
    fi

    parts=("${(@)parts//\%/%%}")
    if [[ $_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION != '~' && $fake_first == 0 && $p == ('~'|'~/'*) ]]; then
      (( expand )) && _p9k_escape $_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION || _p9k__ret=$_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION
      parts[1]=$_p9k__ret
      [[ $_p9k__ret == *%* ]] && parts[1]+=$style
    elif [[ $_POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == 1 && $fake_first == 0 && $#parts > 1 && -z $parts[1] && -n $parts[2] ]]; then
      parts[1]=()
    fi

    local last_style=
    _p9k_param $state PATH_HIGHLIGHT_BOLD ''
    [[ $_p9k__ret == true ]] && last_style+=%B
    if (( $+parameters[_POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND] ||
          $+parameters[_POWERLEVEL9K_${state_u}_PATH_HIGHLIGHT_FOREGROUND] )); then
      _p9k_color $state PATH_HIGHLIGHT_FOREGROUND ''
      _p9k_foreground $_p9k__ret
      last_style+=$_p9k__ret
    fi
    if [[ -n $last_style ]]; then
      (( expand )) && _p9k_escape_style $last_style || _p9k__ret=$last_style
      parts[-1]=$_p9k__ret${parts[-1]//$'\1'/$'\1'$_p9k__ret}$style
    fi

    local anchor_style=
    _p9k_param $state ANCHOR_BOLD ''
    [[ $_p9k__ret == true ]] && anchor_style+=%B
    if (( $+parameters[_POWERLEVEL9K_DIR_ANCHOR_FOREGROUND] ||
          $+parameters[_POWERLEVEL9K_${state_u}_ANCHOR_FOREGROUND] )); then
      _p9k_color $state ANCHOR_FOREGROUND ''
      _p9k_foreground $_p9k__ret
      anchor_style+=$_p9k__ret
    fi
    if [[ -n $anchor_style ]]; then
      (( expand )) && _p9k_escape_style $anchor_style || _p9k__ret=$anchor_style
      if [[ -z $last_style ]]; then
        parts=("${(@)parts/%(#b)(*)$'\2'/$_p9k__ret$match[1]$style}")
      else
        (( $#parts > 1 )) && parts[1,-2]=("${(@)parts[1,-2]/%(#b)(*)$'\2'/$_p9k__ret$match[1]$style}")
        parts[-1]=${parts[-1]/$'\2'}
      fi
    else
      parts=("${(@)parts/$'\2'}")
    fi

    if (( $+parameters[_POWERLEVEL9K_DIR_SHORTENED_FOREGROUND] ||
          $+parameters[_POWERLEVEL9K_${state_u}_SHORTENED_FOREGROUND] )); then
      _p9k_color $state SHORTENED_FOREGROUND ''
      _p9k_foreground $_p9k__ret
      (( expand )) && _p9k_escape_style $_p9k__ret
      local shortened_fg=$_p9k__ret
      (( expand )) && _p9k_escape $delim || _p9k__ret=$delim
      [[ $_p9k__ret == *%* ]] && _p9k__ret+=$style$shortened_fg
      parts=("${(@)parts/(#b)$'\3'(*)$'\1'(*)$'\3'/$shortened_fg$match[1]$_p9k__ret$match[2]$style}")
      parts=("${(@)parts/(#b)(*)$'\1'(*)/$shortened_fg$match[1]$_p9k__ret$match[2]$style}")
    else
      (( expand )) && _p9k_escape $delim || _p9k__ret=$delim
      [[ $_p9k__ret == *%* ]] && _p9k__ret+=$style
      parts=("${(@)parts/$'\1'/$_p9k__ret}")
      parts=("${(@)parts//$'\3'}")
    fi

    if [[ $_p9k__cwd == / && $_POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == 1 ]]; then
      local sep='/'
    else
      local sep=''
      if (( $+parameters[_POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND] ||
            $+parameters[_POWERLEVEL9K_${state_u}_PATH_SEPARATOR_FOREGROUND] )); then
        _p9k_color $state PATH_SEPARATOR_FOREGROUND ''
        _p9k_foreground $_p9k__ret
        (( expand )) && _p9k_escape_style $_p9k__ret
        sep=$_p9k__ret
      fi
      _p9k_param $state PATH_SEPARATOR /
      _p9k__ret=${(g::)_p9k__ret}
      (( expand )) && _p9k_escape $_p9k__ret
      sep+=$_p9k__ret
      [[ $sep == *%* ]] && sep+=$style
    fi

    local content="${(pj.$sep.)parts}"
    if (( _POWERLEVEL9K_DIR_HYPERLINK && _p9k_term_has_href )) && [[ $_p9k__cwd == /* ]]; then
      _p9k_url_escape $_p9k__cwd
      local header=$'%{\e]8;;file://'$_p9k__ret$'\a%}'
      local footer=$'%{\e]8;;\a%}'
      if (( expand )); then
        _p9k_escape $header
        header=$_p9k__ret
        _p9k_escape $footer
        footer=$_p9k__ret
      fi
      content=$header$content$footer
    fi

    (( expand )) && _p9k_prompt_length "${(e):-"\${\${_p9k__d::=0}+}$content"}" || _p9k__ret=
    _p9k_cache_ephemeral_set "$state" "$icon" "$expand" "$content" $_p9k__ret
  fi

  if (( _p9k__cache_val[3] )); then
    if (( $+_p9k__dir )); then
      _p9k__cache_val[4]='${${_p9k__d::=-1024}+}'$_p9k__cache_val[4]
    else
      _p9k__dir=$_p9k__cache_val[4]
      _p9k__dir_len=$_p9k__cache_val[5]
      _p9k__cache_val[4]='%{d%}'$_p9k__cache_val[4]'%{d%}'
    fi
  fi
  _p9k_prompt_segment "$_p9k__cache_val[1]" "blue" "$_p9k_color1" "$_p9k__cache_val[2]" "$_p9k__cache_val[3]" "" "$_p9k__cache_val[4]"
}

instant_prompt_dir() { prompt_dir; }

################################################################
# Docker machine
prompt_docker_machine() {
  _p9k_prompt_segment "$0" "magenta" "$_p9k_color1" 'SERVER_ICON' 0 '' "${DOCKER_MACHINE_NAME//\%/%%}"
}

_p9k_prompt_docker_machine_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$DOCKER_MACHINE_NAME'
}

################################################################
# GO prompt
prompt_go_version() {
  _p9k_cached_cmd 0 '' go version || return
  [[ $_p9k__ret == (#b)*go([[:digit:].]##)* ]] || return
  local v=$match[1]
  if (( _POWERLEVEL9K_GO_VERSION_PROJECT_ONLY )); then
    local p=$GOPATH
    if [[ -z $p ]]; then
      if [[ -d $HOME/go ]]; then
        p=$HOME/go
      else
        p="$(go env GOPATH 2>/dev/null)" && [[ -n $p ]] || return
      fi
    fi
    if [[ $_p9k__cwd/ != $p/* && $_p9k__cwd_a/ != $p/* ]]; then
      _p9k_upglob go.mod && return
    fi
  fi
  _p9k_prompt_segment "$0" "green" "grey93" "GO_ICON" 0 '' "${v//\%/%%}"
}

_p9k_prompt_go_version_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[go]'
}

################################################################
# Command number (in local history)
prompt_history() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment "$0" "grey50" "$_p9k_color1" '' 0 '' '%h'
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

prompt_package() {
  unset P9K_PACKAGE_NAME P9K_PACKAGE_VERSION
  _p9k_upglob package.json && return

  local file=$_p9k__parent_dirs[$?]/package.json
  if ! _p9k_cache_stat_get $0 $file; then
    () {
      local data field
      local -A found
      # Redneck json parsing. Yields correct results for any well-formed json document.
      # Produces random garbage for invalid json.
      { data="$(<$file)" || return } 2>/dev/null
      data=${${data//$'\r'}##[[:space:]]#}
      [[ $data == '{'* ]] || return
      data[1]=
      local -i depth=1
      while true; do
        data=${data##[[:space:]]#}
        [[ -n $data ]] || return
        case $data[1] in
          '{'|'[')      data[1]=; (( ++depth ));;
          '}'|']')      data[1]=; (( --depth > 0 )) || return;;
          ':')          data[1]=;;
          ',')          data[1]=; field=;;
          [[:alnum:].]) data=${data##[[:alnum:].]#};;
          '"')
            local tail=${data##\"([^\"\\]|\\?)#}
            [[ $tail == '"'* ]] || return
            local s=${data:1:-$#tail}
            data=${tail:1}
            (( depth == 1 )) || continue
            if [[ -z $field ]]; then
              field=${s:-x}
            elif [[ $field == (name|version) ]]; then
              (( ! $+found[$field] ))   || return
              [[ -n $s ]]               || return
              [[ $s != *($'\n'|'\')* ]] || return
              found[$field]=$s
              (( $#found == 2 )) && break
            fi
          ;;
          *) return 1;;
        esac
      done
      _p9k_cache_stat_set 1 $found[name] $found[version]
      return 0
    } || _p9k_cache_stat_set 0
  fi
  (( _p9k__cache_val[1] )) || return

  P9K_PACKAGE_NAME=$_p9k__cache_val[2]
  P9K_PACKAGE_VERSION=$_p9k__cache_val[3]
  _p9k_prompt_segment "$0" "cyan" "$_p9k_color1" PACKAGE_ICON 0 '' ${P9K_PACKAGE_VERSION//\%/%%}
}

################################################################
# Detection for virtualization (systemd based systems only)
prompt_detect_virt() {
  local virt="$(systemd-detect-virt 2>/dev/null)"
  if [[ "$virt" == "none" ]]; then
    local -a inode
    if zstat -A inode +inode / 2>/dev/null && [[ $inode[1] != 2 ]]; then
      virt="chroot"
    fi
  fi
  if [[ -n "${virt}" ]]; then
    _p9k_prompt_segment "$0" "$_p9k_color1" "yellow" '' 0 '' "${virt//\%/%%}"
  fi
}

_p9k_prompt_detect_virt_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[systemd-detect-virt]'
}

################################################################
# Segment to display the current IP address
prompt_ip() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment "$0" "cyan" "$_p9k_color1" 'NETWORK_ICON' 1 '$P9K_IP_IP' '$P9K_IP_IP'
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

################################################################
# Segment to display if VPN is active
prompt_vpn_ip() {
  typeset -ga _p9k__vpn_ip_segments
  _p9k__vpn_ip_segments+=($_p9k__prompt_side $_p9k__line_index $_p9k__segment_index)
  local p='${(e)_p9k__vpn_ip_'$_p9k__prompt_side$_p9k__segment_index'}'
  _p9k__prompt+=$p
  typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$p
}

_p9k_vpn_ip_render() {
  local _p9k__segment_name=vpn_ip _p9k__prompt_side ip
  local -i _p9k__has_upglob _p9k__segment_index
  for _p9k__prompt_side _p9k__line_index _p9k__segment_index in $_p9k__vpn_ip_segments; do
    local _p9k__prompt=
    for ip in $_p9k__vpn_ip_ips; do
      _p9k_prompt_segment prompt_vpn_ip "cyan" "$_p9k_color1" 'VPN_ICON' 0 '' $ip
    done
    typeset -g _p9k__vpn_ip_$_p9k__prompt_side$_p9k__segment_index=$_p9k__prompt
  done
}

################################################################
# Segment to display laravel version
prompt_laravel_version() {
  _p9k_upglob artisan && return
  local dir=$_p9k__parent_dirs[$?]
  local app=$dir/vendor/laravel/framework/src/Illuminate/Foundation/Application.php
  [[ -r $app ]] || return
  if ! _p9k_cache_stat_get $0 $dir/artisan $app; then
    local v="$(php $dir/artisan --version 2> /dev/null)"
    _p9k_cache_stat_set "${${(M)v:#Laravel Framework *}#Laravel Framework }"
  fi
  [[ -n $_p9k__cache_val[1] ]] || return
  _p9k_prompt_segment "$0" "maroon" "white" 'LARAVEL_ICON' 0 '' "${_p9k__cache_val[1]//\%/%%}"
}

_p9k_prompt_laravel_version_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[php]'
}

################################################################
# Segment to display load
prompt_load() {
  if [[ $_p9k_os == (OSX|BSD) ]]; then
    local -i len=$#_p9k__prompt _p9k__has_upglob
    _p9k_prompt_segment $0_CRITICAL red    "$_p9k_color1" LOAD_ICON 1 '$_p9k__load_critical' '$_p9k__load_value'
    _p9k_prompt_segment $0_WARNING  yellow "$_p9k_color1" LOAD_ICON 1 '$_p9k__load_warning'  '$_p9k__load_value'
    _p9k_prompt_segment $0_NORMAL   green  "$_p9k_color1" LOAD_ICON 1 '$_p9k__load_normal'   '$_p9k__load_value'
    (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
    return
  fi

  [[ -r /proc/loadavg ]] || return
  _p9k_read_file /proc/loadavg || return
  local load=${${(A)=_p9k__ret}[_POWERLEVEL9K_LOAD_WHICH]//,/.}
  local -F pct='100. * load / _p9k_num_cpus'
  if (( pct > _POWERLEVEL9K_LOAD_CRITICAL_PCT )); then
    _p9k_prompt_segment $0_CRITICAL red    "$_p9k_color1" LOAD_ICON 0 '' $load
  elif (( pct > _POWERLEVEL9K_LOAD_WARNING_PCT )); then
    _p9k_prompt_segment $0_WARNING  yellow "$_p9k_color1" LOAD_ICON 0 '' $load
  else
    _p9k_prompt_segment $0_NORMAL   green  "$_p9k_color1" LOAD_ICON 0 '' $load
  fi
}

_p9k_prompt_load_init() {
  if [[ $_p9k_os == (OSX|BSD) ]]; then
    typeset -g _p9k__load_value=
    typeset -g _p9k__load_normal=
    typeset -g _p9k__load_warning=
    typeset -g _p9k__load_critical=
    _p9k__async_segments_compute+='_p9k_worker_invoke load _p9k_prompt_load_compute'
  elif [[ ! -r /proc/loadavg ]]; then
    typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
  fi
}

_p9k_prompt_load_compute() {
  (( $+commands[sysctl] )) || return
  _p9k_worker_async _p9k_prompt_load_async _p9k_prompt_load_sync
}

_p9k_prompt_load_async() {
  local load="$(sysctl -n vm.loadavg 2>/dev/null)" || return
  load=${${(A)=load}[_POWERLEVEL9K_LOAD_WHICH+1]//,/.}
  [[ $load == <->(|.<->) && $load != $_p9k__load_value ]] || return
  _p9k__load_value=$load
  _p9k__load_normal=
  _p9k__load_warning=
  _p9k__load_critical=
  local -F pct='100. * _p9k__load_value / _p9k_num_cpus'
  if (( pct > _POWERLEVEL9K_LOAD_CRITICAL_PCT )); then
    _p9k__load_critical=1
  elif (( pct > _POWERLEVEL9K_LOAD_WARNING_PCT )); then
    _p9k__load_warning=1
  else
    _p9k__load_normal=1
  fi
  _p9k_print_params     \
    _p9k__load_value    \
    _p9k__load_normal   \
    _p9k__load_warning  \
    _p9k__load_critical
  echo -E - 'reset=1'
}

_p9k_prompt_load_sync() {
  eval $REPLY
  _p9k_worker_reply $REPLY
}

# Usage: _p9k_cached_cmd <0|1> <dep> <cmd> [args...]
#
# The first argument says whether to capture stderr (1) or ignore it (0).
# The second argument can be empty or a file. If it's a file, the
# output of the command is presumed to potentially depend on it.
function _p9k_cached_cmd() {
  local cmd=$commands[$3]
  [[ -n $cmd ]] || return
  if ! _p9k_cache_stat_get $0" ${(q)*}" $2 $cmd; then
    local out
    if (( $1 )); then
      out="$($cmd "${@:4}" 2>&1)"
    else
      out="$($cmd "${@:4}" 2>/dev/null)"
    fi
    _p9k_cache_stat_set $(( ! $? )) "$out"
  fi
  (( $_p9k__cache_val[1] )) || return
  _p9k__ret=$_p9k__cache_val[2]
}

################################################################
# Segment to diplay Node version
prompt_node_version() {
  _p9k_upglob package.json
  local -i idx=$?
  if (( idx )); then
    _p9k_cached_cmd 0 $_p9k__parent_dirs[idx]/package.json node --version || return
  else
    (( _POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY )) && return
    _p9k_cached_cmd 0 '' node --version || return
  fi
  [[ $_p9k__ret == v?* ]] || return
  _p9k_prompt_segment "$0" "green" "white" 'NODE_ICON' 0 '' "${_p9k__ret#v}"
}

_p9k_prompt_node_version_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[node]'
}

# Almost the same as `nvm_version default` but faster. The differences shouldn't affect
# the observable behavior of Powerlevel10k.
function _p9k_nvm_ls_default() {
  local v=default
  local -a seen=($v)
  while [[ -r $NVM_DIR/alias/$v ]]; do
    local target=
    IFS='' read -r target <$NVM_DIR/alias/$v
    target=${target%$'\r'}
    [[ -z $target ]] && break
    (( $seen[(I)$target] )) && return
    seen+=$target
    v=$target
  done

  case $v in
    default|N/A)
      return 1
    ;;
    system|v)
      _p9k__ret=system
      return 0
    ;;
    iojs-[0-9]*)
      v=iojs-v${v#iojs-}
    ;;
    [0-9]*)
      v=v$v
    ;;
  esac

  if [[ $v == v*.*.* ]]; then
    if [[ -x $NVM_DIR/versions/node/$v/bin/node || -x $NVM_DIR/$v/bin/node ]]; then
      _p9k__ret=$v
      return 0
    elif [[ -x $NVM_DIR/versions/io.js/$v/bin/node ]]; then
      _p9k__ret=iojs-$v
      return 0
    else
      return 1
    fi
  fi

  local -a dirs=()
  case $v in
    node|node-|stable)
      dirs=($NVM_DIR/versions/node $NVM_DIR)
      v='(v[1-9]*|v0.*[02468].*)'
    ;;
    unstable)
      dirs=($NVM_DIR/versions/node $NVM_DIR)
      v='v0.*[13579].*'
    ;;
    iojs*)
      dirs=($NVM_DIR/versions/io.js)
      v=v${${${v#iojs}#-}#v}'*'
    ;;
    *)
      dirs=($NVM_DIR/versions/node $NVM_DIR $NVM_DIR/versions/io.js)
      v=v${v#v}'*'
    ;;
  esac

  local -a matches=(${^dirs}/${~v}(/N))
  (( $#matches )) || return

  local max path
  for path in ${(Oa)matches}; do
    [[ ${path:t} == (#b)v(*).(*).(*) ]] || continue
    v=${(j::)${(@l:6::0:)match}}
    [[ $v > $max ]] || continue
    max=$v
    _p9k__ret=${path:t}
    [[ ${path:h:t} != io.js ]] || _p9k__ret=iojs-$_p9k__ret
  done

  [[ -n $max ]]
}

# The same as `nvm_version current` but faster.
_p9k_nvm_ls_current() {
  local node_path=${commands[node]:A}
  [[ -n $node_path ]] || return

  local nvm_dir=${NVM_DIR:A}
  if [[ -n $nvm_dir && $node_path == $nvm_dir/versions/io.js/* ]]; then
    _p9k_cached_cmd 0 '' iojs --version || return
    _p9k__ret=iojs-v${_p9k__ret#v}
  elif [[ -n $nvm_dir && $node_path == $nvm_dir/* ]]; then
    _p9k_cached_cmd 0 '' node --version || return
    _p9k__ret=v${_p9k__ret#v}
  else
    _p9k__ret=system
  fi
}

################################################################
# Segment to display Node version from NVM
# Only prints the segment if different than the default value
prompt_nvm() {
  [[ -n $NVM_DIR ]] && _p9k_nvm_ls_current || return
  local current=$_p9k__ret
  ! _p9k_nvm_ls_default || [[ $_p9k__ret != $current ]] || return
  _p9k_prompt_segment "$0" "magenta" "black" 'NODE_ICON' 0 '' "${${current#v}//\%/%%}"
}

_p9k_prompt_nvm_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[nvm]:-${${+functions[nvm]}:#0}}'
}

################################################################
# Segment to display NodeEnv
prompt_nodeenv() {
  local msg
  if (( _POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION )) && _p9k_cached_cmd 0 '' node --version; then
    msg="${_p9k__ret//\%/%%} "
  fi
  msg+="$_POWERLEVEL9K_NODEENV_LEFT_DELIMITER${${NODE_VIRTUAL_ENV:t}//\%/%%}$_POWERLEVEL9K_NODEENV_RIGHT_DELIMITER"
  _p9k_prompt_segment "$0" "black" "green" 'NODE_ICON' 0 '' "$msg"
}

_p9k_prompt_nodeenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$NODE_VIRTUAL_ENV'
}

function _p9k_nodeenv_version_transform() {
  local dir=${NODENV_ROOT:-$HOME/.nodenv}/versions
  [[ -z $1 || $1 == system ]] && _p9k__ret=$1          && return
  [[ -d $dir/$1 ]]            && _p9k__ret=$1          && return
  [[ -d $dir/${1/v} ]]        && _p9k__ret=${1/v}      && return
  [[ -d $dir/${1#node-} ]]    && _p9k__ret=${1#node-}  && return
  [[ -d $dir/${1#node-v} ]]   && _p9k__ret=${1#node-v} && return
  return 1
}

function _p9k_nodenv_global_version() {
  _p9k_read_word ${NODENV_ROOT:-$HOME/.nodenv}/version || _p9k__ret=system
}

################################################################
# Segment to display nodenv information
# https://github.com/nodenv/nodenv
prompt_nodenv() {
  if [[ -n $NODENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_NODENV_SOURCES[(I)shell]} )) || return
    local v=$NODENV_VERSION
  else
    (( ${_POWERLEVEL9K_NODENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $NODENV_DIR != (|.) ]]; then
      [[ $NODENV_DIR == /* ]] && local dir=$NODENV_DIR || local dir="$_p9k__cwd_a/$NODENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.node-version; then
            (( ${_POWERLEVEL9K_NODENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .node-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.node-version; then
        (( ${_POWERLEVEL9K_NODENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_NODENV_SOURCES[(I)global]} )) || return
      _p9k_nodenv_global_version
    fi

    _p9k_nodeenv_version_transform $_p9k__ret || return
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_nodenv_global_version
    _p9k_nodeenv_version_transform $_p9k__ret && [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_NODENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" "black" "green" 'NODE_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_nodenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[nodenv]:-${${+functions[nodenv]}:#0}}'
}

prompt_dotnet_version() {
  if (( _POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY )); then
    _p9k_upglob 'project.json|global.json|packet.dependencies|*.csproj|*.fsproj|*.xproj|*.sln' && return
  fi
  _p9k_cached_cmd 0 '' dotnet --version || return
  _p9k_prompt_segment "$0" "magenta" "white" 'DOTNET_ICON' 0 '' "$_p9k__ret"
}

_p9k_prompt_dotnet_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[dotnet]'
}

################################################################
# Segment to print a little OS icon
prompt_os_icon() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment "$0" "black" "white" '' 0 '' "$_p9k_os_icon"
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

instant_prompt_os_icon() { prompt_os_icon; }

################################################################
# Segment to display PHP version number
prompt_php_version() {
  if (( _POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY )); then
    _p9k_upglob 'composer.json|*.php' && return
  fi
  _p9k_cached_cmd 0 '' php --version || return
  [[ $_p9k__ret == (#b)(*$'\n')#'PHP '([[:digit:].]##)* ]] || return
  local v=$match[2]
  _p9k_prompt_segment "$0" "fuchsia" "grey93" 'PHP_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_php_version_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[php]'
}

################################################################
# Segment to display free RAM and used Swap
prompt_ram() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment $0 yellow "$_p9k_color1" RAM_ICON 1 '$_p9k__ram_free' '$_p9k__ram_free'
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

function _p9k_prompt_ram_init() {
  if [[ $_p9k_os == OSX && $+commands[vm_stat] == 0 ||
        $_p9k_os == BSD && ! -r /var/run/dmesg.boot ||
        $_p9k_os != (OSX|BSD) && ! -r /proc/meminfo ]]; then
    typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
    return
  fi
  typeset -g _p9k__ram_free=
  _p9k__async_segments_compute+='_p9k_worker_invoke ram _p9k_prompt_ram_compute'
}

_p9k_prompt_ram_compute() {
  _p9k_worker_async _p9k_prompt_ram_async _p9k_prompt_ram_sync
}

_p9k_prompt_ram_async() {
  local -F free_bytes

  case $_p9k_os in
    OSX)
      (( $+commands[vm_stat] )) || return
      local stat && stat="$(vm_stat 2>/dev/null)" || return
      [[ $stat =~ 'Pages free:[[:space:]]+([0-9]+)' ]] || return
      (( free_bytes += match[1] ))
      [[ $stat =~ 'Pages inactive:[[:space:]]+([0-9]+)' ]] || return
      (( free_bytes += match[1] ))
      if (( ! $+_p9k__ram_pagesize )); then
        local p
        (( $+commands[pagesize] )) && p=$(pagesize 2>/dev/null) && [[ $p == <1-> ]] || p=4096
        typeset -gi _p9k__ram_pagesize=p
        _p9k_print_params _p9k__ram_pagesize
      fi
      (( free_bytes *= _p9k__ram_pagesize ))
    ;;
    BSD)
      local stat && stat="$(grep -F 'avail memory' /var/run/dmesg.boot 2>/dev/null)" || return
      free_bytes=${${(A)=stat}[4]}
    ;;
    *)
      [[ -r /proc/meminfo ]] || return
      local stat && stat="$(</proc/meminfo)" || return
      [[ $stat == (#b)*(MemAvailable:|MemFree:)[[:space:]]#(<->)* ]] || return
      free_bytes=$(( $match[2] * 1024 ))
    ;;
  esac

  _p9k_human_readable_bytes $free_bytes
  [[ $_p9k__ret != $_p9k__ram_free ]] || return
  _p9k__ram_free=$_p9k__ret
  _p9k_print_params _p9k__ram_free
  echo -E - 'reset=1'
}

_p9k_prompt_ram_sync() {
  eval $REPLY
  _p9k_worker_reply $REPLY
}

function _p9k_rbenv_global_version() {
  _p9k_read_word ${RBENV_ROOT:-$HOME/.rbenv}/version || _p9k__ret=system
}

################################################################
# Segment to display rbenv information
# https://github.com/rbenv/rbenv#choosing-the-ruby-version
prompt_rbenv() {
  if [[ -n $RBENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)shell]} )) || return
    local v=$RBENV_VERSION
  else
    (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $RBENV_DIR != (|.) ]]; then
      [[ $RBENV_DIR == /* ]] && local dir=$RBENV_DIR || local dir="$_p9k__cwd_a/$RBENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.ruby-version; then
            (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .ruby-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.ruby-version; then
        (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)global]} )) || return
      _p9k_rbenv_global_version
    fi
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_rbenv_global_version
    [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_RBENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" "red" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_rbenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[rbenv]:-${${+functions[rbenv]}:#0}}'
}

function _p9k_phpenv_global_version() {
  _p9k_read_word ${PHPENV_ROOT:-$HOME/.phpenv}/version || _p9k__ret=system
}

function _p9k_scalaenv_global_version() {
  _p9k_read_word ${SCALAENV_ROOT:-$HOME/.scalaenv}/version || _p9k__ret=system
}

# https://github.com/scalaenv/scalaenv
prompt_scalaenv() {
  if [[ -n $SCALAENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)shell]} )) || return
    local v=$SCALAENV_VERSION
  else
    (( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $SCALAENV_DIR != (|.) ]]; then
      [[ $SCALAENV_DIR == /* ]] && local dir=$SCALAENV_DIR || local dir="$_p9k__cwd_a/$SCALAENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.scala-version; then
            (( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .scala-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.scala-version; then
        (( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)global]} )) || return
      _p9k_scalaenv_global_version
    fi
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_scalaenv_global_version
    [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_SCALAENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" "red" "$_p9k_color1" 'SCALA_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_scalaenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[scalaenv]:-${${+functions[scalaenv]}:#0}}'
}

function _p9k_phpenv_global_version() {
  _p9k_read_word ${PHPENV_ROOT:-$HOME/.phpenv}/version || _p9k__ret=system
}

prompt_phpenv() {
  if [[ -n $PHPENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)shell]} )) || return
    local v=$PHPENV_VERSION
  else
    (( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $PHPENV_DIR != (|.) ]]; then
      [[ $PHPENV_DIR == /* ]] && local dir=$PHPENV_DIR || local dir="$_p9k__cwd_a/$PHPENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.php-version; then
            (( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .php-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.php-version; then
        (( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)global]} )) || return
      _p9k_phpenv_global_version
    fi
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_phpenv_global_version
    [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_PHPENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" "magenta" "$_p9k_color1" 'PHP_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_phpenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[phpenv]:-${${+functions[phpenv]}:#0}}'
}

function _p9k_luaenv_global_version() {
  _p9k_read_word ${LUAENV_ROOT:-$HOME/.luaenv}/version || _p9k__ret=system
}

################################################################
# Segment to display luaenv information
# https://github.com/cehoffman/luaenv
prompt_luaenv() {
  if [[ -n $LUAENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)shell]} )) || return
    local v=$LUAENV_VERSION
  else
    (( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $LUAENV_DIR != (|.) ]]; then
      [[ $LUAENV_DIR == /* ]] && local dir=$LUAENV_DIR || local dir="$_p9k__cwd_a/$LUAENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.lua-version; then
            (( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .lua-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.lua-version; then
        (( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)global]} )) || return
      _p9k_luaenv_global_version
    fi
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_luaenv_global_version
    [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_LUAENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" blue "$_p9k_color1" 'LUA_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_luaenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[luaenv]:-${${+functions[luaenv]}:#0}}'
}

function _p9k_jenv_global_version() {
  _p9k_read_word ${JENV_ROOT:-$HOME/.jenv}/version || _p9k__ret=system
}

################################################################
# Segment to display jenv information
# https://github.com/jenv/jenv
prompt_jenv() {
  if [[ -n $JENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_JENV_SOURCES[(I)shell]} )) || return
    local v=$JENV_VERSION
  else
    (( ${_POWERLEVEL9K_JENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $JENV_DIR != (|.) ]]; then
      [[ $JENV_DIR == /* ]] && local dir=$JENV_DIR || local dir="$_p9k__cwd_a/$JENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.java-version; then
            (( ${_POWERLEVEL9K_JENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .java-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.java-version; then
        (( ${_POWERLEVEL9K_JENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_JENV_SOURCES[(I)global]} )) || return
      _p9k_jenv_global_version
    fi
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_jenv_global_version
    [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_JENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" white red 'JAVA_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_jenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[jenv]:-${${+functions[jenv]}:#0}}'
}

function _p9k_plenv_global_version() {
  _p9k_read_word ${PLENV_ROOT:-$HOME/.plenv}/version || _p9k__ret=system
}

################################################################
# Segment to display plenv information
# https://github.com/plenv/plenv#choosing-the-perl-version
prompt_plenv() {
  if [[ -n $PLENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_PLENV_SOURCES[(I)shell]} )) || return
    local v=$PLENV_VERSION
  else
    (( ${_POWERLEVEL9K_PLENV_SOURCES[(I)local|global]} )) || return
    _p9k__ret=
    if [[ $PLENV_DIR != (|.) ]]; then
      [[ $PLENV_DIR == /* ]] && local dir=$PLENV_DIR || local dir="$_p9k__cwd_a/$PLENV_DIR"
      dir=${dir:A}
      if [[ $dir != $_p9k__cwd_a ]]; then
        while true; do
          if _p9k_read_word $dir/.perl-version; then
            (( ${_POWERLEVEL9K_PLENV_SOURCES[(I)local]} )) || return
            break
          fi
          [[ $dir == (/|.) ]] && break
          dir=${dir:h}
        done
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      _p9k_upglob .perl-version
      local -i idx=$?
      if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.perl-version; then
        (( ${_POWERLEVEL9K_PLENV_SOURCES[(I)local]} )) || return
      else
        _p9k__ret=
      fi
    fi
    if [[ -z $_p9k__ret ]]; then
      (( _POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW )) || return
      (( ${_POWERLEVEL9K_PLENV_SOURCES[(I)global]} )) || return
      _p9k_plenv_global_version
    fi
    local v=$_p9k__ret
  fi

  if (( !_POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_plenv_global_version
    [[ $v == $_p9k__ret ]] && return
  fi

  if (( !_POWERLEVEL9K_PLENV_SHOW_SYSTEM )); then
    [[ $v == system ]] && return
  fi

  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PERL_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_plenv_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[plenv]:-${${+functions[plenv]}:#0}}'
}

################################################################
# Segment to display perlbrew information
# https://github.com/gugod/App-perlbrew

prompt_perlbrew() {
  if (( _POWERLEVEL9K_PERLBREW_PROJECT_ONLY )); then
    _p9k_upglob 'cpanfile|.perltidyrc|(|MY)META.(yml|json)|(Makefile|Build).PL|*.(pl|pm|t|pod)' && return
  fi

  local v=$PERLBREW_PERL
  (( _POWERLEVEL9K_PERLBREW_SHOW_PREFIX )) || v=${v#*-}
  [[ -n $v ]] || return
  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PERL_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_perlbrew_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$PERLBREW_PERL'
}

################################################################
# Segment to display chruby information
# see https://github.com/postmodern/chruby/issues/245 for chruby_auto issue with ZSH
prompt_chruby() {
  local v
  (( _POWERLEVEL9K_CHRUBY_SHOW_ENGINE )) && v=$RUBY_ENGINE
  if [[ $_POWERLEVEL9K_CHRUBY_SHOW_VERSION == 1 && -n $RUBY_VERSION ]] && v+=${v:+ }$RUBY_VERSION
  _p9k_prompt_segment "$0" "red" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_chruby_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$RUBY_ENGINE'
}

################################################################
# Segment to print an icon if user is root.
prompt_root_indicator() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment "$0" "$_p9k_color1" "yellow" 'ROOT_ICON' 0 '${${(%):-%#}:#\%}' ''
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

instant_prompt_root_indicator() { prompt_root_indicator; }

################################################################
# Segment to display Rust version number
prompt_rust_version() {
  unset P9K_RUST_VERSION
  if (( _POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY )); then
    _p9k_upglob Cargo.toml && return
  fi
  local rustc=$commands[rustc] toolchain deps=()
  if (( $+commands[ldd] )); then
    if ! _p9k_cache_stat_get $0_so $rustc; then
      local line so
      for line in "${(@f)$(ldd $rustc 2>/dev/null)}"; do
        [[ $line == (#b)[[:space:]]#librustc_driver[^[:space:]]#.so' => '(*)' (0x'[[:xdigit:]]#')' ]] || continue
        so=$match[1]
        break
      done
      _p9k_cache_stat_set "$so"
    fi
    deps+=$_p9k__cache_val[1]
  fi
  if (( $+commands[rustup] )); then
    local rustup=$commands[rustup]
    local rustup_home=${RUSTUP_HOME:-~/.rustup}
    local cfg=($rustup_home/settings.toml(.N))
    deps+=($cfg $rustup_home/update-hashes/*(.N))
    if [[ -z ${toolchain::=$RUSTUP_TOOLCHAIN} ]]; then
      if ! _p9k_cache_stat_get $0_overrides $rustup $cfg; then
        local lines=(${(f)"$(rustup override list 2>/dev/null)"})
        if [[ $lines[1] == "no overrides" ]]; then
          _p9k_cache_stat_set
        else
          local MATCH
          local keys=(${(@)${lines%%[[:space:]]#[^[:space:]]#}/(#m)*/${(b)MATCH}/})
          local vals=(${(@)lines/(#m)*/$MATCH[(I)/] ${MATCH##*[[:space:]]}})
          _p9k_cache_stat_set ${keys:^vals}
        fi
      fi
      local -A overrides=($_p9k__cache_val)
      _p9k_upglob rust-toolchain
      local dir=$_p9k__parent_dirs[$?]
      local -i n m=${dir[(I)/]}
      local pair
      for pair in ${overrides[(K)$_p9k__cwd/]}; do
        n=${pair%% *}
        (( n <= m )) && continue
        m=n
        toolchain=${pair#* }
      done
      if [[ -z $toolchain && -n $dir ]]; then
        _p9k_read_word $dir/rust-toolchain
        toolchain=$_p9k__ret
      fi
    fi
  fi
  if ! _p9k_cache_stat_get $0_v$toolchain $rustc $deps; then
    _p9k_cache_stat_set "$($rustc --version 2>/dev/null)"
  fi
  local v=${${_p9k__cache_val[1]#rustc }%% *}
  [[ -n $v ]] || return
  typeset -g P9K_RUST_VERSION=$_p9k__cache_val[1]
  _p9k_prompt_segment "$0" "darkorange" "$_p9k_color1" 'RUST_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_rust_version_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$commands[rustc]'
}

# RSpec test ratio
prompt_rspec_stats() {
  if [[ -d app && -d spec ]]; then
    local -a code=(app/**/*.rb(N))
    (( $#code )) || return
    local tests=(spec/**/*.rb(N))
    _p9k_build_test_stats "$0" "$#code" "$#tests" "RSpec" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Ruby Version Manager information
prompt_rvm() {
  [[ $GEM_HOME == *rvm* && $ruby_string != $rvm_path/bin/ruby ]] || return
  local v=${GEM_HOME:t}
  (( _POWERLEVEL9K_RVM_SHOW_GEMSET )) || v=${v%%${rvm_gemset_separator:-@}*}
  (( _POWERLEVEL9K_RVM_SHOW_PREFIX )) || v=${v#*-}
  [[ -n $v ]] || return
  _p9k_prompt_segment "$0" "240" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}

_p9k_prompt_rvm_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${commands[rvm-prompt]:-${${+functions[rvm-prompt]}:#0}}'
}

################################################################
# Segment to display SSH icon when connected
prompt_ssh() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment "$0" "$_p9k_color1" "yellow" 'SSH_ICON' 0 '' ''
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

_p9k_prompt_ssh_init() {
  if (( ! P9K_SSH )); then
    typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
  fi
}

instant_prompt_ssh() {
  if (( ! P9K_SSH )); then
    return
  fi
  prompt_ssh
}

################################################################
# Status: When an error occur, return the error code, or a cross icon if option is set
# Display an ok icon when no error occur, or hide the segment if option is set to false
prompt_status() {
  if ! _p9k_cache_get $0 $_p9k__status $_p9k__pipestatus; then
    (( _p9k__status )) && local state=ERROR || local state=OK
    if (( _POWERLEVEL9K_STATUS_EXTENDED_STATES )); then
      if (( _p9k__status )); then
        if (( $#_p9k__pipestatus > 1 )); then
          state+=_PIPE
        elif (( _p9k__status > 128 )); then
          state+=_SIGNAL
        fi
      elif [[ "$_p9k__pipestatus" == *[1-9]* ]]; then
        state+=_PIPE
      fi
    fi
    _p9k__cache_val=(:)
    if (( _POWERLEVEL9K_STATUS_$state )); then
      if (( _POWERLEVEL9K_STATUS_SHOW_PIPESTATUS )); then
        local text=${(j:|:)${(@)_p9k__pipestatus:/(#b)(*)/$_p9k_exitcode2str[$match[1]+1]}}
      else
        local text=$_p9k_exitcode2str[_p9k__status+1]
      fi
      if (( _p9k__status )); then
        if (( !_POWERLEVEL9K_STATUS_CROSS && _POWERLEVEL9K_STATUS_VERBOSE )); then
          _p9k__cache_val=($0_$state red yellow1 CARRIAGE_RETURN_ICON 0 '' "$text")
        else
          _p9k__cache_val=($0_$state $_p9k_color1 red FAIL_ICON 0 '' '')
        fi
      elif (( _POWERLEVEL9K_STATUS_VERBOSE || _POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE )); then
        [[ $state == OK ]] && text=''
        _p9k__cache_val=($0_$state "$_p9k_color1" green OK_ICON 0 '' "$text")
      fi
    fi
    if (( $#_p9k__pipestatus < 3 )); then
      _p9k_cache_set "${(@)_p9k__cache_val}"
    fi
  fi
  _p9k_prompt_segment "${(@)_p9k__cache_val}"
}

instant_prompt_status() {
  if (( _POWERLEVEL9K_STATUS_OK )); then
    _p9k_prompt_segment prompt_status_OK "$_p9k_color1" green OK_ICON 0 '' ''
  fi
}

prompt_prompt_char() {
  local saved=$_p9k__prompt_char_saved[$_p9k__prompt_side$_p9k__segment_index$((!_p9k__status))]
  if [[ -n $saved ]]; then
    _p9k__prompt+=$saved
    return
  fi
  local -i len=$#_p9k__prompt _p9k__has_upglob
  if (( __p9k_sh_glob )); then
    if (( _p9k__status )); then
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' 'o'
        _p9k_prompt_segment $0_ERROR_VIOWR "$_p9k_color1" 196 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' '�'
      else
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' 'o'
      fi
      _p9k_prompt_segment $0_ERROR_VICMD "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' 'n'
      _p9k_prompt_segment $0_ERROR_VIVIS "$_p9k_color1" 196 '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' 'd'
    else
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' 'o'
        _p9k_prompt_segment $0_OK_VIOWR "$_p9k_color1" 76 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' '�'
      else
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' 'o'
      fi
      _p9k_prompt_segment $0_OK_VICMD "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' 'n'
      _p9k_prompt_segment $0_OK_VIVIS "$_p9k_color1" 76 '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' 'd'
    fi
  else
    if (( _p9k__status )); then
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' 'o'
        _p9k_prompt_segment $0_ERROR_VIOWR "$_p9k_color1" 196 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' '�'
      else
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' 'o'
      fi
      _p9k_prompt_segment $0_ERROR_VICMD "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' 'n'
      _p9k_prompt_segment $0_ERROR_VIVIS "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' 'd'
    else
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' 'o'
        _p9k_prompt_segment $0_OK_VIOWR "$_p9k_color1" 76 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' '�'
      else
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' 'o'
      fi
      _p9k_prompt_segment $0_OK_VICMD "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' 'n'
      _p9k_prompt_segment $0_OK_VIVIS "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' 'd'
    fi
  fi
  (( _p9k__has_upglob )) || _p9k__prompt_char_saved[$_p9k__prompt_side$_p9k__segment_index$((!_p9k__status))]=$_p9k__prompt[len+1,-1]
}

instant_prompt_prompt_char() {
  _p9k_prompt_segment prompt_prompt_char_OK_VIINS "$_p9k_color1" 76 '' 0 '' 'o'
}

################################################################
# Segment to display Swap information
prompt_swap() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment $0 yellow "$_p9k_color1" SWAP_ICON 1 '$_p9k__swap_used' '$_p9k__swap_used'
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

function _p9k_prompt_swap_init() {
  if [[ $_p9k_os == OSX && $+commands[sysctl] == 0 || $_p9k_os != OSX && ! -r /proc/meminfo ]]; then
    typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='${:-}'
    return
  fi
  typeset -g _p9k__swap_used=
  _p9k__async_segments_compute+='_p9k_worker_invoke swap _p9k_prompt_swap_compute'
}

_p9k_prompt_swap_compute() {
  _p9k_worker_async _p9k_prompt_swap_async _p9k_prompt_swap_sync
}

_p9k_prompt_swap_async() {
  local -F used_bytes

  if [[ "$_p9k_os" == "OSX" ]]; then
    (( $+commands[sysctl] )) || return
    [[ "$(sysctl vm.swapusage 2>/dev/null)" =~ "used = ([0-9,.]+)([A-Z]+)" ]] || return
    used_bytes=${match[1]//,/.}
    case ${match[2]} in
      'K') (( used_bytes *= 1024 ));;
      'M') (( used_bytes *= 1048576 ));;
      'G') (( used_bytes *= 1073741824 ));;
      'T') (( used_bytes *= 1099511627776 ));;
      *) return 0;;
    esac
  else
    local meminfo && meminfo="$(grep -F 'Swap' /proc/meminfo 2>/dev/null)" || return
    [[ $meminfo =~ 'SwapTotal:[[:space:]]+([0-9]+)' ]] || return
    (( used_bytes+=match[1] ))
    [[ $meminfo =~ 'SwapFree:[[:space:]]+([0-9]+)' ]] || return
    (( used_bytes-=match[1] ))
    (( used_bytes *= 1024 ))
  fi

  (( used_bytes >= 0 || (used_bytes = 0) ))

  _p9k_human_readable_bytes $used_bytes
  [[ $_p9k__ret != $_p9k__swap_used ]] || return
  _p9k__swap_used=$_p9k__ret
  _p9k_print_params _p9k__swap_used
  echo -E - 'reset=1'
}

_p9k_prompt_swap_sync() {
  eval $REPLY
  _p9k_worker_reply $REPLY
}

################################################################
# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ -d src && -d app && -f app/AppKernel.php ]]; then
    local -a all=(src/**/*.php(N))
    local -a code=(${(@)all##*Tests*})
    (( $#code )) || return
    _p9k_build_test_stats "$0" "$#code" "$(($#all - $#code))" "SF2" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Symfony2-Version
prompt_symfony2_version() {
  if [[ -r app/bootstrap.php.cache ]]; then
    local v="${$(grep -F " VERSION " app/bootstrap.php.cache 2>/dev/null)//[![:digit:].]}"
    _p9k_prompt_segment "$0" "grey35" "$_p9k_color1" 'SYMFONY_ICON' 0 '' "${v//\%/%%}"
  fi
}

################################################################
# Show a ratio of tests vs code
_p9k_build_test_stats() {
  local code_amount="$2"
  local tests_amount="$3"
  local headline="$4"

  (( code_amount > 0 )) || return
  local -F 2 ratio=$(( 100. * tests_amount / code_amount ))

  (( ratio >= 75 )) && _p9k_prompt_segment "${1}_GOOD" "cyan" "$_p9k_color1" "$5" 0 '' "$headline: $ratio%%"
  (( ratio >= 50 && ratio < 75 )) && _p9k_prompt_segment "$1_AVG" "yellow" "$_p9k_color1" "$5" 0 '' "$headline: $ratio%%"
  (( ratio < 50 )) && _p9k_prompt_segment "$1_BAD" "red" "$_p9k_color1" "$5" 0 '' "$headline: $ratio%%"
}

################################################################
# System time
prompt_time() {
  if (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )); then
    _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 0 '' "$_POWERLEVEL9K_TIME_FORMAT"
  else
    if [[ $_p9k__refresh_reason == precmd ]]; then
      if [[ $+__p9k_instant_prompt_active == 1 && $__p9k_instant_prompt_time_format == $_POWERLEVEL9K_TIME_FORMAT ]]; then
        _p9k__time=${__p9k_instant_prompt_time//\%/%%}
      else
        _p9k__time=${${(%)_POWERLEVEL9K_TIME_FORMAT}//\%/%%}
      fi
    fi
    if (( _POWERLEVEL9K_TIME_UPDATE_ON_COMMAND )); then
      _p9k_escape $_p9k__time
      local t=$_p9k__ret
      _p9k_escape $_POWERLEVEL9K_TIME_FORMAT
      _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 1 '' \
          "\${_p9k__line_finished-$t}\${_p9k__line_finished+$_p9k__ret}"
    else
      _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 0 '' $_p9k__time
    fi
  fi
}

instant_prompt_time() {
  _p9k_escape $_POWERLEVEL9K_TIME_FORMAT
  local stash='${${__p9k_instant_prompt_time::=${(%)${__p9k_instant_prompt_time_format::='$_p9k__ret'}}}+}'
  _p9k_escape $_POWERLEVEL9K_TIME_FORMAT
  _p9k_prompt_segment prompt_time "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 1 '' $stash$_p9k__ret
}

_p9k_prompt_time_init() {
  (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )) || return
  _p9k__async_segments_compute+='_p9k_worker_invoke time _p9k_prompt_time_compute'
}

_p9k_prompt_time_compute() {
  _p9k_worker_async _p9k_prompt_time_async _p9k_prompt_time_sync
}

_p9k_prompt_time_async() {
  sleep 1 || true
}

_p9k_prompt_time_sync() {
  _p9k_worker_reply '_p9k_worker_invoke _p9k_prompt_time_compute _p9k_prompt_time_compute; reset=1'
}

################################################################
# System date
prompt_date() {
  if [[ $_p9k__refresh_reason == precmd ]]; then
    if [[ $+__p9k_instant_prompt_active == 1 && $__p9k_instant_prompt_date_format == $_POWERLEVEL9K_DATE_FORMAT ]]; then
      _p9k__date=${__p9k_instant_prompt_date//\%/%%}
    else
      _p9k__date=${${(%)_POWERLEVEL9K_DATE_FORMAT}//\%/%%}
    fi
  fi
  _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "DATE_ICON" 0 '' "$_p9k__date"
}

instant_prompt_date() {
  _p9k_escape $_POWERLEVEL9K_DATE_FORMAT
  local stash='${${__p9k_instant_prompt_date::=${(%)${__p9k_instant_prompt_date_format::='$_p9k__ret'}}}+}'
  _p9k_escape $_POWERLEVEL9K_DATE_FORMAT
  _p9k_prompt_segment prompt_date "$_p9k_color2" "$_p9k_color1" "DATE_ICON" 1 '' $stash$_p9k__ret
}

################################################################
# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  unset P9K_TODO_TOTAL_TASK_COUNT P9K_TODO_FILTERED_TASK_COUNT
  [[ -r $_p9k__todo_file && -x $_p9k__todo_command ]] || return
  if ! _p9k_cache_stat_get $0 $_p9k__todo_file; then
    local count="$($_p9k__todo_command -p ls | command tail -1)"
    if [[ $count == (#b)'TODO: '([[:digit:]]##)' of '([[:digit:]]##)' '* ]]; then
      _p9k_cache_stat_set 1 $match[1] $match[2]
    else
      _p9k_cache_stat_set 0
    fi
  fi
  (( $_p9k__cache_val[1] )) || return
  typeset -gi P9K_TODO_FILTERED_TASK_COUNT=$_p9k__cache_val[2]
  typeset -gi P9K_TODO_TOTAL_TASK_COUNT=$_p9k__cache_val[3]
  if (( (P9K_TODO_TOTAL_TASK_COUNT    || !_POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL) &&
        (P9K_TODO_FILTERED_TASK_COUNT || !_POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED) )); then
    if (( P9K_TODO_TOTAL_TASK_COUNT == P9K_TODO_FILTERED_TASK_COUNT )); then
      local text=$P9K_TODO_TOTAL_TASK_COUNT
    else
      local text="$P9K_TODO_FILTERED_TASK_COUNT/$P9K_TODO_TOTAL_TASK_COUNT"
    fi
    _p9k_prompt_segment "$0" "grey50" "$_p9k_color1" 'TODO_ICON' 0 '' "$text"
  fi
}

_p9k_prompt_todo_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$_p9k__todo_file'
}

################################################################
# VCS segment: shows the state of your repository, if you are in a folder under
# version control

# The vcs segment can have 4 different states - defaults to 'CLEAN'.
typeset -gA __p9k_vcs_states=(
  'CLEAN'         '2'
  'MODIFIED'      '3'
  'UNTRACKED'     '2'
  'LOADING'       '8'
  'CONFLICTED'    '3'
)

function +vi-git-untracked() {
  [[ -z "${vcs_comm[gitdir]}" || "${vcs_comm[gitdir]}" == "." ]] && return

  # get the root for the current repo or submodule
  local repoTopLevel="$(git rev-parse --show-toplevel 2> /dev/null)"
  # dump out if we're outside a git repository (which includes being in the .git folder)
  [[ $? != 0 || -z $repoTopLevel ]] && return

  local untrackedFiles="$(git ls-files --others --exclude-standard "${repoTopLevel}" 2> /dev/null)"

  if [[ -z $untrackedFiles && $_POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY == 1 ]]; then
    untrackedFiles+="$(git submodule foreach --quiet --recursive 'git ls-files --others --exclude-standard' 2> /dev/null)"
  fi

  [[ -z $untrackedFiles ]] && return

  hook_com[unstaged]+=" $(print_icon 'VCS_UNTRACKED_ICON')"
  VCS_WORKDIR_HALF_DIRTY=true
}

function +vi-git-aheadbehind() {
  local ahead behind
  local -a gitstatus

  # for git prior to 1.7
  # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
  ahead="$(git rev-list --count "${hook_com[branch]}"@{upstream}..HEAD 2>/dev/null)"
  (( ahead )) && gitstatus+=( " $(print_icon 'VCS_OUTGOING_CHANGES_ICON')${ahead// /}" )

  # for git prior to 1.7
  # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
  behind="$(git rev-list --count HEAD.."${hook_com[branch]}"@{upstream} 2>/dev/null)"
  (( behind )) && gitstatus+=( " $(print_icon 'VCS_INCOMING_CHANGES_ICON')${behind// /}" )

  hook_com[misc]+=${(j::)gitstatus}
}

function +vi-git-remotebranch() {
  local remote
  local branch_name="${hook_com[branch]}"

  # Are we on a remote-tracking branch?
  remote="$(git rev-parse --verify HEAD@{upstream} --symbolic-full-name 2>/dev/null)"
  remote=${remote/refs\/(remotes|heads)\/}

  if (( $+_POWERLEVEL9K_VCS_SHORTEN_LENGTH && $+_POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH )); then
    if (( ${#hook_com[branch]} > _POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH && ${#hook_com[branch]} > _POWERLEVEL9K_VCS_SHORTEN_LENGTH )); then
      case $_POWERLEVEL9K_VCS_SHORTEN_STRATEGY in
        truncate_middle)
          hook_com[branch]="${branch_name:0:$_POWERLEVEL9K_VCS_SHORTEN_LENGTH}${_POWERLEVEL9K_VCS_SHORTEN_DELIMITER}${branch_name: -$_POWERLEVEL9K_VCS_SHORTEN_LENGTH}"
        ;;
        truncate_from_right)
          hook_com[branch]="${branch_name:0:$_POWERLEVEL9K_VCS_SHORTEN_LENGTH}${_POWERLEVEL9K_VCS_SHORTEN_DELIMITER}"
        ;;
      esac
    fi
  fi

  if (( _POWERLEVEL9K_HIDE_BRANCH_ICON )); then
    hook_com[branch]="${hook_com[branch]}"
  else
    hook_com[branch]="$(print_icon 'VCS_BRANCH_ICON')${hook_com[branch]}"
  fi
  # Always show the remote
  #if [[ -n ${remote} ]] ; then
  # Only show the remote if it differs from the local
  if [[ -n ${remote} ]] && [[ "${remote#*/}" != "${branch_name}" ]] ; then
     hook_com[branch]+="$(print_icon 'VCS_REMOTE_BRANCH_ICON')${remote// /}"
  fi
}

function +vi-git-tagname() {
  if (( !_POWERLEVEL9K_VCS_HIDE_TAGS )); then
    # If we are on a tag, append the tagname to the current branch string.
    local tag
    tag="$(git describe --tags --exact-match HEAD 2>/dev/null)"

    if [[ -n "${tag}" ]] ; then
      # There is a tag that points to our current commit. Need to determine if we
      # are also on a branch, or are in a DETACHED_HEAD state.
      if [[ -z "$(git symbolic-ref HEAD 2>/dev/null)" ]]; then
        # DETACHED_HEAD state. We want to append the tag name to the commit hash
        # and print it. Unfortunately, `vcs_info` blows away the hash when a tag
        # exists, so we have to manually retrieve it and clobber the branch
        # string.
        local revision
        revision="$(git rev-list -n 1 --abbrev-commit --abbrev=${_POWERLEVEL9K_CHANGESET_HASH_LENGTH} HEAD)"
        if (( _POWERLEVEL9K_HIDE_BRANCH_ICON )); then
          hook_com[branch]="${revision} $(print_icon 'VCS_TAG_ICON')${tag}"
        else
          hook_com[branch]="$(print_icon 'VCS_BRANCH_ICON')${revision} $(print_icon 'VCS_TAG_ICON')${tag}"
        fi
      else
        # We are on both a tag and a branch; print both by appending the tag name.
        hook_com[branch]+=" $(print_icon 'VCS_TAG_ICON')${tag}"
      fi
    fi
  fi
}

# Show count of stashed changes
# Port from https://github.com/whiteinge/dotfiles/blob/5dfd08d30f7f2749cfc60bc55564c6ea239624d9/.zsh_shouse_prompt#L268
function +vi-git-stash() {
  if [[ -s "${vcs_comm[gitdir]}/logs/refs/stash" ]] ; then
    local -a stashes=( "${(@f)"$(<${vcs_comm[gitdir]}/logs/refs/stash)"}" )
    hook_com[misc]+=" $(print_icon 'VCS_STASH_ICON')${#stashes}"
  fi
}

function +vi-hg-bookmarks() {
  if [[ -n "${hgbmarks[@]}" ]]; then
    hook_com[hg-bookmark-string]=" $(print_icon 'VCS_BOOKMARK_ICON')${hgbmarks[@]}"

    # To signal that we want to use the sting we just generated, set the special
    # variable `ret' to something other than the default zero:
    ret=1
    return 0
  fi
}

function +vi-vcs-detect-changes() {
  if [[ "${hook_com[vc