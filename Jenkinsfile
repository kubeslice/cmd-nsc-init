@Library('jenkins-library@opensource-release') _
dockerImagePipeline(
  script: this,
  service: 'cmd-nsc-init',
  dockerfile: 'Dockerfile',
  buildContext: '.',
  buildArguments: [PLATFORM:"amd64"]
  
)
