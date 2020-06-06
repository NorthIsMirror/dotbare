mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ :$PATH: != *:"${mydir}":* ]] && export PATH="$PATH:${mydir}"

_dotbare_completions()
{
  local IFS=$'\n' subcommands curr prev options selected
  curr="${COMP_WORDS[$COMP_CWORD]}"
  prev="${COMP_WORDS[$COMP_CWORD-1]}"

  if [[ "$COMP_CWORD" -eq "1" ]]; then
    subcommands=$("${mydir}"/dotbare -h \
      | awk '{
          if ($0 ~ /^  f.*/) {
            gsub(/^  /, "", $0)
            gsub(/\t\t/, "    ", $0)
            print $0
          }
        }')

    if [[ $curr == -* ]]; then
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "-h" -- "${curr}"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "${subcommands}" -- "${curr}"))
    fi
    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
      COMPREPLY=( "${COMPREPLY[0]%% *}" )
    fi

  elif [[ "${COMP_WORDS[1]}" == "fbackup" && "${prev}" == '-p' ]]; then
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -d -- "${curr}"))

  elif [[ "${prev}" != '-h' ]]; then
    selected=("${COMP_WORDS[@]:1}")
    case "${COMP_WORDS[1]}" in
      fbackup)
        options=$("${mydir}"/dotbare fbackup -h \
          | awk -v selected="${selected[*]}" '{
              if (selected ~ $1) {
                next
              } else if ($0 ~ /  -p PATH/) {
                gsub(/^  -p PATH/, "-p  ", $0)
                gsub(/\t/, "  ", $0)
                print selected
              } else if ($0 ~ /  -*/) {
                gsub(/^  /, "", $0)
                gsub(/\t/, "  ", $0)
                print $0
              }
            }')
        ;;
      finit)
        options=$("${mydir}"/dotbare finit -h \
          | awk -v selected="${selected[*]}" '{
              if (selected ~ $1) {
                next
              } else if ($0 ~ /  -u URL/) {
                gsub(/^  -u URL/, "-u  ", $0)
                gsub(/\t/, "  ", $0)
                print $0
              } else if ($0 ~ /  -*/) {
                gsub(/^  /, "", $0)
                gsub(/\t/, "  ", $0)
                print $0
              }
            }')
        ;;
      *)
        options=$("${mydir}"/dotbare "${COMP_WORDS[1]}" -h \
          | awk -v selected="${selected[*]}" '{
              if (selected ~ $1) {
                next
              } else if ($0 ~ /  -*/) {
                gsub(/^  /, "", $0)
                gsub(/\t/, "  ", $0)
                print $0
              }
            }')
        ;;
    esac
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${options}" -- "${curr}"))
    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
      COMPREPLY=( "${COMPREPLY[0]%% *}" )
    fi
  fi
}
complete -F _dotbare_completions dotbare
