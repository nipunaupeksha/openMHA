// This file is part of the HörTech Open Master Hearing Aid (openMHA)
// Copyright © 2018 2019 HörTech gGmbH
//
// openMHA is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// openMHA is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License, version 3 for more details.
//
// You should have received a copy of the GNU Affero General Public License, 
// version 3 along with openMHA.  If not, see <http://www.gnu.org/licenses/>.

// On the 2019 windows build server, we cannot use the sh step anymore.
// This workaround invokes the msys2 bash, sets the required environment
// variables, and executes the desired command.
def windows_bash(command) {
  bat ('C:\\msys64\\usr\\bin\\bash -c "source /jenkins.environment && set -ex && ' + command + ' "')
  // This will probably fail if command contains multiple lines, quotes, or
  // similar.  Currently all our shell commands are simple enough for this
  // simple solution to work.  Should this no longer be sufficient, then we
  // could write the shell command to a temporary file and execute this file
  // after sourcing the enviroment.
}

// Encapsulation of the build steps to perform when compiling openMHA
// @param stage_name the stage name is "system && arch" where system is bionic,
//                   xenial, windows, or mac, and arch is x86_64, i686,
//                   or armv7. Both are separated by an && operator and spaces.
//                   This string is also used as a valid label expression for
//                   jenkins. The appropriate nodes have the respective labels.
//                   We might need to extend this in future to include the
//                   "mhadev" label, to differentiate build environments
//                   for the same system and architecture but with different
//                   library / tool dependencies.
def openmha_build_steps(stage_name) {
  // Extract components from stage_name:
  def system, arch, devenv
  (system,arch,devenv) = stage_name.split(/ *&& */) // regexp for missing/extra spaces

  // platform booleans
  def linux = (system != "windows" && system != "mac")
  def windows = (system == "windows")
  def mac = (system == "mac")
  def docs = (devenv == "mhadoc")

  // Compilation on ARM is the slowest, assign 5 CPU cores to each ARM build job
  def cpus = (arch == "armv7") ? 5 : 2 // default on other systems is 2 cores
  def additional_cpus_for_docs = 7

  // workaround to invoke unix shell on all systems
  def bash = { command -> windows ? windows_bash(command) : sh(command) }

  // checkout openMHA from version control system, the exact same revision that
  // triggered this job on each build slave
  checkout scm

  // Avoid that artifacts from previous builds influence this build
  bash "git reset --hard && git clean -ffdx"

  // Save time by using precompiled external libs if possible.
  // Install pre-compiled external libraries for the common branches
  copyArtifacts(projectName: "openMHA/external_libs/external_libs_development",
                selector:    lastSuccessful())
  bash "tar xvzf external_libs.tgz"

  // if we notice any differences between the sources of the precompiled
  // dependencies and the current sources, we cannot help but need to recompile
  bash "git diff --exit-code || (git reset --hard && git clean -ffdx)"

  // Autodetect libs/compiler
  bash "./configure"

  if (docs) {
    bash ("make -j ${cpus + additional_cpus_for_docs} doc")

    // Store generated PDF documents as Jenkins artifacts
    stash name: "docs", includes: '*.pdf'
    bash ("echo stashed docs on $system $arch at \$(date -R)")
    archiveArtifacts '*.pdf'
  }

  // Build executables, plugins, execute tests
  bash ("make -j $cpus test")

  // Retrieve the documents, wait if they are not ready yet
  def wait_time = 1
  def attempt = 0
  retry(45){
    sleep(wait_time)
    wait_time = 15
    attempt = attempt + 1
    bash ("echo unstash docs attempt $attempt on $system $arch at \$(date -R)")
    unstash "docs"
  }

  if (linux) {
    bash ("make -j $cpus deb")
    // Store debian packages
    stash name: (arch+"_"+system), includes: 'mha/tools/packaging/deb/hoertech/'
    archiveArtifacts 'mha/tools/packaging/deb/hoertech/*/*.deb'
  }

  if (windows) {
    bash ("make -j $cpus exe")
    // Store windows installer
    archiveArtifacts 'mha/tools/packaging/exe/*.exe'
  }

  if (mac) {
    bash ("make -j $cpus pkg")
    // Store mac installer
    archiveArtifacts 'mha/tools/packaging/pkg/*.pkg'
  }
}

pipeline {
    agent {label "jenkinsmaster"}
    stages {
        stage("build") {
            parallel {
                stage(                         "bionic && x86_64 && mhadoc") {
                    agent {label               "bionic && x86_64 && mhadoc"}
                    steps {openmha_build_steps("bionic && x86_64 && mhadoc")}
                }
                stage(                         "xenial && x86_64 && mhadev") {
                    agent {label               "xenial && x86_64 && mhadev"}
                    steps {openmha_build_steps("xenial && x86_64 && mhadev")}
                }
                stage(                         "bionic && i686 && mhadev") {
                    agent {label               "bionic && i686 && mhadev"}
                    steps {openmha_build_steps("bionic && i686 && mhadev")}
                }
                stage(                         "xenial && i686 && mhadev") {
                    agent {label               "xenial && i686 && mhadev"}
                    steps {openmha_build_steps("xenial && i686 && mhadev")}
                }
                stage(                         "bionic && armv7 && mhadev") {
                    agent {label               "bionic && armv7 && mhadev"}
                    steps {openmha_build_steps("bionic && armv7 && mhadev")}
                }
                stage(                         "xenial && armv7 && mhadev") {
                    agent {label               "xenial && armv7 && mhadev"}
                    steps {openmha_build_steps("xenial && armv7 && mhadev")}
                }
                stage(                         "windows && x86_64 && mhadev") {
                    agent {label               "windows && x86_64 && mhadev"}
                    steps {openmha_build_steps("windows && x86_64 && mhadev")}
                }
                stage(                         "mac && x86_64 && mhadev") {
                    agent {label               "mac && x86_64 && mhadev"}
                    steps {openmha_build_steps("mac && x86_64 && mhadev")}
                }
            }
        }
        stage("debian packages for apt") {
            agent {label "aptly"}
            // do not publish packages for any branches except these
            when { anyOf { branch 'master'; branch 'development' } }
            steps {
                // receive all deb packages from openmha build
                unstash "x86_64_bionic"
                unstash "x86_64_xenial"
                unstash "armv7_bionic"
                unstash "armv7_xenial"
                unstash "i686_bionic"
                unstash "i686_xenial"

                // Copies the new debs to the stash of existing debs,
                sh "make storage"
                build job:         "/hoertech-aptly/$BRANCH_NAME",
                      quietPeriod: 300,
                      wait:        false
            }
        }
    }

    // Email notification on failed build taken from
    // https://jenkins.io/doc/pipeline/tour/post/
    // multiple recipients are comma-separated:
    // https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#-mail-%20mail
    post {
        failure {
            mail to: 't.herzke@hoertech.de,p.maanen@hoertech.de,g.grimm@hoertech.de',
                 subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                 body: "Something is wrong with ${env.BUILD_URL}"
        }
    }
}
