#!/bin/bash

find_env_files_with_backup() {
    directory="${1:-.}"
    backup_dir="$directory/backup_env/$(date +"%d-%m-%Y_%H:%M:%S")"

    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
    fi

    find "$directory" -type d \( -path "$directory/backup_env" -prune \) -o \( -type f \( -name "*.env" -o -name "dotenv*" \) -print \) | while IFS= read -r env_file; do
        backup_file="$backup_dir/${env_file#$directory/}"
        mkdir -p "$(dirname "$backup_file")"
        cp "$env_file" "$backup_file"
    done

    echo "Backup have been created at $backup_dir"
}

restore_from_latest_backup() {
    directory="${1:-.}"
    backup_dir="$directory/backup_env"
    latest_backup=$(ls -td "$backup_dir"/* | head -1)

    if [ -z "$latest_backup" ]; then
        echo "No backup found."
        return
    fi

    read -p "Are you sure you want to overwrite current environment files with the latest backup? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Restoration cancelled."
        return
    fi

    find "$latest_backup" -type f -print | while IFS= read -r backup_file; do
        restore_file="$directory/${backup_file#$latest_backup/}"
        mkdir -p "$(dirname "$restore_file")"
        cp "$backup_file" "$restore_file"
    done

    echo "Loaded from $latest_backup"
}

while true; do
    echo "Please choose an option:"
    echo "1. Backup environment file"
    echo "2. Load from last backup"
    echo "3. Exit"
    read -p "Enter your choice [1, 2, or 3]: " choice

    case $choice in
        1)
            current_directory="."
            find_env_files_with_backup "$current_directory"
            ;;
        2)
            current_directory="."
            restore_from_latest_backup "$current_directory"
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
done
