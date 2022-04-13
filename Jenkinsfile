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

    PROXMOX_API_CREDS = credentials('proxmox-api-hashi')
    TF_VAR_proxmox_url = 'https://spsrv:8006/api2/json'
    TF_VAR_pve_node = 'spsrv'
    TF_VAR_template_name = 'tpl-ubuntu-2004'

    STAGE0_VM_NAME = 'ubuntu-2004'
    STAGE0_VM_ID = '8999'
    STAGE1_VM_ID_BASE = '9000'
    STAGE1_VM_ID_K8S = '9001'
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
          echo "proxmox_username = \\"$PROXMOX_API_CREDS_USR\\"" >> vars.auto.pkrvars.hcl
          echo "proxmox_token = \\"$PROXMOX_API_CREDS_PSW\\"" >> vars.auto.pkrvars.hcl
          cat vars.auto.pkrvars.hcl
          packer init .
          packer inspect .
        '''
      }
    }
  }
}
