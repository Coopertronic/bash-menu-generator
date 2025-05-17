#!/bin/bash

# Configuration
##  Defaults
symbolDefaults="*"        # -s
paddingSymbolDefaults=" " # -p
lineLengthDefaults=70     # -l
charsToOptionDefaults=1   # -o
charsToNameDefaults=3     # -n

##      Options
while getopts "hvs:p:l:o:n:" option; do
    case $option in
    s)
        symbol=(${OPTARG})
        ;;
    p)
        paddingSymbol=(${OPTARG})
        ;;
    l)
        lineLength=(${OPTARG})
        ;;
    o)
        charsToOption=(${OPTARG})
        ;;
    n)
        charsToName=(${OPTARG})
        ;;
    h)
        help_me
        exit 3
        ;;
    v)
        version_info
        exit 3
        ;;
    ?)
        help_me
        exit 1
        ;;
    esac
done

##  Set default if no option used
if [ -z "$symbol" ]; then       # -s not used
    symbol="$symbolDefaults"
fi
if [ -z "$paddingSymbol" ]; then       # -p not used
    paddingSymbol="$paddingSymbolDefaults"
fi
if [ -z "$lineLength" ]; then       # -l not used
    lineLength="$lineLengthDefaults"
fi
if [ -z "$charsToOption" ]; then       # -o not used
    charsToOption="$charsToOptionDefaults"
fi
if [ -z "$charsToName" ]; then       # -n not used
    charsToName="$charsToNameDefaults"
fi

# Generates dialog with options
declare -a options=("Enable WiFi" "Disable flux capacitor" "Check repository status" "Walk the dog");
generateDialog "options" "Choose an option" "${options[@]}"

read choice
# Do something after getting their choice



function generatePadding() {
    string=""
    for ((i = 0; i < $2; i++)); do
        string+="$1"
    done
    echo "$string"
}

# Generated configs
remainingLength=$(($lineLength - 2))
line=$(generatePadding "${symbol}" "${lineLength}")
toOptionPadding=$(generatePadding "${paddingSymbol}" "${charsToOption}")
toNamePadding=$(generatePadding "$paddingSymbol" "$charsToName")

# generateText (text)
function generateText() {
    totalCharsToPad=$((remainingLength - ${#1}))
    charsToPadEachSide=$((totalCharsToPad / 2))
    padding=$(generatePadding "$paddingSymbol" "$charsToPadEachSide")
    totalChars=$((${#symbol} + ${#padding} + ${#1} + ${#padding} + ${#symbol}))
    if [[ ${totalChars} < ${lineLength} ]]; then
        echo "${symbol}${padding}${1}${padding}${paddingSymbol}${symbol}"
    else
        echo "${symbol}${padding}${1}${padding}${symbol}"
    fi
}

# generateTitle (title)
function generateTitle() {
    echo "$line"
    generateText ""
    generateText "$1"
    generateText ""
    echo "$line"
}

# generateOption (dialogType, optionNumber, optionName)
function generateOption() {
    tempOptionPadding=$toOptionPadding
    tempNamePadding=$toNamePadding
    if [[ $1 == "options" ]]; then
        if [[ $3 == "Exit" ]] || [[ $3 == "Return to the main menu" ]]; then
            optionString="[0]"
        else
            optionString="[$2]"
        fi
    elif [[ $1 == "instructions" ]]; then
        optionString="$2."
    fi
    charsToPadName=$((${lineLength} - ${#symbol} - ${#tempOptionPadding} - ${#optionString} - ${#tempNamePadding} - ${#3} - ${#symbol}))
    namePadding=$(generatePadding "$paddingSymbol" "$charsToPadName")
    echo "${symbol}${tempOptionPadding}${optionString}${tempNamePadding}${3}${namePadding}${symbol}"
}

# generateOptionsFromArray (dialogType, array[options])
function generateOptionsFromArray() {
    index=1
    generateText ""
    for OPTION in "${@:2}"; do
        if [[ "$1" == "message" ]]; then
            generateText "$OPTION"
        else
            generateOption "$1" "$index" "$OPTION"
        fi
        ((index++))
    done
    generateText ""
}

# generateDialog (dialogType, dialogTitle, array[options])
function generateDialog() {
    generateTitle "$2"
    generateOptionsFromArray "$1" "${@:3}"
    echo "$line"
}

# generateGoBackDialog (name, isNewLine)
function generateGoBackDialog() {
    if [[ $2 == "true" ]]; then
        echo -e "\n$line"
    else
        echo -e "$line"
    fi
    generateText ""
    generateOption "options" "0" "$1"
    generateText ""
    echo -e "$line"
}

# generateMessageDialog (title, array[message])
function generateMessageDialog() {
    if [[ "${#1}" > 0 ]]; then
        generateTitle "$1"
    fi
    generateOptionsFromArray "message" "${@:2}"
    echo "$line"
}
