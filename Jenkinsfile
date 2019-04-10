import com.cwctravel.hudson.plugins.extended_choice_parameter.ExtendedChoiceParameterDefinition
ExtendedChoiceParameterDefinition extendedChoiceParameterDefinition = new ExtendedChoiceParameterDefinition(
  "name",
  "PT_CHECKBOX",
  "VALUE, A, B",
  null,//project name
  null,
  null,
  null,
  null,// bindings
  null,
  null, // propertykey
  "VALUE, B", //default value
  null,
  null,
  null,
  null, //default bindings
  null,
  null,
  null, //descriptionPropertyValue
  null,
  null,
  null,
  null,
  null,
  null,
  null,// javascript file
  null, // javascript
  false, // save json param to file
  false, // quote
  2, // visible item count
  "DESC",
  ","
)
params << test
props << parameters(params)

properties(props)

pipeline {
  agent any

  environment {
    PATH = '/usr/local/rvm/bin:/usr/bin:/bin'
    RUBY_VERSION = '2.3.7'
  }

  parameters {
    string(name: 'ALGIEBA_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'app\nfull', description: 'デプロイ範囲')
    extendedChoiceParameterDefinition
  }

  stages {
    stage('Install Gems') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        script {
          sh "rvm ${RUBY_VERSION} do bundle install --path=vendor/bundle"
        }
      }
    }

    stage('Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:models"
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:controllers"
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:views"
      }
    }

    stage('Deploy') {
      steps {
        ws("${env.WORKSPACE}/../chef") {
          script {
            git url: 'https://github.com/Leonis0813/subra.git', branch: params.SUBRA_BRANCH
            def version = params.ALGIEBA_VERSION.replaceFirst(/^.+\//, '')
            def recipe = ('app' == params.SCOPE ? 'app' : 'default')
            sh "sudo ALGIEBA_VERSION=${version} chef-client -z -r algieba::${recipe} -E ${env.ENVIRONMENT}"
          }
        }
      }
    }

    stage('System Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do env REMOTE_HOST=http://localhost/algieba bundle exec rake spec:requests"
      }
    }
  }
}
