#! groovy

// general vars
def DOCKER_REPO = "larskhansen"
def PRODUCT = 'itotko-dk'
def BRANCH
BRANCH = BRANCH_NAME.replaceAll('feature/', '')
BRANCH = BRANCH.replaceAll('_', '-')

// artifactory buildname
def BUILDNAME = 'Itotko-dk :: ' + BRANCH

pipeline {
  agent {
    node { label 'master' }
  }
  options {
    buildDiscarder(logRotator(artifactDaysToKeepStr: "", artifactNumToKeepStr: "", daysToKeepStr: "", numToKeepStr: "5"))
    timestamps()
    // Limit concurrent builds to one pr. branch.
    disableConcurrentBuilds()
  }
  stages {
    // Build the Drupal website image.
    stage('Docker Drupal Site') {
      steps {
        script {
          docker.build("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}",
            "-f ./docker/www/Dockerfile --no-cache --build-arg BRANCH=${BRANCH_NAME} .")
        }
      }
    }
    
    stage('Push to artifactory') {
      steps {
        script {
          def artyServer = Artifactory.server 'arty'
          def artyDocker = Artifactory.docker server: artyServer, host: env.DOCKER_HOST

          def buildInfo_www = Artifactory.newBuildInfo()
          buildInfo_www.name = BUILDNAME
          buildInfo_www = artyDocker.push("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}", 'docker', buildInfo_www)
          buildInfo_www.env.capture = true
          buildInfo_www.env.collect()

          artyServer.publishBuildInfo buildInfo_www

          //docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          if (BRANCH == 'develop') {
            build job: 'Faktalink/Deploys/Deploy faktalink.dk develop'
          } else if (BRANCH == 'master') {
            build job: 'Faktalink/Deploys/Deploy faktalink.dk staging'
          } else {
            build job: 'Faktalink/Deploys/Deploy faktalink.dk develop', parameters: [string(name: 'deploybranch', value: BRANCH)]
          }
        }
      }
    }
  }
  post {
    always {
      sh """
      echo WORKSPACE: ${env.WORKSPACE}
      """
      cleanWs()
      dir("${env.WORKSPACE}@2") {
        deleteDir()
      }
      dir("${env.WORKSPACE}@2@tmp") {
        deleteDir()
      }
      dir("${env.WORKSPACE}@tmp") {
        deleteDir()
      }
    }
  }
}
