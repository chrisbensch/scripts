#!/usr/bin/env bash
# Fully backup a docker-compose project, including all images, named and unnamed volumes, container filesystems, config, logs, and databases. 

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
cd "$project_dir"

project_name=$(basename "$project_dir")
backup_time=$(date +"%Y-%m-%d_%H-%M")
backup_dir="$project_dir/backups/$backup_time"

# Optionally pause the containers
# docker-compose pause

# Source any needed environment variables
[ -f "$project_dir/docker-compose.env" ] && source "$project_dir/docker-compose.env"
[ -f "$project_dir/.env" ] && source "$project_dir/.env"


echo "[+] Backing up $project_name project to $backup_dir"
mkdir -p "$backup_dir"

echo "    - Saving config to ./docker-compose.yml"
docker-compose config > "$backup_dir/docker-compose.yml" || exit 1


# save database dump files
echo "    - Saving database dumps to ./dumps"
mkdir -p "$backup_dir/dumps"
# your database/stateful service export commands go here, e.g.
# docker-compose exec postgresql env PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip -9 > "$backup_dir/dumps/$POSTGRES_DB.sql.gz"

for service_name in $(docker-compose config --services); do
    container_id=$(docker-compose ps -q "$service_name")
    image_name=$(docker inspect -f "{{ .Config.Image }}" "$container_id")
    image_id=$(docker image ls -q "$image_name")

    service_dir="$backup_dir/$service_name"
    echo "[*] Backing up ${project_name}__${service_name} to ./$service_name..."
    mkdir -p "$service_dir"

    # save config
    echo "    - Saving config to ./$service_name/config.json"
    docker inspect "$container_id" > "$service_dir/config.json"

    # save logs
    echo "    - Saving logs to ./$service_name/docker.out/err"
    docker logs "$container_id" > "$service_dir/docker.out" 2> "$service_dir/docker.err"

    # save data volumes
    mkdir -p "$service_dir/volumes"
    for source in $(docker inspect -f '{{range .Mounts}}{{println .Source}}{{end}}' "$container_id"); do
        volume_dir="$service_dir/volumes$source"
        echo "    - Saving $source volume to ./$service_name/volumes$source"
        mkdir -p $(dirname "$volume_dir")
        cp -a -r "$source" "$volume_dir"
    done
    
    # save image
    echo "    - Saving $image_name image to ./$service_name/image.tar"
    docker save --output "$service_dir/image.tar" "$image_id"

    # save container filesystem
    echo "    - Saving container filesystem to ./$service_name/container.tar"
    docker export --output "$service_dir/container.tar" "$container_id"

    # save entire container root dir
    echo "    - Saving container root to $service_dir/root"
    cp -a -r "/var/lib/docker/containers/$container_id" "$service_dir/root"
done

echo "[*] Compressing backup folder to $backup_dir.tar.gz"
tar -zcf "$backup_dir.tar.gz" --totals "$backup_dir" && rm -Rf "$backup_dir"

echo "[√] Finished Backing up $project_name to $backup_dir.tar.gz."

# Resume the containers if paused above
# docker-compose unpause