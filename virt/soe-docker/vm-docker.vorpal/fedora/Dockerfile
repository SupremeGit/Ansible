FROM scratch
MAINTAINER \
[Adam Miller <maxamillion@fedoraproject.org>] \
[Patrick Uiterwijk <patrick@puiterwijk.org>]
ENV DISTTAG=f27container FGC=f27 FBR=f27
ADD fedora-27-x86_64-20171110.tar.xz /



## Use an official Python runtime as a parent image
##FROM python:2.7-slim

# Set the working directory to /soe
#WORKDIR instruction sets the (remote) working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile.
WORKDIR /soe

# Copy the current directory contents into the container at /soe
#ADD instruction copies new files, directories or remote file URLs from <src> and adds them to the filesystem of the image at the path <dest>.
#Multiple <src> resources may be specified but if they are files or directories, their paths are interpreted as relative to the source of the context of the build.
ADD ./scripts/ /soe/scripts/

# Define environment variable Balls=Salty
ENV Balls Salty

# Install any needed packages specified in requirements.txt
#RUN has 2 forms:
#    RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
#    RUN ["executable", "param1", "param2"] (exec form)
#The RUN instruction will execute any commands in a new layer on top of the current image and commit the results. 
#The resulting committed image will be used for the next step in the Dockerfile.
#
#RUN pip install --trusted-host pypi.python.org -r fedora-requirements.txt
#RUN apt-get update && apt-get install -y inotify-tools nginx apache2 openssh-server

RUN sleep 10
RUN dnf install --assumeyes net-tools
RUN dnf install --assumeyes hostname
RUN dnf install --assumeyes openssh-server

# Make port 80 available to the world outside this container
#EXPOSE 80
EXPOSE 22


# Run fedora-run.sh when the container launches
CMD ["bash", "/soe/scripts/fedora-run.sh"]
