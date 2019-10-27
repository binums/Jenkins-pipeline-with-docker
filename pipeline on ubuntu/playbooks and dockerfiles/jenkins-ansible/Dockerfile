FROM jenkins/jenkins
# if we want to install via apt
USER root
RUN apt-get update && apt-get install -y apt-utils curl sshpass
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install nodejs ansible zip nano -y
COPY inventory.txt pb1.yml /
# RUN echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
# RUN ssh-keygen -f newkey -N ""
# drop back to the regular jenkins user - good practice
#USER jenkins