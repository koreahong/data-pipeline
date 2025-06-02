alias c='clear' 
alias p='pwd' 
alias lll='ls -lh' 
alias b='cd ..' 
alias bb='cd ../..' 
alias bbb='cd ../../..' 
alias bbbb='cd ../../../..' 

dkar() {
        docker stop $(docker ps -a | grep airflow | awk '{print $1}')
        docker stop $(docker ps -a | grep redis | awk '{print $1}')
        docker stop $(docker ps -a | grep flower | awk '{print $1}')
        # docker stop $(docker ps -a | grep postgres | awk '{print $1}')
        docker rm $(docker ps -a | grep airflow | awk '{print $1}')
        docker rm $(docker ps -a | grep redis | awk '{print $1}')
        docker rm $(docker ps -a | grep flower | awk '{print $1}')
        # docker rm $(docker ps -a | grep postgres | awk '{print $1}')
        docker rmi -f $(docker images | grep airflow | awk '{print $3}')
        docker rmi -f $(docker images | grep redis | awk '{print $3}')
        docker rmi -f $(docker images | grep flower | awk '{print $3}')
        # docker rmi -f $(docker images | grep postgres | awk '{print $3}')
        if [ "$SERVER_ENV" == "prod" ]; then
            docker stop $(docker ps -a | grep statsd | awk '{print $1}')
            docker rm $(docker ps -a | grep statsd | awk '{print $1}')
            sudo docker build -t statsd-exporter -f statsd_dockerfile . && \
            docker rmi -f $(docker images | grep statsd | awk '{print $3}')
            sudo docker run -d --name statsd-exporter --network=ubuntu_default \
                -p 9102:9102 -p 9125:9125 -p 9125:9125/udp statsd-exporter \
                --statsd.listen-udp=:9125 \
                --web.listen-address=:9102 \
                --log.level=debug \
                --statsd.mapping-config=/opt/statsd_mapping.yaml
        else
            echo "Environment is not 'prod'. Skipping Docker build and run."
        fi            
        sudo docker compose --env-file .env -f airflow-main-compose.yaml up -d --build
        # sudo docker compose -f airflow-main-compose.yaml up -d && \
        # sudo docker compose -f airflow-main-compose.yaml up -d flower
}

dkopr() {
    docker stop $(docker ps -a | grep openmetadata | awk '{print $1}')
    docker stop $(docker ps -a | grep execute_migrate_all | awk '{print $1}')
    docker stop $(docker ps -a | grep elasticsearch | awk '{print $1}')
    docker rm $(docker ps -a | grep openmetadata | awk '{print $1}')
    docker rm $(docker ps -a | grep execute_migrate_all | awk '{print $1}')
    docker rm $(docker ps -a | grep elasticsearch | awk '{print $1}')
    docker rmi -f $(docker images | grep openmetadata | awk '{print $3}')
    docker rmi -f $(docker images | grep elasticsearch | awk '{print $3}')
    sudo docker compose --env-file .env -f openmetadata-compose.yml up -d
}


dktl() {
    case "$1" in
        s) echo exec container airflow-airflow-scheduler-1 && docker exec -it "airflow-airflow-scheduler-1" /bin/bash ;;
        w) echo exec container airflow-airflow-webserver-1 && docker exec -it "airflow-airflow-webserver-1" /bin/bash ;;
        t) echo exec container airflow-airflow-triggerer-1 && docker exec -it "airflow-airflow-triggerer-1" /bin/bash ;;
        k) echo exec container airflow-airflow-worker-1 && docker exec -it "airflow-airflow-worker-1" /bin/bash ;;
        # p) echo exec container ubuntu-airflow-sync-perm-1 && docker exec -it "ubuntu-airflow-sync-perm-1" /bin/bash ;;
        o) echo exec container openmetadata_server && docker exec -it openmetadata_server /bin/bash ;;
        *) echo "Invalid parameter. Usage: docker_exec [s(scheduler)|w(webserver)|t(triggerer)|k(worker)]" ;;
    esac
}