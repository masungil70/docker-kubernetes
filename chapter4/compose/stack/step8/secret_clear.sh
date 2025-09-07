docker stack rm prod_stack
docker stack rm logging
docker secret rm db_root_password
docker secret rm db_password
docker config rm nginx_config
docker config rm fluentd_config