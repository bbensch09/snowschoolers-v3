web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}


worker: bundle exec QUEUE=* rake resque:work
clock:  bundle exec rake resque:scheduler
