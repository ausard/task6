node {
    def versionString
    stage('Clone code') {
        git branch: 'task6', url: 'https://github.com/ausard/task6'
    }

    stage('Gradle build') {
        sh './gradlew incrementVersion'
        sh './gradlew clean build'
        archiveArtifacts 'build/libs/app.war'
    }

    stage ('Get version') {
        // need plugin 'Pipeline Utility Steps'
        def properties = readProperties  file: 'gradle.properties'
        versionString = properties."version"
    }

    stage('Publish to nexus') {
      //need plugin Nexus artifact uploader
        nexusArtifactUploader artifacts: [[artifactId: 'app',
            classifier: '', file: 'build/libs/app.war',
            type: 'war']], 
            credentialsId: 'Nexus',
            groupId: 'test',
            nexusUrl: 'localhost:8081/nexus',
            nexusVersion: 'nexus2',
            protocol: 'http',
            repository: 'snapshots',
            version: versionString   

    }
    stage('Build image and push at repository'){                    
        sh "docker build --build-arg VERSION=${versionString} -t task6:${versionString} ."
        sh "docker image tag task6:${versionString} localhost:5000/task6:${versionString}"
        sh "docker push localhost:5000/task6:${versionString}"
        sh "docker image remove localhost:5000/task6:${versionString}"
        sh "docker image remove tomcat:9"
   }

    stage('Swarm service'){
        def SWARM_ACTIVE = sh (
            script: 'docker system info | grep "Swarm: active"',
            returnStatus: true
        ) == 0
        sh "docker pull localhost:5000/task6:${versionString}" 

        if (SWARM_ACTIVE) { 
            def TOMCAT_RUNNING = sh (
                script: 'docker service ls | grep tomcat',
                returnStatus: true
            ) == 0       
            if(TOMCAT_RUNNING){
                sh "docker service update --image localhost:5000/task6:${versionString} tomcat"
            }else{
                sh "docker service create --name tomcat --replicas=2 -p 8082:8080 localhost:5000/task6:${versionString}"
            }            
        } else {
            sh "docker swarm init --advertise-addr 192.168.50.2"                      
            sh "docker service create --name tomcat --replicas=2 -p 8082:8080 localhost:5000/task6:${versionString}"
        }   
    }

    stage('Validate deploy of service'){
        def urlTomcat = 'http://192.168.50.2:8082/app/'
                
        def response = sh (
            script: "curl ${urlTomcat} | grep ${versionString}",
            returnStatus: true
        ) == 0
        // need plugin 	HTTP Request
        //respString = response.content respString.contains(versionString)
        if(response) {
            println "Version on the webserver is correct"
            currentBuild.result="SUCCESS"
        } else {
            println "Version on the webserver is incorrect!!!"
            currentBuild.result="FAILURE"
        }                     
   }
    
    stage('Commit changes on git'){
        echo 'This will sync changes on git'      
        sh 'git add gradle.properties'
        sh 'git config --global user.name "ausard"'
        sh 'git config --global user.email "ausard@yandex.ru"'
        sh 'git commit -m "Version changed to '+versionString+'"'            
        withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh 'git push --set-upstream https://$USERNAME:$PASSWORD@github.com/ausard/task6.git task6'
            sh 'git checkout master'
            sh 'git merge task6'
            sh 'git tag '+versionString
            sh 'git push --tags https://$USERNAME:$PASSWORD@github.com/ausard/task6.git'
        }
    }    
}
