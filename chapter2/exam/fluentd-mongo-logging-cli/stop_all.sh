
#!/bin/bash
set -e

echo "### Stopping and removing all containers... ###"
docker stop mongo-db fluentd-aggregator nginx1 nginx2 mysql1 mysql2
docker rm mongo-db fluentd-aggregator nginx1 nginx2 mysql1 mysql2

echo "### Removing Docker network... ###"
docker network rm logging-net

echo "### Cleanup complete! ###"
