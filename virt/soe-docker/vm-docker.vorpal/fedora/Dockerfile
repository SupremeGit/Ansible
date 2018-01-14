FROM scratch

MAINTAINER \
[Adam Miller <maxamillion@fedoraproject.org>] \
[Patrick Uiterwijk <patrick@puiterwijk.org>]

ENV DISTTAG=f27container FGC=f27 FBR=f27 Balls=Salty
ADD fedora-27-x86_64-20171110.tar.xz /

#########################################################
# Install any needed packages specified in requirements.txt
#RUN has 2 forms:
#    RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
#    RUN ["executable", "param1", "param2"] (exec form)
#The RUN instruction will execute any commands in a new layer on top of the current image and commit the results. 
#The resulting committed image will be used for the next step in the Dockerfile.
#RUN pip install --trusted-host pypi.python.org -r fedora-requirements.txt

RUN dnf install --assumeyes net-tools hostname openssh-server monit dumb-init procps-ng less iputils iproute passwd python2-dnf sudo rsync

#not really required:
#lsof tigervnc-server

######################################################### 
#If dynamic ops above are cached, changing anything after this line should be fast:

#Local workdir is set to dir the Dockerfile is in. So, eg: src path for ADD can be relative to this.
#WORKDIR instruction sets the (remote) working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile.
WORKDIR /soe

#ADD instruction copies new files, directories or remote file URLs from <src> and adds them to the filesystem of the image at the path <dest>.
#Multiple <src> resources may be specified but if they are files or directories, their paths are interpreted as relative to the source of the context of the build.
ADD ./scripts/ ./scripts/
ADD fedora-version.txt .

# Make ports available to the world outside this container, and 
#   22    :  sshd
#   2812  :  monit status webpage:
#   5666: :  nrpe
#   9090  :  CockPit
#   25826 :  collectd
EXPOSE 22 2812 5666 9090 25826

##################################
#Specify main entrypoint, or cmd:
#cmd        - passed to shell
#entrypoint - run directly as pid 1. 

#cmd will always run during build process
#entrypoint by itself will not run during build. Only when container is run.

#The default CMD is over-ridden by command specified with run.
#The default ENTRYPOINT can be similarly overridden but it requires the use of the --entrypoint flag
#  and generally you don't want to override entrypoint unless debugging or something eg:
#    docker run -it --entrypoint="/bin/bash" myapp

#When using entrypoint & cmd together:
#  ENTRYPOINT specifies a command that will always be executed when the container starts. 
#  The CMD specifies arguments that will be fed to the ENTRYPOINT
#  ie if entrypoint is specified, then args passed in by CMD or run are passed to entrypoint as args
#
#To use, build and tag:
#  docker build -t=myapp
#Then run tagged build, passing it args just like a command:
#  docker run myapp args_for_myapp

#In contrast, ENTRYPOINT should be used in scenarios where you want the container to behave exclusively as if it were 
#the executable it's wrapping. That is, when you don't want or expect the user to override the executable you've specified.

#shell form:
#CMD executable param1 param2
#When using the shell form, the specified binary is executed with an invocation of the shell using /bin/sh -c.

#exec form:
#CMD ["executable","param1","param2"]
#Note that the content appearing after the CMD instruction in this case is formatted as a JSON array.
#When the exec form of the CMD instruction is used the command will be executed without a shell.

#example entrypoint and command, image behaves like a wrapped executable, eg "ping -c 3":
#must use exec form.
#ENTRYPOINT ["/bin/ping","-c","3"]
#CMD ["localhost"]

#########################################################
#Run dumb-init:
# Runs "/usr/bin/dumb-init -- /my/script --with --args"
#ENTRYPOINT ["/usr/bin/dumb-init", "--"]
#--single-child  only forward signals to direct child, not to all managed processes (& subprocesses):
#  this is useful when starting a shell, as without this, bash job control does not work:
ENTRYPOINT ["/usr/bin/dumb-init", "--single-child", "--"]
#
# or if you use --rewrite or other cli flags
# ENTRYPOINT ["dumb-init", "--rewrite", "2:3", "--"]

#CMD ["/my/script", "--with", "--args"]
#CMD ["/bin/bash", "-il"]
CMD ["/bin/bash"]

# Run fedora-run.sh when the container launches
#CMD ["bash", "/soe/scripts/fedora-run.sh"]

###ENTRYPOINT ["/bin/bash","-il"]
#ENTRYPOINT ["/bin/bash"]
#CMD ["/soe/scripts/fedora-run.sh"]

#Or use monit instead of dumb-init:
#CMD=["monit", "-d", "10", "-Ic", "/soe/scripts/monitrc"]

#with entrypoint bash, can get an interactive container with:
#docker run --tty --interactive --hostname "balls" soe.vorpal_fedora:current "-il"

