docker container exec pipelineonubuntu_ansible-host1_1 serve -s /home/remote-user/deploy/final/build -l 4000 &
docker container exec pipelineonubuntu_ansible-host2_1 serve -s /home/remote-user/deploy/final/build -l 4000 &
docker container exec pipelineonubuntu_ansible-host3_1 serve -s /home/remote-user/deploy/final/build -l 4000 &
docker container exec pipelineonubuntu_jekns-ans-master_1 sshpass -p "1234" ssh -o StrictHostKeyChecking=no remote-user@172.24.0.6 'exit'
docker container exec pipelineonubuntu_jekns-ans-master_1 sshpass -p "1234" ssh -o StrictHostKeyChecking=no remote-user@172.24.0.8 'exit'
docker container exec pipelineonubuntu_jekns-ans-master_1 sshpass -p "1234" ssh -o StrictHostKeyChecking=no remote-user@172.24.0.10 'exit'
echo -e "\n fetching jenkins password........"
sleep 20
echo -e "\nJenkins password:"
docker container exec pipelineonubuntu_jekns-ans-master_1 cat /var/jenkins_home/secrets/initialAdminPassword
echo -e "\n fetching nexus password........"
sleep 10
echo -e "\nNexus Password:"
docker container exec pipelineonubuntu_nexus_1 cat /nexus-data/admin.password
echo -e "\n\n"
