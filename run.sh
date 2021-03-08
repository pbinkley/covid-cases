#!/bin/bash --login
echo `date`
cd /home/pbinkley/Projects/knitting/covid-cases
export PATH=/home/pbinkley/.rvm/gems/ruby-2.5.5/bin:$PATH
rvm use 2.5.5
bundle exec ./fetch-cases.rb
bundle exec ./process-cases.rb

