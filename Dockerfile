FROM amazonlinux:2.0.20180827

# Pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN /bin/bash -c "python get-pip.py"

# Linters
RUN pip install cfn-lint
RUN pip install yamllint
RUN pip install pylint

# Shellcheck faff
RUN yum install -y xz tar
RUN curl -O "https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz"
RUN tar -xvf shellcheck-stable.linux.x86_64.tar.xz
RUN mv shellcheck-stable/shellcheck /usr/bin/
RUN mkdir /scan

ADD yamllintrc /
ADD lintball.sh /entry.sh
RUN chmod +x /entry.sh

ENTRYPOINT ["/entry.sh"]