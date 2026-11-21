
library 'ts-jenkins-shared-library@main'

// main and release branches start at most one build an hour instead of one per push: a push
// that arrives inside the hour waits in the queue, later pushes fold into that one build, and
// it builds the newest commit when the hour is up. A build started by hand is not held back
// (userBoost). Pull requests and other branches build on every push; the limit there is set
// too high to ever apply. TownSuite/TownSuite.IssueTracker#17881.
int builds_per_hour = townsuite.is_publishing_branch() ? 1 : 1000

pipeline {
    agent none
    options {
        rateLimitBuilds(throttle: [count: builds_per_hour, durationName: 'hour', userBoost: true])
        copyArtifactPermission('*/TownSuite-Artifact-Publish')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 2, unit: 'HOURS')
    }
    environment {
        AUTOCONFIGURE_NUGET = 'true'
    }
    stages {
        stage('Start Automation Script') {
            agent { label 'starting-agent' }
            steps {
                script {
                    townsuite_automation2.start_linux_and_windows()
                }
            }
        }
        stage('Pipeline') {
            stages {
                stage('Parallel Paths') {
                    parallel {
                        stage('Windows Path') {
                            agent { label townsuite_automation2.get_windows_label() }
                            stages {
                                stage('Environment Setup') {
                                    steps {
                                        script {
                                            townsuite.common_environment_configuration()
                                            townsuite.checkout_scm()
                                        }
                                    }
                                }
                                stage('Build') {
                                    steps {
                                        pwsh '''
                                        .\\build_windows.ps1
                                        '''
                                    }
                                }
                                stage('Code Sign') {
                                    when {
                                        expression { return env.BRANCH_NAME.startsWith('PR-') == false }
                                    }
                                    steps {
                                        echo 'Code Signing happening here....'
                                        script {
                                            townsuite.codesign "${env.WORKSPACE}\\build", '*TownSuite*.dll;*TownSuite*.exe', false
                                        }
                                    }
                                }
                                stage('Zip') {
                                    steps {
                                        pwsh '''
                                        .\\build_zip.ps1
                                        '''
                                    }
                                }
                                stage('Code Sign Detached') {
                                    when {
                                        expression { return env.BRANCH_NAME.startsWith('PR-') == false }
                                    }
                                    steps {
                                        echo 'Code Signing happening here....'
                                        script {
                                            townsuite.codesign "${env.WORKSPACE}/build", '*.zip', true
                                        }
                                    }
                                }
                                stage('Archive') {
                                    steps {
                                        echo 'archiving artifacts'
                                        script {
                                            townsuite.archiveWithRetryAndLock('build/*.zip,build/*.SHA256SUMS,build/*.sig', 3)
                                        }
                                    }
                                }
                            }
                        }
                        stage('Linux Path') {
                            agent { label townsuite_automation2.get_ubuntu_label() }
                            stages {
                                stage('Environment Setup') {
                                    steps {
                                        script {
                                            townsuite.common_environment_configuration()
                                            townsuite.checkout_scm()
                                        }
                                    }
                                }
                                stage('Build') {
                                    steps {
                                        pwsh '''
                                        .\\build.ps1
                                        .\\build_linux.ps1
                                        .\\build_zip.ps1
                                        '''
                                    }
                                }
                                stage('Code Sign Detached') {
                                    when {
                                        expression { return env.BRANCH_NAME.startsWith('PR-') == false }
                                    }
                                    steps {
                                        echo 'Code Signing happening here....'
                                        script {
                                            townsuite.codesign "${env.WORKSPACE}/build", 'TownSuite*;*.zip', true
                                        }
                                    }
                                }
                                stage('Archive') {
                                    steps {
                                        echo 'archiving artifacts'
                                        script {
                                            townsuite.archiveWithRetryAndLock('build/*.zip,build/*.SHA256SUMS,build/*.sig,build/*.txt', 3)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            CleanupVirtualMachines()
        }
        success {
            echo 'Pipeline executed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
        aborted {
            echo 'Pipeline was aborted.'
        }
    }
}

def CleanupVirtualMachines() {
    node('stopping-agent') {
        cleanWs()
        script {
            townsuite_automation2.stop_automation()
        }
    }
}
