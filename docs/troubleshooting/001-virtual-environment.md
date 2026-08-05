# Problem

Unable to create Python virtual environment.

## Error

ensurepip is not available.

## Cause

The python3.12-venv package wasn't installed.

The second attempt was interrupted using Ctrl+C.

## Solution

sudo apt install python3.12-venv

rm -rf .venv

python3 -m venv .venv

source .venv/bin/activate

## Lesson Learned

Allow virtual environment creation to complete before interrupting the process.
