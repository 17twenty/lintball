FROM amazonlinux:2.0.20180827

WORKDIR /scan

# node, it's needed for jsonlint
RUN curl -L https://rpm.nodesource.com/setup_10.x | bash -
RUN yum install -y nodejs
# Pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN /bin/bash -c "python get-pip.py"

# Linters
RUN pip install cfn-lint
RUN pip install yamllint
RUN pip install pylint
RUN pip install awscli --upgrade
RUN npm i jsonlint -g

# Shellcheck faff
RUN yum install -y xz tar
RUN curl -O "https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz"
RUN tar -xvf shellcheck-stable.linux.x86_64.tar.xz
RUN mv shellcheck-stable/shellcheck /usr/bin/

ADD yamllintrc .
ADD lintball.sh lintball.sh
RUN chmod +x lintball.sh

ENTRYPOINT ["lintball.sh"]