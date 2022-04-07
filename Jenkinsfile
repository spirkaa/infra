pipeline {
  agent {
    docker {
      image 'git.devmem.ru/cr/ansible:infra'
      registryUrl 'https://git.devmem.ru'
      registryCredentialsId 'gitea-user'
      alwaysPull true
      reuseNode true
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '60'))
    parallelsAlwaysFailFast()
    disableConcurrentBuilds()
  }

  environment {
    REGISTRY = 'git.devmem.ru'
    REGISTRY_URL = "https://${REGISTRY}"
    REGISTRY_CREDS_ID = 'gitea-user'
    ANSIBLE_CREDS_ID = 'jenkins-ssh-key'
    ANSIBLE_IMAGE = "${REGISTRY}/cr/ansible:infra"
  }

  stages {
    stage('packer') {
      when {
        beforeAgent true
        not {
          changeRequest()
        }
      }
      steps {
        sh '''
          cd packer
          packer init .
          packer build .
        '''
      }
    }
  }
}
