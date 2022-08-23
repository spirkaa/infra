pipeline {
  agent {
    docker {
      image 'git.devmem.ru/projects/ansible:infra'
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
    skipDefaultCheckout true
  }

  triggers {
    cron(BRANCH_NAME == 'main' ? 'H 9 * * 6' : '')
  }

  environment {
    REGISTRY = 'git.devmem.ru'
    REGISTRY_URL = "https://${REGISTRY}"
    REGISTRY_CREDS_ID = 'gitea-user'
    ANSIBLE_IMAGE = "${REGISTRY}/projects/ansible:infra"
    JENKINS_SSH_KEY = 'jenkins-ssh-key'

    TF_IN_AUTOMATION = "1"
    TF_BACKEND_CREDS = credentials('terraform-backend')
    PROXMOX_API_CREDS = credentials('proxmox-api-hashi')
    SSH_PUB_KEY_1 = credentials('ssh-pub-key-spirkaa-sphome-fc')
    SSH_PUB_KEY_2 = credentials('ssh-pub-key-jenkins-ci')

    PROXMOX_NODE = 'spsrv'
    TF_VAR_proxmox_url = "https://${PROXMOX_NODE}:8006/api2/json"
    TF_VAR_template_name = 'tpl-ubuntu-2204'

    STAGE0_VM_NAME = 'ubuntu-2204'
    STAGE0_VM_ID = '8999'
    STAGE1_VM_ID_BASE = '9000'
    STAGE1_VM_ID_K8S = '9001'
  }

  stages {
    stage('init') {
      when {
        anyOf {
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'TimerTrigger'
          changeRequest()
        }
      }
      steps {
        checkout([
          $class: 'GitSCM',
          branches: scm.branches,
          extensions: scm.extensions + [
            [$class: 'SubmoduleOption',
              disableSubmodules: false,
              parentCredentials: false,
              recursiveSubmodules: true,
              trackingSubmodules: true,
              reference: ''
            ]
          ],
          userRemoteConfigs: scm.userRemoteConfigs
        ])
        withCredentials([sshUserPrivateKey(credentialsId: "${JENKINS_SSH_KEY}", keyFileVariable: 'SSH_KEY')]) {
          sh '''#!/bin/bash
            mkdir ~/.ssh && chmod 700 ~/.ssh
            cat $SSH_KEY > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
          '''
        }
      }
    }

    stage('pre-commit') {
      when {
        anyOf {
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'TimerTrigger'
          changeRequest()
        }
      }
      steps {
        cache(path: "/home/jenkins/agent/workspace/.cache/pre-commit", key: "infra-pre-commit-${hashFiles('.pre-commit-config.yaml')}") {
          sh '''#!/bin/bash
            PRE_COMMIT_HOME=/home/jenkins/agent/workspace/.cache/pre-commit pre-commit run --all-files --verbose --color always
          '''
        }
      }
    }

    stage('ansible') {
      when {
        branch 'main'
        anyOf {
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh '''#!/bin/bash
          cd ansible
          ansible-playbook pve_template_build.yml --private-key ~/.ssh/id_rsa
        '''
      }
    }

    stage('packer') {
      when {
        branch 'main'
        anyOf {
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh '''#!/bin/bash
          cd packer
          echo "proxmox_username = \\"$PROXMOX_API_CREDS_USR\\"" >> vars.auto.pkrvars.hcl
          echo "proxmox_token = \\"$PROXMOX_API_CREDS_PSW\\"" >> vars.auto.pkrvars.hcl

          packer init .
          packer inspect .
        '''
      }
    }

    stage('terraform') {
      when {
        branch 'main'
        anyOf {
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh '''#!/bin/bash
          cd terraform
          echo "proxmox_username = \\"$PROXMOX_API_CREDS_USR\\"" >> terraform.tfvars
          echo "proxmox_token = \\"$PROXMOX_API_CREDS_PSW\\"" >> terraform.tfvars
          echo "ssh_pub_keys = \\"$SSH_PUB_KEY_1\\n$SSH_PUB_KEY_2\\"" >> terraform.tfvars

          terraform init -input=false \
            -backend-config="access_key=$TF_BACKEND_CREDS_USR" \
            -backend-config="secret_key=$TF_BACKEND_CREDS_PSW"
          terraform plan -input=false
        '''
      }
    }
  }
}
