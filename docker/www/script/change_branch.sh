#!/usr/bin/env bash

###
#
# If the branch exists at the origin, then checkout it out and pull.
#
##
do_git_work() {
  branches=$(git branch -l -r)
  for B in ${branches}
  do
    if [ "${B}" == "origin/${branch_name}" ]; then
      git checkout ${branch_name}
      git pull;
      break;
    fi
  done
}

##
#
# We get the branch from the dockerfile ENV.
# It is used in the do_git_work method.
#
##
branch_name=${BRANCH}
cd web/themes/custom/faktalink || return
do_git_work
cd ../../..

cd modules/custom || return
folders=$(find . -maxdepth 1 -type d)
for D in ${folders}
do
  if [ "${D}" != '.' ]; then
    cd ${D} || return
    do_git_work
    cd ..
  fi
done
