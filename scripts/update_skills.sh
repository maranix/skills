#!/usr/bin/env bash

# Uncomment to echo command before executing (Used for debugging)
# set -x

set -euo pipefail

REPO="$(realpath "$(dirname "$0")/..")"
TEMP="$REPO/temp"
SKILLS="$REPO/skills"
# [OWNER] [SKILLS] [REPO]
SOURCES=(
    "mattpocock|handoff,write-a-skill|https://github.com/mattpocock/skills/archive/refs/heads/main.zip"
    "JuliusBrussee|caveman,caveman-commit|https://github.com/JuliusBrussee/caveman/archive/refs/heads/main.zip"
)

# Exists early if command does not exist
check_command_throw()
{
if [[ -n "$(command -v $1 &>/dev/null)" ]];
then
    echo "unable to find $1, exiting..."
    exit 1
fi
}

# Downloads the repo in output directory using curl
# Verifies the integrity of zip file and inflates it
#
# Args:
#   $1: output directory path
#   $2: link of the repo
download_repo()
{
    local out=$1
    local repo=$2

    # Check if out directory exists
    if [[ -e $out ]];
    then
        # Make sure it is a directory 
        if [[ ! -d $out ]];
        then
            echo "$out exists, but isn't a directory..."
            exit 1
        else
            # re-create the directory
            rm -rf "$out"
            mkdir -p $out
        fi
    else
        # Create one if it doesn't exist
        echo "$out doesn't exist, creating..."
        mkdir -p $out
    fi

    pushd $out > /dev/null
    file="skills-main.zip"
    file=$(curl -sSLOJ $repo -w "%{filename_effective}")
    echo "Verifying $file"
    unzip -qt $file
    unzip $file
    pushd > /dev/null
}

# Filters the provided comma-separated skills in output directory
# then copies them to REPO/skills directory
#
# Args:
#   $1: directory to filter the skills from
#   $2: comma separated names of skills to filter
update_skill()
{
    IFS="," read -ra skill_arr <<< "$2"

    for skill in "${skill_arr[@]}";
    do
        result=$(find "$1" -name "$skill" -type d -not -path "*/plugins*")
        count=$(wc -l <<< "$result")

        if [[ -z $result || (( count == 0 )) ]];
        then
            echo "Unable to find $skill in $1, skipping"
            continue
        fi

        if (( count > 1 ));
        then
            echo "Duplicate $skill detected in $1"
            echo $result
            echo "Skipping $skill..."
            continue
        fi

        if [[ ! -f "$result/SKILL.md" ]];
        then
            echo "$result/SKILL.md is not a valid file, skipping"
            continue
        fi

        echo "Copying $result to $REPO/skills/$skill"
        cp -r $result "$REPO/skills/"
    done
}

# Process packed SOURCES array
#
# Args:
#   $1: An array of packed string
process_source ()
{
    local owner
    local repo 
    local source_part
    local skill_arr
    local output
    
    # IFS (Input Field Separator)
    IFS="|" read -ra source_part <<< "$1"

    owner="${source_part[0]}"
    repo="${source_part[2]}"
    output="$TEMP/$owner"

    echo "Processing $repo"

    download_repo $output $repo
    update_skill $output "${source_part[1]}"
}

check_command_throw curl

for source in "${SOURCES[@]}";
do
    process_source $source
done

rm -rf $TEMP
