#!/bin/bash

  input_validation() {
    ROBUST=0
    WORDS=5
    SEPARATOR=""
    SECURE_CHARSET="˜!#$%ˆ&*()-=+[]\{}:;’<>?/"
    CHARSET_REG="^[^$SECURE_CHARSET]+$"
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
      case $1 in
        -r|--more-robust)
          ROBUST=1
          shift # past argument
          ;;

        -s|--separator)
          if [[ -z "$2" ]]; then 
            SEPARATOR=" "
            return 0
          fi
        
          if [[ "$2" =~ ^[\\s\\w]+$ ]]; then
            echo "(-s|--separator): separator must be a printable character"
            exit 1
          fi
          SEPARATOR=$2
          shift # past argument
          shift # past value
          ;;

        -w|--words)
          if [[ -z "$2" || "$2" =~ ^[^0-9]+$ || "$2" -lt 1 ]]; then
            echo "(-w|--words): word number must be an integer between 1 and 10"
            exit 1
          fi
          WORDS=$2
          shift # past argument
          shift # past value
          ;;

        -c|--charset)
          if [[ -z "$2" || "$2" =~ $CHARSET_REG ]]; then
            echo "(-c|--charset): charset must be in $SECURE_CHARSET"
            exit 1
          fi
          SECURE_CHARSET=$2
          shift # past argument
          shift # past value
          ;;

        -*)
          echo  "Unknown option $1"
          exit 1
          ;;

        *)
          POSITIONAL_ARGS+=("$1") # save positional arg
          shift # past argument
          ;;
      esac
    done

    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

    # echo "robust = ${ROBUST}"
    # echo "words = ${WORDS}"
    # echo ""

    if [[ -n $1 ]]; then
      echo "Last line of file specified as non-opt/last argument:"
      tail -1 "$1"
      exit 1
    fi  
  }

  words_shuffling() {

    TMP=$(mktemp)

    sort -R ./wordlist.txt > "$TMP"

    if  [[ $ROBUST == 1 ]]; then
      SECURE_WORD=$(( RANDOM % ( WORDS - 1 + 1 ) + 1 ))
      SECURE_CHAR="${SECURE_CHARSET:$(( RANDOM % ${#SECURE_CHARSET} )):1}"

      # echo "charset: $SECURE_CHARSET"
      # echo ""
    fi

    i=1
    while [ $i -le "$WORDS" ];
    do

      WORD="$( sed -e 1$'{w/dev/stdout\n;d}' -i~ "$TMP" )"

      if [[ $ROBUST == 1 && $SECURE_WORD = "$i" ]]; then
        SECURE_LETTER=$(( RANDOM % ( ${#WORD} - 1 + 1 ) + 1 ))
      
        # echo "robust word number: $SECURE_WORD"
        # echo "robust letter number: $SECURE_LETTER"
        # echo "random character: $SECURE_CHAR"
        # echo ""

        WORD="${WORD:0:$SECURE_LETTER - 1}$SECURE_CHAR${WORD:$SECURE_LETTER}"
      fi

      if [[ ! $i = 1 ]]; then
        OUTPUT="$OUTPUT$SEPARATOR$WORD"
      else
        OUTPUT="$WORD"
      fi

      i=$(( i + 1 ))
    done

    rm "$TMP"

    echo "$OUTPUT"
  }

  input_validation "$@"

  words_shuffling
