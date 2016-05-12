#!/bin/sh

cd `dirname $0`

# If there is a file that defines a shell environment specific to this
# instance of Galaxy, source the file.
if [ -z "$GALAXY_LOCAL_ENV_FILE" ];
then
    GALAXY_LOCAL_ENV_FILE='./config/local_env.sh'
fi

if [ -f $GALAXY_LOCAL_ENV_FILE ];
then
    . $GALAXY_LOCAL_ENV_FILE
fi

# Pop args meant for common_startup.sh
while :
do
    case "$1" in
        --skip-eggs|--skip-wheels|--skip-samples|--dev-wheels|--no-create-venv|--no-replace-pip|--replace-pip)
            common_startup_args="$common_startup_args $1"
            shift
            ;;
        --skip-venv)
            skip_venv=1
            common_startup_args="$common_startup_args $1"
            shift
            ;;
        --stop-daemon)
            common_startup_args="$common_startup_args $1"
            paster_args="$paster_args $1"
            stop_daemon_arg_set=1
            shift
            ;;
        --daemon|restart)
            paster_args="$paster_args $1"
            daemon_or_restart_arg_set=1
            shift
            ;;
        --wait)
            wait_arg_set=1
            shift
            ;;
        "")
            break
            ;;
        *)
            paster_args="$paster_args $1"
            shift
            ;;
    esac
done

./scripts/common_startup.sh $common_startup_args || exit 1

# If there is a .venv/ directory, assume it contains a virtualenv that we
# should run this instance in.
GALAXY_VIRTUAL_ENV="${GALAXY_VIRTUAL_ENV:-.venv}"
if [ -d "$GALAXY_VIRTUAL_ENV" -a -z "$skip_venv" ];
then
    [ -n "$PYTHONPATH" ] && { echo 'Unsetting $PYTHONPATH'; unset PYTHONPATH; }
    printf "Activating virtualenv at $GALAXY_VIRTUAL_ENV\n"
    . "$GALAXY_VIRTUAL_ENV/bin/activate"
fi

# If you are using --skip-venv we assume you know what you are doing but warn
# in case you don't.
[ -n "$PYTHONPATH" ] && echo 'WARNING: $PYTHONPATH is set, this can cause problems importing Galaxy dependencies'

python ./scripts/check_python.py || exit 1

if [ ! -z "$GALAXY_RUN_WITH_TEST_TOOLS" ];
then
    export GALAXY_CONFIG_OVERRIDE_TOOL_CONFIG_FILE="test/functional/tools/samples_tool_conf.xml"
    export GALAXY_CONFIG_ENABLE_BETA_WORKFLOW_MODULES="true"
    export GALAXY_CONFIG_OVERRIDE_ENABLE_BETA_TOOL_FORMATS="true"
fi

if [ -n "$GALAXY_UNIVERSE_CONFIG_DIR" ]; then
    python ./scripts/build_universe_config.py "$GALAXY_UNIVERSE_CONFIG_DIR"
fi

if [ -z "$GALAXY_CONFIG_FILE" ]; then
    if [ -f universe_wsgi.ini ]; then
        GALAXY_CONFIG_FILE=universe_wsgi.ini
    elif [ -f config/galaxy.ini ]; then
        GALAXY_CONFIG_FILE=config/galaxy.ini
    else
        GALAXY_CONFIG_FILE=config/galaxy.ini.sample
    fi
    export GALAXY_CONFIG_FILE
fi

