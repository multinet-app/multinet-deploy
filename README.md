# Readme

Ansible is an open-source software provisioning, configuration management, and application-deployment tool. It makes it very easy to write installation steps as code and running it against EC2 instances, vagrant machines or even your own host.

### Installing Ansible
Let's start with installing ansible:

It is recommended that you pip install packages to a virtualenv to keep your system Python clean.

```sh
pip install ansible
```

### Vagrant

In order to use it with vagrant simply:

```sh
vagrant up
```

That will provision an empty vagrant box (practice the ansible playbook we wrote against a vagrant box) and expose port 8080. After the provisioning step is over you can navigate to http://localhost:8080 and you should see your multinet instance. 

If you change something in the playbook and want to re-run you can:

```sh
vagrant provision
```

This will reprovision your instance and skip the steps that are already applied to your instance. If our ansible playbook is written nicely, it should be idempotent, which means the same steps should not be run over and over again. Each time we run the playbook (regardless of the state of the machine), it should produce the same results.

If you want to blow up the box and start over again simply:

```sh
vagrant destroy
vagrant up
```

### Ansible Playbook

#### Basics

Let's start with the first part of our ansible playbook. 

```yaml
- hosts: all
  remote_user: root
```

In vagrant box the remote user that we want to use is "root". However for AWS EC2 deployments that user might change. For example if you create an ubuntu instance, that variable should be set to "ubuntu". This is the user which ansible uses to ssh and invoke the commands that we told it to run.

The next section is where we define variables which would be used throughout our ansible playbook.

```yaml
  vars:
    ansible_python_interpreter: /usr/bin/python3
    multinet_server_path: "{{ ansible_env.HOME }}/multinet"
    adjmatrix_client_path: "{{ ansible_env.HOME }}/adjmatrix"
    nodelink_client_path: "{{ ansible_env.HOME }}/nodelink"
    arangodb_password: "letmein"
```

You might want to change the arangodb_password for the real deployment to an EC2 instance. 
This is not the only way to specify variables though. We can overwrite, what is in the playbook with an inventory file which we will cover in the following sections.

It is always a good idea to use roles. They are like npm or pip packages, but for ansible.

```yaml
  roles:
    - role: geerlingguy.nodejs
      become: true
```

These role names are coming from ansible galaxy. In order to use them, we specify them in our requirements.yml file. In the example above, that given role installs nodejs.

We can also import other "task" files, which specifies the tasks we want to run. 

```yaml
  tasks:
    - include_tasks: tasks/arangodb_tasks.yml
    - include_tasks: tasks/server_tasks.yml
    - include_tasks: tasks/client_tasks.yml
    - include_tasks: tasks/nodelink_tasks.yml
    - include_tasks: tasks/adjmatrix_tasks.yml
```

Each task file installs the necessary components to get multinet up and running.

#### EC2 Deployment

If we want to run this playbook against an EC2 instance, we need to create an inventory file. It is best not to commit the inventory file (in my opinion) since it might include secret variables such as database passwords.

Here is a sample inventory file:

```ini
[all:vars]
ansible_user=ubuntu 
ansible_python_interpreter=/usr/bin/python3 
arangodb_password="foobar"
ansible_ssh_private_key_file=./mykeypair.pem

[all]
IP_OF_EC2_INSTANCE
```

First step would be installing required roles:
```sh
ansible-galaxy install -r requirements.yml
```

Then run the playbook against the EC2 instance in our inventory file:

```sh
ansible-playbook -i inventory playbook.yml
```
